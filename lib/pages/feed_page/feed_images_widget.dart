import 'package:together_version_2/pages/feed_page/cache_network_image_widget.dart';
import 'package:flutter/material.dart';

class FeedImagesWidget extends StatelessWidget {
  final List<String> imageList;
  const FeedImagesWidget({
    super.key,
    required this.imageList,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Check the length of ImagesList and decide widget

    // For 1 image

    if (imageList.length == 1) {
      return SizedBox(
        width: size.width,
        height: 400,
        child: CacheNetworkImageWidget(
            image: imageList[0],
            imageIndex: 0,
            imagesList: imageList,
            borderRadius: BorderRadius.circular(20),
            size: size.width),
      );
    }

    // For 2 images
    else if (imageList.length == 2) {
      return SizedBox(
        width: size.width,
        height: 400,
        child: Row(
          children: [
            Expanded(
              child: CacheNetworkImageWidget(
                  image: imageList[0],
                  imagesList: imageList,
                  imageIndex: 0,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20)),
                  size: size.width),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: CacheNetworkImageWidget(
                  imagesList: imageList,
                  imageIndex: 1,
                  image: imageList[1],
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  size: size.width),
            ),
          ],
        ),
      );
    }

    // For 3 images
    else if (imageList.length == 3) {
      return Container(
        width: size.width,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: CacheNetworkImageWidget(
                  imagesList: imageList,
                  imageIndex: 0,
                  image: imageList[0],
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20)),
                  size: size.width),
            ),
            const SizedBox(width: 2),
            Expanded(
                child: Column(
              children: [
                Expanded(
                  child: CacheNetworkImageWidget(
                      imagesList: imageList,
                      imageIndex: 1,
                      image: imageList[1],
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                      ),
                      size: size.width),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: CacheNetworkImageWidget(
                      imagesList: imageList,
                      imageIndex: 2,
                      image: imageList[2],
                      borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(20)),
                      size: size.width),
                ),
              ],
            )),
          ],
        ),
      );
    }

    // For 4 images
    else if (imageList.length == 4) {
      return Container(
        width: size.width,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
                child: Column(
              children: [
                Expanded(
                  child: CacheNetworkImageWidget(
                      imagesList: imageList,
                      imageIndex: 0,
                      image: imageList[0],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                      ),
                      size: size.width),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: CacheNetworkImageWidget(
                      imagesList: imageList,
                      imageIndex: 1,
                      image: imageList[1],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                      ),
                      size: size.width),
                ),
              ],
            )),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: CacheNetworkImageWidget(
                        imagesList: imageList,
                        imageIndex: 2,
                        image: imageList[2],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                        ),
                        size: size.width),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: CacheNetworkImageWidget(
                        imagesList: imageList,
                        imageIndex: 3,
                        image: imageList[3],
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(20),
                        ),
                        size: size.width),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // starts from 5 images
    else {
      return Container(
        width: size.width,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: CacheNetworkImageWidget(
                  imagesList: imageList,
                  imageIndex: 0,
                  image: imageList[0],
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20)),
                  size: size.width),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: CacheNetworkImageWidget(
                        imagesList: imageList,
                        imageIndex: 1,
                        image: imageList[1],
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                        ),
                        size: size.width),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: CacheNetworkImageWidget(
                        imagesList: imageList,
                        imageIndex: 2,
                        image: imageList[2],
                        borderRadius: BorderRadius.circular(0),
                        size: size.width),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CacheNetworkImageWidget(
                            imagesList: imageList,
                            imageIndex: 3,
                            image: imageList[3],
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(20),
                            ),
                            size: size.width),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            "+${imageList.length - 4}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
  }
}
