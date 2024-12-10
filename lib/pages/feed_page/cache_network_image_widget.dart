import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/pages/feed_page/view_feed_images_list_horizontally_page.dart';
import 'package:together_version_2/pages/feed_page/view_feed_images_llist_vertically_page.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CacheNetworkImageWidget extends StatelessWidget {
  final String image;
  final BorderRadius borderRadius;
  final int imageIndex;
  final double size;
  final List<String> imagesList;
  const CacheNetworkImageWidget({
    super.key,
    required this.image,
    required this.borderRadius,
    required this.size,
    required this.imageIndex,
    required this.imagesList,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        imagesList.length != 1
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewFeedImagesListVerticallyPage(
                    imagesList: imagesList,
                    initialIndex: imageIndex,
                  ),
                ))
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewFeedImagesListHorizontallyPage(
                    imagesList: imagesList,
                    initialIndex: imageIndex,
                  ),
                ));
      },
      child: CachedNetworkImage(
        cacheKey: image,
        imageUrl: image,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) =>
            LoadingAnimationWidget.hexagonDots(color: Colors.black87, size: 20),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
