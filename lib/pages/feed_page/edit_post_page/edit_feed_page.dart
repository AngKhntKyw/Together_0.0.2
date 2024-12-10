import 'dart:developer';
import 'package:together_version_2/pages/feed_page/edit_post_page/new_video_list_widget.dart';
import 'package:together_version_2/pages/feed_page/edit_post_page/old_image_list_widget.dart';
import 'package:together_version_2/pages/feed_page/edit_post_page/new_image_list_widget.dart';
import 'package:together_version_2/pages/feed_page/edit_post_page/old_video_list_widget.dart';
import 'package:together_version_2/pages/feed_page/edit_post_page/text_field_widget.dart';
import 'package:together_version_2/providers/edit_post_provider.dart';
import 'package:together_version_2/services/feed_services.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class EditFeedPage extends StatefulWidget {
  final String postText;
  final List<String> oldImageStringList;
  final List<String> oldVideoStringList;
  final String postId;
  const EditFeedPage({
    super.key,
    required this.postId,
    required this.oldImageStringList,
    required this.oldVideoStringList,
    required this.postText,
  });

  @override
  State<EditFeedPage> createState() => _EditFeedPageState();
}

class _EditFeedPageState extends State<EditFeedPage> {
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() {
    context.read<EditPostProvider>().typePostText(widget.postText);

    for (String image in widget.oldImageStringList) {
      context.read<EditPostProvider>().oldImageStringList.add(image);
    }
    for (String video in widget.oldVideoStringList) {
      context.read<EditPostProvider>().oldVideoStringList.add(video);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postTextController = TextEditingController();
    postTextController.text = context.watch<EditPostProvider>().postText;

    log("Build again");

    return WillPopScope(
      onWillPop: () async {
        final result = await context.read<EditPostProvider>().clearLists();
        return result;
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          title: const Text("Edit Post"),
        ),
        body: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFieldWidget(
                    postTextController: postTextController,
                    text: widget.postText,
                  ),

                  //
                  const SizedBox(height: 20),
                  context.watch<EditPostProvider>().imageFileList.isEmpty
                      ? const OldImageListWidget()
                      : NewImageListWidget(),

                  //
                  const SizedBox(height: 20),

                  context.watch<EditPostProvider>().videoFileList.isEmpty
                      ? const OldVideoListWidget()
                      : NewVideoListWidget(),
                ],
              ),
            )),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<EditPostProvider>().pickImagesList();
                  },
                  icon: Icon(
                    Iconsax.gallery_add5,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    context.read<EditPostProvider>().pickVideosList();
                  },
                  icon: Icon(
                    Iconsax.video_add5,
                  ),
                ),
              ],
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Offstage(
          offstage: ((context.watch<EditPostProvider>().imageFileList.isEmpty &&
                      context
                          .watch<EditPostProvider>()
                          .videoFileList
                          .isEmpty) &&
                  (context
                          .watch<EditPostProvider>()
                          .oldImageStringList
                          .isEmpty &&
                      context
                          .watch<EditPostProvider>()
                          .oldVideoStringList
                          .isEmpty)) ||
              context.watch<EditPostProvider>().postText.isEmpty,
          child: FloatingActionButton(
            backgroundColor: Colors.black87,
            child: context.read<EditPostProvider>().isPosting
                ? LoadingAnimationWidget.hexagonDots(
                    color: Colors.white, size: 20)
                : const Icon(Icons.check, color: Colors.white),
            onPressed: () async {
              context.read<EditPostProvider>().startPosting();

              await FeedServices.editPostWithImages(
                widget.postId,
                context.read<EditPostProvider>().postText,
                context.read<EditPostProvider>().imageFileList,
                context.read<EditPostProvider>().oldImageStringList,
                context.read<EditPostProvider>().videoFileList,
                context.read<EditPostProvider>().oldVideoStringList,
                context,
              );
              //

              context.read<EditPostProvider>().stopPosting();
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
