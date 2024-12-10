import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/pages/chat_page/chat_page.dart';
import 'package:together_version_2/services/auth_services.dart';
import 'package:together_version_2/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authServices = AuthServices();
  final fireStore = FirebaseFirestore.instance;
  final fireAuth = FirebaseAuth.instance;

  Map<String, dynamic>? userMap;
  List<Map<String, dynamic>?> userMaps = [];
  bool isLoading = false;
  final searchController = TextEditingController();

  void onSearch() async {
    setState(() {
      isLoading = true;
    });
    try {
      await fireStore
          .collection("users")
          .where("email", isEqualTo: searchController.text)
          .get()
          .then((value) {
        setState(() {
          isLoading = false;
          userMap = value.docs[0].data();
        });
        log(userMap.toString());
      });
    } catch (e) {
      log("On Search error : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void getUserMaps() async {
    setState(() {
      isLoading = true;
    });
    try {
      await fireStore
          .collection("users")
          .where("uid", isNotEqualTo: fireAuth.currentUser!.uid)
          .get()
          .then((value) {
        setState(() {
          isLoading = false;
          for (var element in value.docs) {
            userMaps.add(element.data());
          }
        });
      });
    } catch (e) {
      log("get UserMaps error : $e");
      setState(() {
        isLoading = false;
      });
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
    checkChatInfos(chatRoomId);
    return chatRoomId;
  }

  @override
  void initState() {
    getUserMaps();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: Colors.black87, size: 20),
            )
          : Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 200,
                      color: Colors.red,
                      child: const Text(
                        'as',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        addSemanticIndexes: false,
                        itemCount: userMaps.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                              onTap: () {
                                String chatRoomId = getChatRoomId(
                                    fireAuth.currentUser!.uid,
                                    userMaps[index]!['uid']);

                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    fullscreenDialog: true,
                                    maintainStateData: true,
                                    child: ChatPage(
                                      chatRoomId: chatRoomId,
                                      userMap: userMaps[index]!,
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
                                        cacheKey:
                                            userMaps[index]!['profileImage'],
                                        userMaps[index]!['profileImage']),
                                    child: LoadingAnimationWidget.hexagonDots(
                                        color: Colors.black87, size: 20),
                                  ),
                                  userMaps[index]!['isOnline']
                                      ? const CircleAvatar(
                                          radius: 5,
                                          backgroundColor: Colors.green,
                                        )
                                      : const SizedBox()
                                ],
                              ),
                              title: Text(
                                userMaps[index]!['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(userMaps[index]!['email']),
                              trailing: Text(userMaps[index]!['isOnline']
                                  ? "active now"
                                  : Utils.changeIntoTimeAgo(
                                      userMaps[index]!['lastOnline'])));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
