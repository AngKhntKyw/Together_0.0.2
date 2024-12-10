import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/pages/feed_page/add_post_page/text_field_widget.dart';
import 'package:together_version_2/pages/feed_page/add_post_page/video_widget.dart';
import 'package:together_version_2/providers/add_post_provider.dart';
import 'package:together_version_2/services/feed_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class AddPostWithImagePage extends StatefulWidget {
  const AddPostWithImagePage({super.key});

  @override
  State<AddPostWithImagePage> createState() => _AddPostWithImagePageState();
}

class _AddPostWithImagePageState extends State<AddPostWithImagePage> {
  final fireStore = FirebaseFirestore.instance;
  final postTextController = TextEditingController();

  List<File> imageFile = [];
  List<File> videoFile = [];
  bool isImagePicked = false;
  bool isVideoPicked = false;
  bool isPosting = false;
  final fireAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    postTextController.dispose();
    imageFile.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: const Text("Add Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: LoadingAnimationWidget.hexagonDots(
                                  color: Colors.black87, size: 20),
                              radius: 25,
                              foregroundImage: CachedNetworkImageProvider(
                                fireAuth.currentUser!.photoURL!,
                                cacheKey: fireAuth.currentUser!.photoURL,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  fireAuth.currentUser!.displayName!,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  fireAuth.currentUser!.email!,
                                  style: TextStyle(fontSize: 12),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFieldWidget(
                          // postTextController: postTextController,
                          ),
                    ),
                    isImagePicked
                        ? Flexible(
                            child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: imageFile.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () async {
                                    imageFile =
                                        (await FeedServices.getImageList())!;
                                    setState(() {
                                      isImagePicked = true;
                                    });
                                  },
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Image.file(
                                        imageFile[index],
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              imageFile
                                                  .remove(imageFile[index]);
                                              log("Left images : ${imageFile.length}");
                                              imageFile.length == 0
                                                  ? isImagePicked = false
                                                  : null;
                                            });
                                          },
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.black,
                                            child: Icon(
                                              Iconsax.close_circle5,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider(
                                  color: Colors.transparent,
                                );
                              },
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(height: 10),

                    // video List
                    isVideoPicked
                        ? Flexible(
                            child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: videoFile.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () async {
                                    videoFile =
                                        (await FeedServices.getVideoList())!;
                                    setState(() {
                                      isVideoPicked = true;
                                    });
                                  },
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      VideoWidget(
                                          videoUrl: videoFile[index].path,
                                          videoList: [],
                                          initialIndex: 0),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              videoFile
                                                  .remove(videoFile[index]);
                                              log("Left images : ${videoFile.length}");
                                              videoFile.length == 0
                                                  ? isVideoPicked = false
                                                  : null;
                                            });
                                          },
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.black,
                                            child: Icon(
                                              Iconsax.close_circle5,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider(
                                  color: Colors.transparent,
                                );
                              },
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    imageFile = (await FeedServices.getImageList())!;
                    setState(() {
                      isImagePicked = true;
                    });
                  },
                  icon: const Icon(
                    Iconsax.gallery_add5,
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    videoFile = (await FeedServices.getVideoList())!;
                    setState(() {
                      isVideoPicked = true;
                    });
                  },
                  icon: const Icon(
                    Iconsax.video_add5,
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      //
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Offstage(
        offstage: (!isImagePicked && !isVideoPicked) ||
            context.watch<AddPostProvider>().postText.isEmpty,
        child: FloatingActionButton(
          backgroundColor: Colors.black87,
          child: isPosting
              ? LoadingAnimationWidget.hexagonDots(
                  color: Colors.white, size: 20)
              : const Icon(Icons.check, color: Colors.white),
          onPressed: () async {
            setState(() {
              isPosting = true;
            });

            //
            await FeedServices.createPostWithImages(
                videoFile, imageFile, postTextController.text, context);

            //

            setState(() {
              isPosting = false;
            });
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
