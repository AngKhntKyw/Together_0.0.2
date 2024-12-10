import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:together_version_2/pages/chat_page/play_video_page.dart';
import 'package:together_version_2/pages/feed_page/view_feed_videos_list_vertically_page.dart';
import 'package:together_version_2/services/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VideoWidget extends StatelessWidget {
  final String videoUrl;
  final List<String> videoList;
  final int index;

  const VideoWidget({
    super.key,
    required this.videoUrl,
    required this.index,
    required this.videoList,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return FutureBuilder(
      future: ChatServices.getThumbnail(videoUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.hexagonDots(
                color: Colors.black87, size: 20),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Icon(Iconsax.info_circle5),
          );
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => videoList.length == 1
                          ? PlayVideoPage(videoUrl: videoUrl)
                          : ViewFeedVideosListVerticallyPage(
                              videoList: videoList, initialIndex: index),
                    ));
              },
              child: SizedBox(
                height: size.height / 2,
                width: size.width,
                child: FadeInImage(
                  placeholder: CachedMemoryImagePlaceholderProvider(
                    bytes: snapshot.data!,
                  ),
                  image: CachedMemoryImageProvider(
                    cached: CachedImage.cacheAndRead,
                    videoUrl,
                    bytes: snapshot.data!,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayVideoPage(videoUrl: videoUrl),
                    ));
              },
              icon: const Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 45,
              ),
            ),
          ],
        );
      },
    );
  }
}
