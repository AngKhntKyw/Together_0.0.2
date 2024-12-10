import 'package:together_version_2/pages/feed_page/feed_video_widget/video_widget.dart';
import 'package:flutter/material.dart';

class FeedVideosWidget extends StatelessWidget {
  final List<String> videoList;
  const FeedVideosWidget({
    super.key,
    required this.videoList,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // one video
    if (videoList.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
            width: size.width,
            height: 400,
            child: VideoWidget(
              videoUrl: videoList[0],
              index: 0,
              videoList: videoList,
            )),
      );
    }

    // 2 videos
    else if (videoList.length == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: size.width,
          height: 400,
          child: Row(
            children: [
              Expanded(
                child: VideoWidget(
                  videoUrl: videoList[0],
                  index: 0,
                  videoList: videoList,
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: VideoWidget(
                  videoUrl: videoList[1],
                  index: 1,
                  videoList: videoList,
                ),
              )
            ],
          ),
        ),
      );
    }

    // 3 videos
    else if (videoList.length == 3) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: size.width,
          height: 400,
          child: Column(
            children: [
              Expanded(
                  child: VideoWidget(
                videoUrl: videoList[0],
                index: 0,
                videoList: videoList,
              )),
              const SizedBox(height: 2),
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                      child: VideoWidget(
                    videoUrl: videoList[1],
                    index: 1,
                    videoList: videoList,
                  )),
                  const SizedBox(width: 2),
                  Expanded(
                      child: VideoWidget(
                    videoUrl: videoList[2],
                    index: 2,
                    videoList: videoList,
                  )),
                ],
              ))
            ],
          ),
        ),
      );
    }

    // 4 videos
    else if (videoList.length == 4) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: size.width,
          height: 400,
          child: Column(
            children: [
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                      child: VideoWidget(
                    videoUrl: videoList[0],
                    index: 0,
                    videoList: videoList,
                  )),
                  const SizedBox(width: 2),
                  Expanded(
                      child: VideoWidget(
                    videoUrl: videoList[1],
                    index: 1,
                    videoList: videoList,
                  )),
                ],
              )),
              const SizedBox(height: 2),
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                      child: VideoWidget(
                    videoUrl: videoList[2],
                    index: 2,
                    videoList: videoList,
                  )),
                  const SizedBox(width: 2),
                  Expanded(
                      child: VideoWidget(
                    videoUrl: videoList[3],
                    index: 3,
                    videoList: videoList,
                  )),
                ],
              )),
            ],
          ),
        ),
      );
    }

    // more than 4 videos
    else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: size.width,
          height: 400,
          child: Column(
            children: [
              Expanded(
                  child: VideoWidget(
                videoUrl: videoList[0],
                index: 0,
                videoList: videoList,
              )),
              const SizedBox(height: 2),
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                      child: VideoWidget(
                    videoUrl: videoList[1],
                    index: 1,
                    videoList: videoList,
                  )),
                  const SizedBox(width: 2),
                  Expanded(
                      child: VideoWidget(
                    videoUrl: videoList[2],
                    index: 2,
                    videoList: videoList,
                  )),
                  const SizedBox(width: 2),
                  Expanded(
                      child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoWidget(
                        videoUrl: videoList[3],
                        index: 3,
                        videoList: videoList,
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          "+${videoList.length - 4}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )),
                ],
              ))
            ],
          ),
        ),
      );
    }
  }
}
