import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/services/feed_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditPostPage extends StatefulWidget {
  final String postText;
  final String imageUrl;
  final String postId;
  const EditPostPage({
    super.key,
    required this.postText,
    required this.imageUrl,
    required this.postId,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final fireStore = FirebaseFirestore.instance;
  final postTextController = TextEditingController();
  File? imageFile;
  bool isImagePicked = false;
  bool isPosting = false;

  @override
  void initState() {
    postTextController.text = widget.postText;

    super.initState();
  }

  @override
  void dispose() {
    postTextController.dispose();
    imageFile != null ? imageFile!.delete() : null;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
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
                          hintText: "I'm feeling .......",
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    isImagePicked && imageFile != null
                        ? InkWell(
                            onTap: () async {
                              imageFile = await FeedServices.getImage();
                              setState(() {
                                isImagePicked = true;
                              });
                            },
                            child: Image.file(imageFile!))
                        : InkWell(
                            onTap: () async {
                              imageFile = await FeedServices.getImage();
                              setState(() {
                                isImagePicked = true;
                              });
                            },
                            child: CachedNetworkImage(
                              cacheKey: widget.imageUrl,
                              imageUrl: widget.imageUrl,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                imageFile = await FeedServices.getImage();
                setState(() {
                  isImagePicked = true;
                });
              },
              icon: const Icon(
                Iconsax.gallery_add5,
                size: 30,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        child: isPosting
            ? LoadingAnimationWidget.hexagonDots(color: Colors.white, size: 20)
            : const Icon(Icons.check, color: Colors.white),
        onPressed: () async {
          setState(() {
            isPosting = true;
          });

          //
          imageFile != null
              ? await FeedServices.editPost(widget.postId, imageFile,
                  postTextController.text, null, context)

              //
              : await FeedServices.editPost(widget.postId, null,
                  postTextController.text, widget.imageUrl, context);
          //

          setState(() {
            isPosting = false;
          });
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        },
      ),
    );
  }
}
