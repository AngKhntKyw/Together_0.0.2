import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:together_version_2/pages/feed_page/view_feed_images_list_horizontally_page.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ViewFeedImagesListVerticallyPage extends StatefulWidget {
  final List<String> imagesList;
  final int initialIndex;
  const ViewFeedImagesListVerticallyPage({
    super.key,
    required this.imagesList,
    required this.initialIndex,
  });

  @override
  State<ViewFeedImagesListVerticallyPage> createState() =>
      _ViewFeedImagesListVerticallyPageState();
}

class _ViewFeedImagesListVerticallyPageState
    extends State<ViewFeedImagesListVerticallyPage> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(
      initialScrollOffset: widget.initialIndex == widget.imagesList.length - 1
          ? (widget.initialIndex * 350) - 350
          : widget.initialIndex * 350,
      keepScrollOffset: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: true,
      ),
      body: Dismissible(
        movementDuration: const Duration(milliseconds: 10),
        resizeDuration: const Duration(milliseconds: 10),
        key: UniqueKey(),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            Navigator.of(context).pop();
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView.separated(
              dragStartBehavior: DragStartBehavior.start,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              addSemanticIndexes: false,
              physics: const ClampingScrollPhysics(),
              itemCount: widget.imagesList.length,
              controller: _controller,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ViewFeedImagesListHorizontallyPage(
                                  imagesList: widget.imagesList,
                                  initialIndex: index),
                        ));
                  },
                  child: Hero(
                    tag: widget.imagesList[index],
                    child: CachedNetworkImage(
                      cacheKey: widget.imagesList[index],
                      imageUrl: widget.imagesList[index],
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        height: 350,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        height: 350,
                        color: const Color.fromARGB(255, 235, 235, 235),
                        child: Center(
                          child: LoadingAnimationWidget.hexagonDots(
                              color: Colors.black87, size: 20),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  color: Colors.transparent,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
