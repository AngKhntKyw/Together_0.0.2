import 'package:together_version_2/pages/feed_page/cache_network_image_widget.dart';
import 'package:together_version_2/pages/feed_page/feed_video_widget/video_widget.dart';
import 'package:flutter/material.dart';

class FeedImagesAndVideosWidget extends StatelessWidget {
  final List<String> imageList;
  final List<String> videoList;
  const FeedImagesAndVideosWidget({
    super.key,
    required this.imageList,
    required this.videoList,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 400,
        width: size.width,
        child: Row(
          children: [
            Expanded(child: ImagesWidget(imageList, size.width)),
            // Expanded(child: FeedImagesWidget(imageList: imageList)),
            const SizedBox(width: 2),
            Expanded(child: VideosWidget(videoList)),
            // Expanded(child: FeedVideosWidget(videoList: videoList)),
          ],
        ),
      ),
    );
  }
}

//for images

Widget ImagesWidget(List<String> imagesList, double size) {
  if (imagesList.length == 1) {
    return CacheNetworkImageWidget(
        image: imagesList[0],
        borderRadius: BorderRadius.circular(0),
        size: size,
        imageIndex: 0,
        imagesList: imagesList);
  } else if (imagesList.length == 2) {
    return Column(
      children: [
        Expanded(
          child: CacheNetworkImageWidget(
              image: imagesList[0],
              borderRadius: BorderRadius.circular(0),
              size: size,
              imageIndex: 0,
              imagesList: imagesList),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: CacheNetworkImageWidget(
              image: imagesList[1],
              borderRadius: BorderRadius.circular(0),
              size: size,
              imageIndex: 1,
              imagesList: imagesList),
        ),
      ],
    );
  } else {
    return Column(
      children: [
        Expanded(
          child: CacheNetworkImageWidget(
              image: imagesList[0],
              borderRadius: BorderRadius.circular(0),
              size: size,
              imageIndex: 0,
              imagesList: imagesList),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CacheNetworkImageWidget(
                  image: imagesList[1],
                  borderRadius: BorderRadius.circular(0),
                  size: size,
                  imageIndex: 1,
                  imagesList: imagesList),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  "+ ${imagesList.length - 2}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//for videos
Widget VideosWidget(List<String> videosList) {
  if (videosList.length == 1) {
    return VideoWidget(
      videoUrl: videosList[0],
      index: 0,
      videoList: videosList,
    );
  } else if (videosList.length == 2) {
    return Column(
      children: [
        Expanded(
          child: VideoWidget(
            videoUrl: videosList[0],
            index: 0,
            videoList: videosList,
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: VideoWidget(
            videoUrl: videosList[1],
            index: 1,
            videoList: videosList,
          ),
        )
      ],
    );
  } else {
    return Column(
      children: [
        Expanded(
          child: VideoWidget(
            videoUrl: videosList[0],
            index: 0,
            videoList: videosList,
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoWidget(
                videoUrl: videosList[1],
                index: 1,
                videoList: videosList,
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  "+${videosList.length - 2}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
