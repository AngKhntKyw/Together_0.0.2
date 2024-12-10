import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewImagePage extends StatelessWidget {
  final String image;
  const ViewImagePage({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: PhotoView(
        heroAttributes: PhotoViewHeroAttributes(tag: image),
        onScaleEnd: (context, details, controllerValue) {
          controllerValue.position == const Offset(0.0, 0.0)
              ? Navigator.pop(context)
              : null;
        },
        wantKeepAlive: true,
        gaplessPlayback: true,
        disableGestures: false,
        enablePanAlways: false,
        initialScale: PhotoViewComputedScale.contained,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered,
        imageProvider: CachedNetworkImageProvider(
          image,
          cacheKey: image,
        ),
      ),
    );
  }
}
