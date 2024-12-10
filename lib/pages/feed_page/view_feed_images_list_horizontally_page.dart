import 'dart:developer';
import 'package:together_version_2/services/feed_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ViewFeedImagesListHorizontallyPage extends StatefulWidget {
  final List<String> imagesList;
  final int initialIndex;
  const ViewFeedImagesListHorizontallyPage({
    super.key,
    required this.imagesList,
    required this.initialIndex,
  });

  @override
  State<ViewFeedImagesListHorizontallyPage> createState() =>
      _ViewFeedImagesListHorizontallyPageState();
}

class _ViewFeedImagesListHorizontallyPageState
    extends State<ViewFeedImagesListHorizontallyPage> {
  bool isButtonsShowed = false;
  late PageController _pageController;
  late String downloadUrl;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.initialIndex);
    downloadUrl = widget.imagesList[widget.initialIndex];
    super.initState();
  }

  @override
  void dispose() {
    isButtonsShowed = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context1) {
    log(downloadUrl);
    return Scaffold(
        body: Stack(
      children: [
        GestureDetector(
          onLongPress: () {
            showModalBottomSheet(
              enableDrag: true,
              isDismissible: true,
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              showDragHandle: true,
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              elevation: 0,
              builder: (context) {
                return SizedBox(
                  height: 100,
                  child: ListTile(
                    leading: Icon(Iconsax.document_download5),
                    title: Text("Save to phone"),
                    onTap: () async {
                      requestFileStoragePermissions();
                      FeedServices.saveNetworkImage(downloadUrl, context1);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            );
          },
          child: PhotoViewGallery.builder(
            onPageChanged: (index) {
              setState(() {
                downloadUrl = widget.imagesList[index];
              });
            },
            wantKeepAlive: true,
            gaplessPlayback: false,
            pageController: _pageController,
            itemCount: widget.imagesList.length,
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(
                  widget.imagesList[index],
                  cacheKey: widget.imagesList[index],
                ),
                onScaleEnd: (context, details, controllerValue) {
                  controllerValue.position == const Offset(0.0, 0.0)
                      ? Navigator.pop(context)
                      : null;
                },
                onTapDown: (context, details, controllerValue) {
                  setState(() {
                    isButtonsShowed
                        ? isButtonsShowed = false
                        : isButtonsShowed = true;
                  });
                },
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                heroAttributes:
                    PhotoViewHeroAttributes(tag: widget.imagesList[index]),
              );
            },
            loadingBuilder: (context, event) => Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.black87,
                  strokeWidth: 4,
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 20,
          child: Offstage(
            offstage: !isButtonsShowed,
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: BackButton(),
            ),
          ),
        )
      ],
    ));
  }

  Future<void> requestFileStoragePermissions() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
    } else if (status.isGranted) {
      log("File storage permissions granted.");
    } else {
      log("File storage permissions denied.");
    }
  }
}
