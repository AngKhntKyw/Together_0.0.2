import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/services/feed_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final fireStore = FirebaseFirestore.instance;
  final postTextController = TextEditingController();
  File? imageFile;
  bool isImagePicked = false;
  bool isPosting = false;
  final fireAuth = FirebaseAuth.instance;

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
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                height: 50,
                width: double.infinity,
                child: Row(
                  children: [
                    CircleAvatar(
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
                          hintText: "What's on your mind today?",
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
                        ? InkWell(
                            onTap: () async {
                              imageFile = await FeedServices.getImage();
                              setState(() {
                                isImagePicked = true;
                              });
                            },
                            child: Image.file(imageFile!))
                        : const SizedBox(),
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
            await FeedServices.createPost(
                imageFile!, postTextController.text, context);

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
