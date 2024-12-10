import 'dart:developer';
import 'package:together_version_2/pages/chat_page/play_video_page.dart';
import 'package:flutter/material.dart';

class PlayVideoListPage extends StatefulWidget {
  final List<String> videoList;
  final int initialIndex;
  const PlayVideoListPage({
    super.key,
    required this.videoList,
    required this.initialIndex,
  });

  @override
  State<PlayVideoListPage> createState() => _PlayVideoListPageState();
}

class _PlayVideoListPageState extends State<PlayVideoListPage> {
  late PageController pageController;

  @override
  void initState() {
    pageController = PageController(initialPage: widget.initialIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: const ClampingScrollPhysics(),
        controller: pageController,
        onPageChanged: (value) {
          log("Change");
        },
        itemCount: widget.videoList.length,
        itemBuilder: (context, index) {
          final videoUrl = widget.videoList[index];
          return PlayVideoPage(videoUrl: videoUrl);
        },
      ),
    );
  }
}
