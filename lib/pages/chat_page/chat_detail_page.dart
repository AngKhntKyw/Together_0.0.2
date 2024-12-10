import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/pages/chat_detail_page/view_media_page/medias_in_chat_history_page.dart';
import 'package:together_version_2/pages/chat_page/chat_page.dart';
import 'package:together_version_2/pages/user_profile_page.dart';
import 'package:together_version_2/pages/view_image.dart';
import 'package:together_version_2/services/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dash_bubble/dash_bubble.dart';

class ChatDetailPage extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;
  const ChatDetailPage(
      {super.key, required this.userMap, required this.chatRoomId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

final fireStore = FirebaseFirestore.instance;
bool isLoading = false;
late int theme;
late int updatedColor;
late String chatInfoId;
late String emoji;

class _ChatDetailPageState extends State<ChatDetailPage> {
  void deleteConversation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await ChatServices.deleteConversation(widget.chatRoomId, context);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void getChatInfos() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot<Map<String, dynamic>> result = await fireStore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chat_infos')
        .get();

    setState(() {
      theme = result.docs[0]['theme'];
      emoji = result.docs[0]['quick_react'];
      chatInfoId = result.docs.first.id;
      isLoading = false;
    });
  }

  @override
  void initState() {
    getChatInfos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail"),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: LoadingAnimationWidget.hexagonDots(
                  color: Colors.white, size: 20))
          : StreamBuilder(
              stream: fireStore
                  .collection('users')
                  .doc(widget.userMap['uid'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: LoadingAnimationWidget.hexagonDots(
                          color: Colors.white, size: 20));
                } else if (snapshot.hasData) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfilePage(
                                    userId: widget.userMap['uid']),
                              ));
                        },
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.black),
                          height: size.height / 4,
                          width: size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViewImage(
                                          imageUrl:
                                              snapshot.data!['profileImage'],
                                        ),
                                      )),
                                  child: Hero(
                                    tag: snapshot.data!['profileImage'],
                                    child: CircleAvatar(
                                      radius: 44,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                          radius: 42,
                                          backgroundColor: Colors.black87,
                                          child: Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: Colors.white,
                                                child: LoadingAnimationWidget
                                                    .hexagonDots(
                                                        color: Colors.black87,
                                                        size: 20),
                                                radius: 40,
                                                foregroundImage:
                                                    CachedNetworkImageProvider(
                                                        cacheKey:
                                                            snapshot.data![
                                                                'profileImage'],
                                                        snapshot.data![
                                                            'profileImage']),
                                              ),
                                              Offstage(
                                                offstage:
                                                    !snapshot.data!['isOnline'],
                                                child: const CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: Colors.white,
                                                  child: CircleAvatar(
                                                    radius: 8,
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                ),
                                              )
                                            ],
                                          )),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 40),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data!['name'],
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      snapshot.data!['email'],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MediasInChatHistoryPage(
                                      chatRoomId: widget.chatRoomId)));
                        },
                        leading:
                            const Icon(Iconsax.gallery5, color: Colors.black87),
                        title: const Text("view media"),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.black87, size: 20),
                      ),
                      ListTile(
                        onTap: () async {
                          await DashBubble.instance.hasOverlayPermission();

                          await DashBubble.instance.requestOverlayPermission();
                          await DashBubble.instance
                              .requestPostNotificationsPermission();

                          //
                          await DashBubble.instance.isRunning()
                              ? await DashBubble.instance.stopBubble()
                              : await DashBubble.instance.startBubble(
                                  bubbleOptions: BubbleOptions(
                                    bubbleSize: 60,
                                    distanceToClose: 60,
                                    enableAnimateToEdge: true,
                                    enableBottomShadow: true,
                                    keepAliveWhenAppExit: true,
                                    startLocationY: 10,
                                    startLocationX:
                                        MediaQuery.of(context).size.width - 60,
                                    closeBehavior: CloseBehavior.following,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                              userMap: widget.userMap,
                                              chatRoomId: widget.chatRoomId),
                                        ));
                                  },
                                );
                        },
                        leading: const Icon(Iconsax.message_circle5,
                            color: Colors.black87),
                        title: const Text("chat head"),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.black87, size: 20),
                      ),
                      ListTile(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            enableDrag: true,
                            showDragHandle: true,
                            builder: (context) {
                              return Container(
                                height: size.height / 2,
                                width: size.width,
                                decoration: const BoxDecoration(
                                    color: Colors.transparent),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: MaterialColorPicker(
                                        shrinkWrap: true,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
                                        alignment: WrapAlignment.start,
                                        allowShades: true,
                                        circleSize: 40,
                                        spacing: 20,
                                        onColorChange: (Color color) {
                                          setState(() {
                                            updatedColor = color.value;
                                          });
                                        },
                                        onMainColorChange: (value) {},
                                        selectedColor: Color(theme),
                                        onlyShadeSelection: true,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 20),
                                      child: InkWell(
                                        onTap: () {
                                          fireStore
                                              .collection('chatroom')
                                              .doc(widget.chatRoomId)
                                              .collection('chat_infos')
                                              .doc(chatInfoId)
                                              .update({"theme": updatedColor});
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: size.width,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: Colors.black87,
                                          ),
                                          child: const Text(
                                            "Save",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        leading: const Icon(Iconsax.paintbucket5,
                            color: Colors.black87),
                        title: const Text("theme"),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.black87, size: 20),
                      ),

                      ListTile(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            enableDrag: true,
                            showDragHandle: true,
                            builder: (context) {
                              return Container(
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                height: size.height / 2,
                                width: size.width,
                                decoration: const BoxDecoration(
                                    color: Colors.transparent),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: EmojiPicker(
                                          onEmojiSelected: (category, emoji) {
                                            log(emoji.emoji);
                                            fireStore
                                                .collection('chatroom')
                                                .doc(widget.chatRoomId)
                                                .collection('chat_infos')
                                                .doc(chatInfoId)
                                                .update({
                                              "quick_react": emoji.emoji
                                            });
                                            Navigator.pop(context);
                                          },
                                          config: const Config(
                                            emojiSizeMax: 30,
                                            columns: 6,
                                            verticalSpacing: 0,
                                            horizontalSpacing: 0,
                                            gridPadding: EdgeInsets.zero,
                                            initCategory: Category.RECENT,
                                            bgColor: Colors.transparent,
                                            indicatorColor: Color.fromARGB(
                                                221, 167, 99, 99),
                                            iconColor: Colors.grey,
                                            iconColorSelected: Colors.black87,
                                            backspaceColor: Colors.black87,
                                            skinToneDialogBgColor: Colors.white,
                                            skinToneIndicatorColor: Colors.grey,
                                            enableSkinTones: true,
                                            recentTabBehavior:
                                                RecentTabBehavior.RECENT,
                                            loadingIndicator: SizedBox.shrink(),
                                            tabIndicatorAnimDuration:
                                                kTabScrollDuration,
                                            categoryIcons: CategoryIcons(),
                                            buttonMode: ButtonMode.MATERIAL,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        leading: const Icon(Iconsax.emoji_normal5,
                            color: Colors.black87),
                        title: const Text("quick react"),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.black87, size: 20),
                      ),

                      //
                      ListTile(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                surfaceTintColor: Colors.white,
                                title: const Text(
                                  'Delete!',
                                  style: TextStyle(color: Colors.red),
                                ),
                                content: const Text(
                                    "Are you sure to delete this conversation?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'NO',
                                        style: TextStyle(color: Colors.black87),
                                      )),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        deleteConversation();
                                      },
                                      child: const Text(
                                        'YES',
                                        style: TextStyle(color: Colors.red),
                                      ))
                                ],
                              );
                            },
                          );
                        },
                        leading: const Icon(Iconsax.close_square5,
                            color: Colors.red),
                        title: const Text(
                          "delete conversation",
                          style: TextStyle(color: Colors.red),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.red, size: 20),
                      )
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
    );
  }
}
