import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/services/feed_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ViewImagesListPage extends StatefulWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> images;
  final int id;
  const ViewImagesListPage({
    super.key,
    required this.images,
    required this.id,
  });

  @override
  State<ViewImagesListPage> createState() => _ViewImagesListPageState();
}

class _ViewImagesListPageState extends State<ViewImagesListPage> {
  ScrollController? scrollController;
  late PageController pageController;
  bool isButtonsShowed = false;
  late int pageId;
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> imagesList;
  late String downloadUrl;

  @override
  void initState() {
    //
    downloadUrl = widget.images[widget.id]['message'];
    pageId = widget.id;
    log("PageID After : $pageId");

    pageController = PageController(initialPage: pageId);
    scrollController = ScrollController(
      onAttach: (position) {
        log("Scroll list attached");
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    scrollController!.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context1) {
    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onVerticalDragEnd: (details) {
        details.velocity != Velocity.zero ? Navigator.pop(context) : null;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(
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
                            FeedServices.saveNetworkImage(
                                downloadUrl, context1);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  );
                },
                child: PhotoViewGallery.builder(
                  wantKeepAlive: true,
                  gaplessPlayback: false,
                  pageController: pageController,
                  itemCount: widget.images.length,
                  onPageChanged: (index) {
                    setState(() {
                      pageId = index;
                      downloadUrl = widget.images[index]['message'];
                    });
                    double startIndex = scrollController!.position.pixels / 50;
                    double endIndex = (startIndex + size.width / 50);
                    if (index >= startIndex && index <= endIndex) {
                      null;
                    } else {
                      scrollController!.animateTo(
                        index * 50,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      onTapDown: (context, details, controllerValue) {
                        setState(() {
                          isButtonsShowed
                              ? isButtonsShowed = false
                              : isButtonsShowed = true;
                        });
                      },
                      imageProvider: CachedNetworkImageProvider(
                          cacheKey: widget.images[index]['message'],
                          widget.images[index]['message']),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      heroAttributes: PhotoViewHeroAttributes(
                          tag: widget.images[index]['message']),
                    );
                  },
                  loadingBuilder: (context, event) => Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 4,
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded /
                                event.expectedTotalBytes!,
                      ),
                    ),
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
                            alignment: Alignment.center,
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
                                    onPressed: () {
                                      showModalBottomSheet(
                                        enableDrag: true,
                                        isDismissible: true,
                                        shape: ContinuousRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        showDragHandle: true,
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.white,
                                        elevation: 0,
                                        builder: (context) {
                                          return SizedBox(
                                            height: 100,
                                            child: ListTile(
                                              leading: Icon(
                                                  Iconsax.document_download5),
                                              title: Text("Save to phone"),
                                              onTap: () async {
                                                requestFileStoragePermissions();
                                                FeedServices.saveNetworkImage(
                                                    downloadUrl, context1);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                    ))
                              ],
                            )),
                      ),
                    )
                  : const SizedBox(),
              Positioned(
                bottom: 0,
                child: Offstage(
                  offstage: !isButtonsShowed,
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    height: 50,
                    width: size.width,
                    child: ListView.builder(
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
                      addSemanticIndexes: false,
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: widget.images.length,
                      itemBuilder: (BuildContext context, int index) {
                        final imageUrl = widget.images[index]['message'];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              pageController.animateToPage(index,
                                  duration: const Duration(milliseconds: 1),
                                  curve: Curves.linear);
                            });
                          },
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.bounceInOut,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.symmetric(
                                      horizontal: BorderSide(
                                        width: 1,
                                        color: pageId == index
                                            ? Colors.white
                                            : Colors.transparent,
                                      ),
                                      vertical: BorderSide(
                                        width: 2,
                                        color: pageId == index
                                            ? Colors.white
                                            : Colors.transparent,
                                      ))),
                              height: 50,
                              width: pageId == index ? 50 : 45,
                              child: CachedNetworkImage(
                                alignment: Alignment.center,
                                cacheKey: imageUrl,
                                progressIndicatorBuilder:
                                    (context, url, progress) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.black87,
                                        value: progress.downloaded.toDouble()),
                                  );
                                },
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
