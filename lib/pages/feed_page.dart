import 'package:together_version_2/pages/chat_page/chat_detail_page.dart';
import 'package:together_version_2/pages/feed_page/add_post_page/add_feed_page.dart';
import 'package:together_version_2/pages/feed_page/feed_app_bar.dart';
import 'package:together_version_2/pages/feed_page/feed_images_and_videos_widget.dart';
import 'package:together_version_2/pages/feed_page/feed_images_widget.dart';
import 'package:together_version_2/pages/feed_page/feed_video_widget/feed_videos_widget.dart';
import 'package:together_version_2/pages/feed_page/post_owner_widget.dart';
import 'package:together_version_2/pages/feed_page/post_text_widget.dart';
import 'package:together_version_2/pages/feed_page/react_and_comment_widget.dart';
import 'package:together_version_2/pages/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      // app bar

      appBar: const FeedAppBar(),

      //body

      body: StreamBuilder(
        stream: fireStore
            .collection('feed')
            .orderBy('time', descending: true)
            .snapshots(includeMetadataChanges: false),

        //
        builder: (context, streamSnapShot) {
          //
          if (streamSnapShot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: Colors.black87, size: 20));
          } else if (streamSnapShot.hasError) {
            return Center(child: Text("${streamSnapShot.error}"));
          } else if (streamSnapShot.data!.docs.isEmpty) {
            return const Center(child: Text("Fuck, No one posts in my app."));
          }

          //
          else {
            //list view
            return NotificationListener(
              onNotification: (ScrollNotification scrollInfo) {
                return true;
              },
              child: ListView.builder(
                itemCount: streamSnapShot.data!.docs.length,
                itemBuilder: (context, index) {
                  final postData = streamSnapShot.data!.docs[index];

                  //for images
                  List<dynamic> dynamicImageList = postData['imageList'];
                  List<String> imageStringList = dynamicImageList
                      .map((dynamic item) => item.toString())
                      .toList();
                  //for videos
                  List<dynamic> dynamicVideoList = postData['videoList'];
                  List<String> videoStringList = dynamicVideoList
                      .map((dynamic item) => item.toString())
                      .toList();

                  // ui
                  return KeyedSubtree(
                    key: UniqueKey(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: size.width,
                        child: Column(
                          children: [
                            //

                            // Post Owner widget
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    fullscreenDialog: true,
                                    maintainStateData: true,
                                    child: UserProfilePage(
                                        userId: postData['post_owner_uid']),
                                    inheritTheme: true,
                                    ctx: context,
                                    matchingBuilder:
                                        const CupertinoPageTransitionsBuilder(),
                                  ),
                                );
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(6),
                                  width: size.width,
                                  child: PostOwnerWidget(
                                    time: postData['time'],
                                    postId: postData.id,
                                    postData: postData,
                                  )),
                            ),

                            //Post Text Widget
                            Container(
                              padding: const EdgeInsets.all(6),
                              width: size.width,
                              child: PostText(postText: postData['post_text']),
                            ),

                            // Post Image Widget
                            videoStringList.isEmpty
                                ? FeedImagesWidget(imageList: imageStringList)
                                : imageStringList.isEmpty
                                    ? FeedVideosWidget(
                                        videoList: videoStringList)
                                    : FeedImagesAndVideosWidget(
                                        imageList: imageStringList,
                                        videoList: videoStringList),

                            //React and Comment Widget
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: size.width,
                              child: ReactAndCommentWidget(postId: postData.id),
                            ),
                            const Divider(
                                color: Colors.black87, thickness: 0.6),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        child: const Icon(Iconsax.edit, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.bottomToTop,
              fullscreenDialog: true,
              maintainStateData: true,
              child: const AddFeedPage(),
              inheritTheme: true,
              ctx: context,
              matchingBuilder: const CupertinoPageTransitionsBuilder(),
            ),
          );
        },
      ),
    );
  }
}
