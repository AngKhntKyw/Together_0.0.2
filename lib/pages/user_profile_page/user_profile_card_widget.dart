import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/pages/view_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class UserProfileCardWidget extends StatelessWidget {
  final String userId;
  const UserProfileCardWidget({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final fireStore = FirebaseFirestore.instance;
    final size = MediaQuery.sizeOf(context);

    return Container(
      width: size.width,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: StreamBuilder(
        stream: fireStore.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          //
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: Colors.black87, size: 20));
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          } else {
            return Container(
              alignment: Alignment.center,
              color: Colors.transparent,
              width: size.width,
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewImage(
                                  imageUrl: snapshot.data!['coverImage'],
                                ),
                              )),
                          child: Hero(
                            tag: snapshot.data!['coverImage'],
                            child: CachedNetworkImage(
                              imageUrl: snapshot.data!['coverImage'],
                              width: size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                            color: Colors.transparent,
                          )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewImage(
                                  imageUrl: snapshot.data!['profileImage'],
                                ),
                              )),
                          child: Hero(
                            tag: snapshot.data!['profileImage'],
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                  radius: 42,
                                  backgroundColor: Colors.black87,
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child:
                                            LoadingAnimationWidget.hexagonDots(
                                                color: Colors.black87,
                                                size: 20),
                                        radius: 42,
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                                cacheKey: snapshot
                                                    .data!['profileImage'],
                                                snapshot.data!['profileImage']),
                                      ),
                                      Offstage(
                                        offstage: !snapshot.data!['isOnline'],
                                        child: const CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            radius: 8,
                                            backgroundColor: Colors.green,
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data!['name'],
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                              Text(
                                snapshot.data!['email'],
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
