// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:together_version_2/pages/feed_page/add_post_page/image_list_widget.dart';
import 'package:together_version_2/pages/feed_page/add_post_page/text_field_widget.dart';
import 'package:together_version_2/pages/feed_page/add_post_page/video_list_widget.dart';
import 'package:together_version_2/providers/add_post_provider.dart';
import 'package:together_version_2/services/feed_services.dart';
import 'package:together_version_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class AddFeedPage extends StatelessWidget {
  const AddFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    log("Build again");

    return WillPopScope(
      onWillPop: () async {
        final result = await context.read<AddPostProvider>().clearLists();
        return result;
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          title: const Text("Add Post"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFieldWidget(),
                      SizedBox(height: 20),
                      ImageListWidget(),
                      SizedBox(height: 20),
                      VideoListWidget(),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      context.read<AddPostProvider>().pickImagesList();
                    },
                    icon: const Icon(
                      Iconsax.gallery_add5,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<AddPostProvider>().pickVideosList();
                    },
                    icon: const Icon(
                      Iconsax.video_add5,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Offstage(
          offstage: (context.watch<AddPostProvider>().imageFileList.isEmpty &&
                  context.watch<AddPostProvider>().videoFileList.isEmpty) ||
              context.watch<AddPostProvider>().postText.isEmpty,
          child: FloatingActionButton(
            backgroundColor: Colors.black87,
            child: context.read<AddPostProvider>().isPosting
                ? LoadingAnimationWidget.hexagonDots(
                    color: Colors.white, size: 20)
                : const Icon(Icons.check, color: Colors.white),
            onPressed: () async {
              context.read<AddPostProvider>().startPosting();
              //
              await FeedServices.createPostWithImages(
                context.read<AddPostProvider>().videoFileList,
                context.read<AddPostProvider>().imageFileList,
                context.read<AddPostProvider>().postText,
                context,
              );

              //
              Utils.loadSound('sound/comment.wav');
              context.read<AddPostProvider>().stopPosting();
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
