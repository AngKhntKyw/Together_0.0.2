import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/pages/chat_page/chat_detail_page.dart';
import 'package:together_version_2/pages/feed_page/post_edit_pop_up_menu_button_widget.dart';
import 'package:together_version_2/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PostOwnerWidget extends StatelessWidget {
  final Timestamp time;
  final String postId;
  final QueryDocumentSnapshot<Map<String, dynamic>> postData;
  const PostOwnerWidget({
    super.key,
    required this.time,
    required this.postId,
    required this.postData,
  });

  @override
  Widget build(BuildContext context) {
    final fireAuth = FirebaseAuth.instance;
    //
    return StreamBuilder(
      stream: fireStore
          .collection('feed')
          .doc(postId)
          .collection('post_owner')
          .snapshots(includeMetadataChanges: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: Colors.black87, size: 20));
        } else if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        }
        DocumentReference<Map<String, dynamic>> postOwner =
            snapshot.data!.docs[0]['owner'];

        return StreamBuilder(
          stream: postOwner.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: LoadingAnimationWidget.hexagonDots(
                      color: Colors.black87, size: 20));
            } else if (snapshot.hasError) {
              return Center(child: Text("${snapshot.error}"));
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      foregroundImage: CachedNetworkImageProvider(
                          cacheKey: snapshot.data!['profileImage'],
                          snapshot.data!['profileImage']),
                      child: LoadingAnimationWidget.hexagonDots(
                          color: Colors.black87, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!['name'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          Utils.changeIntoTimeAgo(time),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                Offstage(
                  offstage: fireAuth.currentUser!.uid != snapshot.data!['uid'],
                  child: PostEditPopUpMenuButtonWidget(
                    postId: postId,
                    postData: postData,
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}
