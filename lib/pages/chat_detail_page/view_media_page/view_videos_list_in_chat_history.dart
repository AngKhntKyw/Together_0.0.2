// import 'dart:developer';
// import 'package:better_player_plus/better_player_plus.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class ViewVideosInChatHistory extends StatefulWidget {
//   final List<QueryDocumentSnapshot<Map<String, dynamic>>> videoList;
//   final int initialIndex;
//   const ViewVideosInChatHistory({
//     super.key,
//     required this.videoList,
//     required this.initialIndex,
//   });

//   @override
//   State<ViewVideosInChatHistory> createState() =>
//       _ViewVideosInChatHistoryState();
// }

// class _ViewVideosInChatHistoryState extends State<ViewVideosInChatHistory> {
//   //
//   List<BetterPlayerDataSource> betterPlayerPlayListDataSource = [];
//   late BetterPlayerPlaylistController betterPlayerPlayListController;
//   late BetterPlayerConfiguration betterPlayerConfiguration;
//   late BetterPlayerPlaylistConfiguration betterPlayerPlaylistConfiguration;

//   final GlobalKey<BetterPlayerPlaylistState> betterPlayerPlaylistStateKey =
//       GlobalKey();

//   @override
//   void initState() {
//     //
//     widget.videoList.map((e) {
//       betterPlayerPlayListDataSource.add(
//         BetterPlayerDataSource(
//           BetterPlayerDataSourceType.network,
//           e['message'],
//           cacheConfiguration: const BetterPlayerCacheConfiguration(
//             useCache: true,
//             maxCacheFileSize: 1024 * 1024 * 100,
//             maxCacheSize: 1024 * 1024 * 100,
//             preCacheSize: 1024 * 1024 * 10,
//           ),
//         ),
//       );
//     }).toList();

//     betterPlayerPlayListController =
//         BetterPlayerPlaylistController(betterPlayerPlayListDataSource);

//     betterPlayerConfiguration = BetterPlayerConfiguration(
//       autoPlay: true,
//       looping: false,
//       // overlay: PlayerControls(
//       //   playListKey: betterPlayerPlaylistStateKey,
//       //   dataSourceList: betterPlayerPlayListDataSource,
//       // ),
//       controlsConfiguration: const BetterPlayerControlsConfiguration(
//         enableSkips: true,
//         // skipForwardIcon: Icons.skip_next_rounded,
//         forwardSkipTimeInMilliseconds:
//             BetterPlayerBufferingConfiguration.defaultMaxBufferMs,
//         // skipBackIcon: Icons.skip_previous_rounded,
//         backwardSkipTimeInMilliseconds:
//             BetterPlayerBufferingConfiguration.defaultMinBufferMs,
//         showControls: true,
//         enableProgressText: true,
//         controlsHideTime: Duration(milliseconds: 10),
//         showControlsOnInitialize: false,
//       ),
//       autoDetectFullscreenAspectRatio: true,
//       autoDetectFullscreenDeviceOrientation: true,
//       fullScreenByDefault: false,
//       deviceOrientationsAfterFullScreen: [
//         DeviceOrientation.landscapeLeft,
//         DeviceOrientation.landscapeRight,
//         DeviceOrientation.portraitDown,
//         DeviceOrientation.portraitUp,
//       ],
//       fit: BoxFit.contain,
//       eventListener: (p0) {},
//     );

//     betterPlayerPlaylistConfiguration = BetterPlayerPlaylistConfiguration(
//       initialStartIndex: widget.initialIndex,
//       nextVideoDelay: const Duration(milliseconds: 3000),
//       loopVideos: false,
//     );

//     super.initState();
//   }

//   @override
//   void dispose() {
//     betterPlayerPlayListDataSource.clear();
//     betterPlayerPlayListController.dispose();
//     betterPlayerPlayListController.betterPlayerController!.clearCache();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black87,
//       body: Center(
//         child: AspectRatio(
//           aspectRatio: 16 / 9,
//           child: BetterPlayerPlaylist(
//             key: betterPlayerPlaylistStateKey,
//             betterPlayerDataSourceList: betterPlayerPlayListDataSource,
//             betterPlayerConfiguration: betterPlayerConfiguration,
//             betterPlayerPlaylistConfiguration:
//                 betterPlayerPlaylistConfiguration,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:better_player_plus/better_player_plus.dart';
import 'package:together_version_2/pages/chat_detail_page/view_media_page/video_thumbnails.dart';
import 'package:together_version_2/pages/chat_page/play_video_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewVideosInChatHistory extends StatefulWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> videoList;
  final int initialIndex;
  const ViewVideosInChatHistory({
    super.key,
    required this.videoList,
    required this.initialIndex,
  });

  @override
  State<ViewVideosInChatHistory> createState() =>
      _ViewVideosInChatHistoryState();
}

class _ViewVideosInChatHistoryState extends State<ViewVideosInChatHistory> {
  late PageController pageController;
  late BetterPlayerController betterPlayerController;
  late BetterPlayerDataSource dataSource;
  late int currentIndex;
  bool showButtons = false;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: currentIndex);

    //
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    betterPlayerController.clearCache();
    betterPlayerController.dispose(forceDispose: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.black87,
      body: InkWell(
        onTap: () {
          setState(() {
            showButtons ? showButtons = false : showButtons = true;
          });
        },
        child: Stack(
          children: [
            PageView.builder(
              physics: const BouncingScrollPhysics(),
              controller: pageController,
              onPageChanged: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              itemCount: widget.videoList.length,
              itemBuilder: (context, index) {
                final videoUrl = widget.videoList[index]['message'];
                return PlayVideoPage(videoUrl: videoUrl);
              },
            ),

            Offstage(
              offstage: !showButtons,
              child: SafeArea(
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
                              onPressed: () {},
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ))
                        ],
                      )),
                ),
              ),
            ),

            //
            Positioned(
              bottom: 0,
              child: Offstage(
                offstage: !showButtons,
                child: Container(
                  height: 50,
                  width: size.width,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.videoList.length,
                    itemBuilder: (context, index) {
                      final videoUrl = widget.videoList[index]['message'];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            pageController.animateToPage(index,
                                duration: const Duration(milliseconds: 1),
                                curve: Curves.linear);
                          });
                        },
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: VideoThumbNails(
                              videoUrl: videoUrl,
                              index: index,
                              currentIndex: currentIndex),
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
    );
  }
}
