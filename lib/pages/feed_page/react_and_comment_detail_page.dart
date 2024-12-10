import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/services/feed_services.dart';
import 'package:together_version_2/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ReactAndCommentDetailPage extends StatelessWidget {
  final String postId;
  const ReactAndCommentDetailPage({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();
    final fireAuth = FirebaseAuth.instance;
    final fireStore = FirebaseFirestore.instance;

    //
    return StreamBuilder(
        stream: fireStore
            .collection('feed')
            .doc(postId)
            .collection('react')
            .snapshots(includeMetadataChanges: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: Colors.black87, size: 20));
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          } else {
            List<dynamic> postReact = snapshot.data!.docs[0]['react'];
            List<dynamic> postComment = snapshot.data!.docs[0]['comment'];

            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  // title: const Text("Reacts & Comments"),
                  bottom: TabBar(
                    indicatorColor: Colors.black87,
                    labelColor: Colors.black87,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 4,
                    tabs: [
                      Tab(text: 'Comments (${postComment.length})'),
                      Tab(text: 'Reacts (${postReact.length})'),
                    ],
                  ),
                  titleSpacing: 0,
                  toolbarHeight: 0,
                ),
                body: TabBarView(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: postComment.length,
                            itemBuilder: (context, index) {
                              DocumentReference<Map<String, dynamic>>
                                  postOwnerData =
                                  postComment[index]['comment_owner'];

                              //
                              return StreamBuilder(
                                stream: postOwnerData.snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child:
                                            LoadingAnimationWidget.hexagonDots(
                                                color: Colors.black87,
                                                size: 20));
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text("${snapshot.error}"));
                                  }

                                  return ListTile(
                                    leading: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child:
                                            LoadingAnimationWidget.hexagonDots(
                                                color: Colors.black87,
                                                size: 20),
                                        radius: 15,
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                                cacheKey: snapshot
                                                    .data!['profileImage'],
                                                snapshot
                                                    .data!['profileImage'])),
                                    title: Text(
                                      "${snapshot.data!['name']}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                        postComment[index]['comment_text']),

                                    //
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: commentController,
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade200)),
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      hintText: "Comment ....",
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                      contentPadding: const EdgeInsets.all(8)),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  if (commentController.text.isNotEmpty) {
                                    postComment.add({
                                      "comment_text": commentController.text,
                                      "comment_owner": fireStore
                                          .collection('users')
                                          .doc(fireAuth.currentUser!.uid),
                                    });

                                    await FeedServices.commentPost(
                                        postId, context, postComment);
                                    commentController.clear();
                                    Utils.loadSound('sound/comment.wav');
                                  } else {
                                    log("Enter....");
                                  }
                                },
                                icon: const Icon(Iconsax.send_15,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    //

                    ListView.builder(
                      itemCount: postReact.length,
                      itemBuilder: (context, index) {
                        DocumentReference<Map<String, dynamic>> postOwnerData =
                            postReact[index];

                        //
                        return StreamBuilder(
                          stream: postOwnerData.snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child: LoadingAnimationWidget.hexagonDots(
                                      color: Colors.black87, size: 20));
                            } else if (snapshot.hasError) {
                              return Center(child: Text("${snapshot.error}"));
                            }

                            return ListTile(
                              leading: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: LoadingAnimationWidget.hexagonDots(
                                      color: Colors.black87, size: 20),
                                  radius: 15,
                                  foregroundImage: CachedNetworkImageProvider(
                                      cacheKey: snapshot.data!['profileImage'],
                                      snapshot.data!['profileImage'])),
                              title: Text(
                                "${snapshot.data!['name']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),

                              //
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }
}
