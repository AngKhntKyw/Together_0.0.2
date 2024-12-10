import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_story/flutter_story.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:together_version_2/pages/chat_page/add_status_page.dart';
import 'package:together_version_2/pages/chat_page/chat_detail_page.dart';
import 'package:together_version_2/pages/chat_page/chat_page.dart';
import 'package:together_version_2/providers/add_status_provider.dart';
import 'package:together_version_2/services/status_services.dart';
import 'package:together_version_2/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fireStore = FirebaseFirestore.instance;
    final fireAuth = FirebaseAuth.instance;
    final storyController = StoryController();
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // StatusList Widget
            SizedBox(
              height: 80,
              child: StreamBuilder(
                stream: StatusServices.getAllStatus(),
                builder: (context, streamSnapShot) {
                  if (streamSnapShot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                        child: LoadingAnimationWidget.hexagonDots(
                            color: Colors.black87, size: 20));
                  } else if (streamSnapShot.hasError) {
                    return Center(child: Text("${streamSnapShot.error}"));
                  } else if (streamSnapShot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("Fuck, No one adds story in my app."));
                  } else {
                    // StoryList View
                    return Story(
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
                      addSemanticIndexes: false,
                      controller: storyController,
                      shrinkWrap: true,
                      children: [
                        ...streamSnapShot.data!.docs.map(
                          (statusDataMap) {
                            List<dynamic> imageList =
                                statusDataMap.data()['imageList'];
                            List<String> stringImageList = [];

                            return StoryUser(
                              visitedBorderColor: Colors.blue,
                              height: 60,
                              width: 60,
                              avatarColor: Colors.white,
                              borderColor: Colors.green,
                              avatar: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    cacheKey: statusDataMap
                                        .data()['post_owner_profile'],
                                    statusDataMap.data()['post_owner_profile']),
                              ),
                              children: [
                                ...imageList.map(
                                  (imageListMap) {
                                    stringImageList.add(imageListMap['image']);
                                    return StoryCard(
                                      onVisited: (value) {
                                        context
                                            .read<AddStatusProvider>()
                                            .setCurrentStoryIndex(value);
                                      },
                                      color: Colors.black,
                                      footer: const StoryCardFooter(
                                        likeButton: StoryCardLikeButton(),
                                        forwardButton: StoryCardForwardButton(),
                                        messageBox: StoryCardMessageBox(),
                                      ),
                                      childOverlay: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                      width: size.width / 10),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        statusDataMap.data()[
                                                            'post_owner_name'],
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14),
                                                      ),
                                                      Text(
                                                        Utils.changeIntoTimeAgo(
                                                            imageListMap[
                                                                'createdAt']),
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          )),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Offstage(
                                              offstage: statusDataMap.data()[
                                                      'post_owner_uid'] !=
                                                  fireAuth.currentUser!.uid,
                                              child: IconButton(
                                                onPressed: () async {
                                                  log("Tap Tap");
                                                  Navigator.pop(context);
                                                  stringImageList.removeAt(context
                                                      .read<AddStatusProvider>()
                                                      .currentStoryIndex);

                                                  await StatusServices
                                                      .updateStatus(
                                                          context,
                                                          statusDataMap.data()[
                                                              'status_id'],
                                                          stringImageList);
                                                },
                                                icon: const Icon(Iconsax.trash,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          CachedNetworkImage(
                                            cacheKey: imageListMap['image'],
                                            imageUrl: imageListMap['image'],
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                LoadingAnimationWidget
                                                    .hexagonDots(
                                                        color: Colors.white,
                                                        size: 20),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );

                    // return ListView.builder(
                    //   scrollDirection: Axis.horizontal,
                    //   itemCount: streamSnapShot.data!.docs.length,
                    //   itemBuilder: (context, index) {
                    //     final statusData = streamSnapShot.data!.docs[index];

                    //     return Padding(
                    //       padding: const EdgeInsets.all(8),
                    //       child: InkWell(
                    //         onTap: () {
                    //           Navigator.push(
                    //             context,
                    //             PageTransition(
                    //               type: PageTransitionType.bottomToTop,
                    //               fullscreenDialog: true,
                    //               maintainStateData: true,
                    //               child: ViewStoryPage(
                    //                   initialIndex: index,
                    //                   statusDataList:
                    //                       streamSnapShot.data!.docs),
                    //               inheritTheme: true,
                    //               ctx: context,
                    //               matchingBuilder:
                    //                   const CupertinoPageTransitionsBuilder(),
                    //             ),
                    //           );
                    //         },
                    //         child: CircleAvatar(
                    //           radius: 29,
                    //           backgroundColor: Colors.green,
                    //           child: CircleAvatar(
                    //             radius: 27,
                    //             backgroundColor: Colors.white,
                    //             child: CircleAvatar(
                    //               radius: 25,
                    //               backgroundImage: CachedNetworkImageProvider(
                    //                 statusData.data()['post_owner_profile'],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // );
                  }
                },
              ),
            ),

            // ContactList widget
            FutureBuilder(
              future: fireStore
                  .collection("users")
                  .where("uid", isNotEqualTo: fireAuth.currentUser!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: LoadingAnimationWidget.hexagonDots(
                          color: Colors.black87, size: 20));
                } else if (snapshot.hasError) {
                  return Center(child: Text("${snapshot.error}"));
                } else if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("There is no user."),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    addSemanticIndexes: false,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> userMaps =
                          snapshot.data!.docs[index].data();

                      return ListTile(
                          onTap: () {
                            String chatRoomId = getChatRoomId(
                                fireAuth.currentUser!.uid, userMaps['uid']);

                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                fullscreenDialog: true,
                                maintainStateData: true,
                                child: ChatPage(
                                  chatRoomId: chatRoomId,
                                  userMap: userMaps,
                                ),
                                inheritTheme: true,
                                ctx: context,
                                matchingBuilder:
                                    const CupertinoPageTransitionsBuilder(),
                              ),
                            );
                          },
                          leading: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                foregroundImage: CachedNetworkImageProvider(
                                    cacheKey: userMaps['profileImage'],
                                    userMaps['profileImage']),
                                child: LoadingAnimationWidget.hexagonDots(
                                    color: Colors.black87, size: 20),
                              ),
                              userMaps['isOnline']
                                  ? const CircleAvatar(
                                      radius: 5,
                                      backgroundColor: Colors.green,
                                    )
                                  : const SizedBox()
                            ],
                          ),
                          title: Text(
                            userMaps['name'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(userMaps['email']),
                          trailing: Text(userMaps['isOnline']
                              ? "active now"
                              : Utils.changeIntoTimeAgo(
                                  userMaps['lastOnline'])));
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        child: const Icon(Iconsax.edit, color: Colors.white),
        onPressed: () async {
          File? image = await getImage();
          if (image != null) {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                fullscreenDialog: true,
                maintainStateData: true,
                child: AddStatusPage(image: image),
                inheritTheme: true,
                ctx: context,
                matchingBuilder: const CupertinoPageTransitionsBuilder(),
              ),
            );
          }
        },
      ),
    );
  }

  Future<File?> getImage() async {
    final imageXFile = await ImagePicker()
        .pickImage(requestFullMetadata: true, source: ImageSource.gallery);
    if (imageXFile != null) {
      return File(imageXFile.path);
    } else {
      return null;
    }
  }

  Future<void> checkChatInfos(String chatRoomId) async {
    QuerySnapshot<Map<String, dynamic>> result = await fireStore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chat_infos')
        .get();

    result.docs.isEmpty
        ? await fireStore
            .collection('chatroom')
            .doc(chatRoomId)
            .collection('chat_infos')
            .add({
            "theme": 0xfffafafa,
            "quick_react": "👍",
          })
        : null;
  }

  String getChatRoomId(String myUserId, String otherUserId) {
    List<String> userIds = [myUserId, otherUserId];
    userIds.sort();
    String chatRoomId = userIds.join("_");
    // checkChatInfos(chatRoomId);
    return chatRoomId;
  }
}
