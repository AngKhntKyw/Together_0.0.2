import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/services/feed_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:together_version_2/pages/feed_page/add_post_page/video_widget.dart';

class EditPostWithImagesPage extends StatefulWidget {
  final String postText;
  final List<String> oldImageStringList;
  final List<String> oldVideoStringList;
  final String postId;
  const EditPostWithImagesPage({
    super.key,
    required this.postId,
    required this.oldImageStringList,
    required this.oldVideoStringList,
    required this.postText,
  });

  @override
  State<EditPostWithImagesPage> createState() => _EditPostWithImagesPageState();
}

class _EditPostWithImagesPageState extends State<EditPostWithImagesPage> {
  final fireStore = FirebaseFirestore.instance;
  final postTextController = TextEditingController();
  List<File>? imageFile;
  List<File>? videoFile;
  bool isImagePicked = true;
  bool isVideoPicked = true;
  bool isPosting = false;
  final fireAuth = FirebaseAuth.instance;

  @override
  void initState() {
    postTextController.text = widget.postText;
    super.initState();
  }

  @override
  void dispose() {
    postTextController.dispose();
    imageFile != null ? imageFile!.clear() : null;
    videoFile != null ? videoFile!.clear() : null;
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        expands: false,
                        controller: postTextController,
                        obscureText: false,
                        maxLines: null,
                        minLines: null,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200)),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          filled: true,
                          fillColor: Colors.grey[200],
                          hintText: "What's on your mind tody?",
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        onChanged: (value) {
                          setState(() {
                            postTextController.text = value;
                          });
                        },
                      ),
                    ),
                    isImagePicked && imageFile != null
                        ? Flexible(
                            child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: imageFile!.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () async {
                                    imageFile =
                                        await FeedServices.getImageList();
                                    setState(() {
                                      isImagePicked = true;
                                    });
                                  },
                                  child: Image.file(
                                    imageFile![index],
                                    fit: BoxFit.cover,
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
                        : Flexible(
                            child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: widget.oldImageStringList.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () async {
                                    imageFile =
                                        await FeedServices.getImageList();
                                    setState(() {
                                      isImagePicked = true;
                                    });
                                  },
                                  child: CachedNetworkImage(
                                    cacheKey: widget.oldImageStringList[index],
                                    imageUrl: widget.oldImageStringList[index],
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
                          ),
                    const SizedBox(height: 10),

                    // video
                    isVideoPicked && videoFile != null
                        ? Flexible(
                            child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: videoFile!.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () async {
                                    videoFile =
                                        await FeedServices.getVideoList();
                                    setState(() {
                                      isVideoPicked = true;
                                    });
                                  },
                                  child: VideoWidget(
                                      videoUrl: videoFile![index].path,
                                      videoList: [],
                                      initialIndex: 0),
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
                        : Flexible(
                            child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: widget.oldVideoStringList.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () async {
                                    videoFile =
                                        await FeedServices.getVideoList();
                                    setState(() {
                                      isVideoPicked = true;
                                    });
                                  },
                                  child: VideoWidget(
                                      videoUrl:
                                          widget.oldVideoStringList[index],
                                      videoList: [],
                                      initialIndex: 0),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider(
                                  color: Colors.transparent,
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    imageFile = await FeedServices.getImageList();
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
        offstage: !isImagePicked || postTextController.text.isEmpty,
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
            // imageFile != null
            // ? await FeedServices.editPostWithImages(widget.postId,
            //     imageFile!, postTextController.text, null, context)

            // //
            // : await FeedServices.editPostWithImages(
            //     widget.postId,
            //     null,
            //     postTextController.text,
            //     widget.oldImageStringList,
            //     context);

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
