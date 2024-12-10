import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_view/photo_view.dart';

class ViewImage extends StatefulWidget {
  final String imageUrl;
  const ViewImage({super.key, required this.imageUrl});

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  bool isButtonsShowed = false;

  @override
  void dispose() {
    isButtonsShowed = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Hero(
        tag: widget.imageUrl,
        child: Container(
          height: size.height,
          width: size.width,
          color: Colors.black87,
          child: Stack(
            children: [
              Center(
                child: PhotoView(
                  onTapDown: (context, details, controllerValue) {
                    setState(() {
                      isButtonsShowed
                          ? isButtonsShowed = false
                          : isButtonsShowed = true;
                    });
                  },
                  onScaleEnd: (context, details, controllerValue) {
                    controllerValue.position == const Offset(0.0, 0.0)
                        ? Navigator.pop(context)
                        : null;
                  },
                  gestureDetectorBehavior: HitTestBehavior.deferToChild,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 4,
                  loadingBuilder: (context, event) {
                    return LoadingAnimationWidget.hexagonDots(
                        color: Colors.black87, size: 20);
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error);
                  },
                  enablePanAlways: false,
                  gaplessPlayback: true,
                  enableRotation: false,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black87,
                  ),
                  imageProvider: CachedNetworkImageProvider(
                    widget.imageUrl,
                    cacheKey: widget.imageUrl,
                  ),
                ),
              ),
              isButtonsShowed
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                            width: size.width,
                            height: size.height / 15,
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.arrow_back)),
                                ),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                    ))
                              ],
                            )),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
