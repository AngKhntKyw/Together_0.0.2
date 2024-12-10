import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/pages/chat_detail_page/view_media_page/view_images_list_in_chat_history.dart';
import 'package:together_version_2/pages/chat_detail_page/view_media_page/view_videos_list_in_chat_history.dart';
import 'package:together_version_2/services/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MediasInChatHistoryPage extends StatelessWidget {
  final String chatRoomId;
  const MediasInChatHistoryPage({super.key, required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    final fireStore = FirebaseFirestore.instance;
    final size = MediaQuery.sizeOf(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Media'),
          bottom: const TabBar(
            indicatorColor: Colors.black87,
            labelColor: Colors.black87,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 4,
            tabs: [
              Tab(text: 'Images'),
              Tab(text: 'Videos'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            StreamBuilder(
              stream: fireStore
                  .collection('chatroom')
                  .doc(chatRoomId)
                  .collection('chats')
                  .where('type', isEqualTo: 'image')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.hexagonDots(
                        color: Colors.black87, size: 20),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error : ${snapshot.error}"),
                  );
                }
                final imageList = snapshot.data!.docs;
                imageList.sort(
                  (a, b) => b['time'].compareTo(a['time']),
                );

                return GridView.builder(
                  itemCount: imageList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemBuilder: (context, index) {
                    final imageUrl = imageList[index]['message'];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewImagesListPage(
                                images: imageList,
                                id: index,
                              ),
                            ));
                      },
                      child: CachedNetworkImage(
                        cacheKey: imageUrl,
                        progressIndicatorBuilder: (context, url, progress) {
                          return Center(
                            child: CircularProgressIndicator(
                                color: Colors.black87,
                                value: progress.downloaded.toDouble()),
                          );
                        },
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              },
            ),

            // Videos View
            StreamBuilder(
              stream: fireStore
                  .collection('chatroom')
                  .doc(chatRoomId)
                  .collection('chats')
                  .where('type', isEqualTo: 'video')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.hexagonDots(
                        color: Colors.black87, size: 20),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error : ${snapshot.error}"),
                  );
                }
                final videoList = snapshot.data!.docs;
                videoList.sort(
                  (a, b) => b['time'].compareTo(a['time']),
                );

                return GridView.builder(
                  itemCount: videoList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemBuilder: (context, index) {
                    String videoUrl = videoList[index]['message'];
                    return InkWell(
                      onTap: () {
                        log("Tap Tap");
                      },
                      child: FutureBuilder(
                        future: ChatServices.getThumbnail(videoUrl),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: LoadingAnimationWidget.hexagonDots(
                                  color: Colors.black87, size: 20),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text("${snapshot.error}"),
                            );
                          }
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: size.height / 2.5,
                                width: size.width / 2.5,
                                child: Image.memory(
                                  cacheHeight: 800,
                                  cacheWidth: 800,
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ViewVideosInChatHistory(
                                          videoList: videoList,
                                          initialIndex: index,
                                        ),
                                      ));
                                },
                                icon: const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
