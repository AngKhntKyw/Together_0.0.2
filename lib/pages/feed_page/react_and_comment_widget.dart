import 'package:together_version_2/pages/chat_page/chat_detail_page.dart';
import 'package:together_version_2/pages/feed_page/react_and_comment_detail_page.dart';
import 'package:together_version_2/services/feed_services.dart';
import 'package:together_version_2/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:developer';

class ReactAndCommentWidget extends StatelessWidget {
  final String postId;
  const ReactAndCommentWidget({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final fireAuth = FirebaseAuth.instance;

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
        }
        List<dynamic> postReact = snapshot.data!.docs[0]['react'];
        List<dynamic> postComment = snapshot.data!.docs[0]['comment'];
        final isReacted = postReact.contains(
            fireStore.collection('users').doc(fireAuth.currentUser!.uid));

        return InkWell(
          onTap: () {
            showModalBottomSheet(
              enableDrag: true,
              isDismissible: true,
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              showDragHandle: true,
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              useSafeArea: true,
              elevation: 0,
              builder: (context) {
                return DraggableScrollableSheet(
                  initialChildSize: 1,
                  shouldCloseOnMinExtent: true,
                  maxChildSize: 1,
                  minChildSize: 1,
                  expand: false,
                  snapAnimationDuration: const Duration(milliseconds: 300),
                  builder: (context, scrollController) {
                    return ReactAndCommentDetailPage(
                      postId: postId,
                    );
                  },
                );
              },
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: !isReacted
                        ? () async {
                            log("React");

                            Utils.loadSound('sound/like.wav');

                            postReact.add(fireStore
                                .collection('users')
                                .doc(fireAuth.currentUser!.uid));

                            await FeedServices.reactPost(
                                postId, context, postReact);
                          }
                        : () async {
                            postReact.remove(fireStore
                                .collection('users')
                                .doc(fireAuth.currentUser!.uid));
                            await FeedServices.reactPost(
                                postId, context, postReact);
                          },
                    //
                    icon: Icon(
                      !isReacted ? Iconsax.lovely : Iconsax.lovely5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text("${postReact.length}"),
                ],
              ),
              Row(
                children: [
                  const Icon(Iconsax.message5),
                  const SizedBox(width: 10),
                  Text("${postComment.length}"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
