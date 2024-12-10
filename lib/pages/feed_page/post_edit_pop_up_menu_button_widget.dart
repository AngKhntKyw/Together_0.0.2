import 'package:together_version_2/pages/feed_page/edit_post_page/edit_feed_page.dart';
import 'package:together_version_2/services/feed_services.dart';
import 'package:together_version_2/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:page_transition/page_transition.dart';

class PostEditPopUpMenuButtonWidget extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> postData;
  final String postId;

  const PostEditPopUpMenuButtonWidget({
    super.key,
    required this.postData,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        surfaceTintColor: Colors.white,
        onSelected: (value) {
          switch (value) {
            case 'DELETE':
              showDeleteConfirmationBox(context, postData);
              break;

            case 'EDIT':
              List<dynamic> imageDynamicList = postData['imageList'];
              List<String> imageStringList = imageDynamicList
                  .map((dynamic item) => item.toString())
                  .toList();
              List<dynamic> videoDynamicList = postData['videoList'];
              List<String> videoStringList = videoDynamicList
                  .map((dynamic item) => item.toString())
                  .toList();

              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  fullscreenDialog: true,
                  maintainStateData: true,
                  child: EditFeedPage(
                    postId: postId,
                    oldImageStringList: imageStringList,
                    oldVideoStringList: videoStringList,
                    postText: postData['post_text'],
                  ),
                  inheritTheme: true,
                  ctx: context,
                  matchingBuilder: const CupertinoPageTransitionsBuilder(),
                ),
              );
              break;

            default:
              break;
          }
        },
        icon: const Icon(Iconsax.more_circle5),
        itemBuilder: (BuildContext context) {
          return [
            popUpMenuItemWidget('DELETE', 'delete', Iconsax.trash),
            popUpMenuItemWidget('EDIT', 'edit', Iconsax.edit),
          ];
        });
  }
}

PopupMenuItem popUpMenuItemWidget(String value, String name, IconData icon) {
  return PopupMenuItem(
    value: value,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black87, size: 18),
        const SizedBox(width: 10),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w400)),
      ],
    ),
  );
}

void showDeleteConfirmationBox(BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> postData) {
  final nav = Navigator.of(context);
  showModalBottomSheet(
    enableDrag: true,
    isDismissible: true,
    shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(50)),
    showDragHandle: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    elevation: 0,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.2,
        shouldCloseOnMinExtent: true,
        maxChildSize: 1,
        minChildSize: 0.2,
        expand: false,
        snapAnimationDuration: const Duration(milliseconds: 500),
        builder: (context, scrollController) {
          return SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Are you sure to delete this post?"),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        nav.pop();
                      },
                      child: const Text('NO'),
                    ),
                    //
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () async {
                        nav.pop();
                        await FeedServices.deletePost(postData.id, context);
                        Utils.loadSound('sound/delete.wav');
                      },
                      child: const Text('YES'),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      );
    },
  );
}
