import 'package:together_version_2/pages/chat_page/chat_app_bar.dart';
import 'package:together_version_2/pages/chat_page/chat_inputs.dart';
import 'package:together_version_2/pages/chat_page/messages_list_page.dart';
import 'package:together_version_2/services/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatPage extends StatelessWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;
  const ChatPage({super.key, required this.userMap, required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    final fireStore = FirebaseFirestore.instance;
    final messageController = TextEditingController();
    final messageFocusNode = FocusNode();
    final size = MediaQuery.sizeOf(context);

    return StreamBuilder(
      stream: fireStore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chat_infos')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: Colors.black87, size: 20));
        } else if (snapshot.hasError) {
          return Center(
            child: Text("${snapshot.error}"),
          );
        } else if (snapshot.data!.docs.isEmpty) {
          fireStore
              .collection('chatroom')
              .doc(chatRoomId)
              .collection('chat_infos')
              .add({
            "theme": 0xfffafafa,
            "quick_react": "👍",
          });
          return Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: Colors.black87, size: 20));
        } else {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,

            // AppBar
            appBar: ChatAppBar(
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              userMap: userMap,
              chatRoomId: chatRoomId,
            ),

            //
            body: Column(
              children: [
                // MessagesList
                MessagesListPage(
                  chatRoomId: chatRoomId,
                  color: Color(snapshot.data!.docs.first['theme']),
                ),

                // ChatInputs
                ChatInputs(
                  messageController: messageController,
                  messageFocusNode: messageFocusNode,
                  onMessageSend: () => ChatServices.onMessageSend(
                      messageController,
                      chatRoomId,
                      context,
                      snapshot.data!.docs.first['quick_react']),
                  getImage: () => ChatServices.getImage(chatRoomId),
                  chatRoomId: chatRoomId,
                  size: size,
                  takePhoto: () => ChatServices.takePhoto(chatRoomId),
                  emoji: snapshot.data!.docs.first['quick_react'],
                ),
              ],
            ),
          );
        }
        // return Scaffold(
        //   body:
        // );
      },
    );
  }
}
