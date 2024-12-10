import 'package:together_version_2/pages/chat_page/messages_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MessagesListPage extends StatelessWidget {
  final String chatRoomId;
  final Color color;
  const MessagesListPage(
      {super.key, required this.chatRoomId, required this.color});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fireStore = FirebaseFirestore.instance;

    return Expanded(
      child: SizedBox(
        width: size.width,
        child: StreamBuilder<QuerySnapshot>(
          stream: fireStore
              .collection('chatroom')
              .doc(chatRoomId)
              .collection('chats')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: LoadingAnimationWidget.hexagonDots(
                      color: Colors.black87, size: 20));
            } else if (snapshot.data != null) {
              return ListView.builder(
                reverse: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return MessagesPage(
                    map: snapshot.data!.docs[index],
                    chatRoomId: chatRoomId,
                    color: color,
                  );
                },
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
