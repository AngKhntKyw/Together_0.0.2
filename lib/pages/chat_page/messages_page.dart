import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/pages/chat_page/video_messages_page.dart';
import 'package:together_version_2/pages/chat_detail_page/view_media_page/view_images_list_in_chat_history.dart';
import 'package:together_version_2/services/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MessagesPage extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> map;
  final String chatRoomId;
  final Color color;
  const MessagesPage({
    super.key,
    required this.map,
    required this.chatRoomId,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fireAuth = FirebaseAuth.instance;
    final size = MediaQuery.sizeOf(context);
    log(color.toString());

    return map['type'] == 'video'
        ? Container(
            height: size.height / 3.5,
            width: size.width,
            // color: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            alignment: map['sendBy'] == fireAuth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              alignment: map['message'] != "" ? null : Alignment.center,
              height: size.height / 2.5,
              width: size.width / 2.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                border: Border.all(),
                color: Colors.white,
              ),
              child: map['message'] != ""
                  ? Stack(
                      children: [
                        VideoMessages(videoUrl: map['message']),
                      ],
                    )
                  : LoadingAnimationWidget.hexagonDots(
                      color: Colors.black87, size: 20),
            ),
          )
        : map['type'] == 'emoji'
            ? Container(
                width: size.width,
                alignment: map['sendBy'] == fireAuth.currentUser!.displayName
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.transparent,
                  ),
                  child: Text(
                    map['message'],
                    style: const TextStyle(color: Colors.white, fontSize: 28),
                  ),
                ),
              )
            : map['type'] == 'text'
                ? Container(
                    width: size.width,
                    alignment:
                        map['sendBy'] == fireAuth.currentUser!.displayName
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color:
                            map['sendBy'] == fireAuth.currentUser!.displayName
                                ? color
                                : color.withOpacity(0.1),
                        border: Border.all(color: color),
                      ),
                      child: Text(
                        map['message'],
                        style: TextStyle(
                          color:
                              map['sendBy'] == fireAuth.currentUser!.displayName
                                  ? color == const Color(0xfffafafa)
                                      ? Colors.black
                                      : Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: size.height / 3.5,
                    width: size.width,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    alignment:
                        map['sendBy'] == fireAuth.currentUser!.displayName
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        int initialId = 0;
                        ChatServices.getPhotosInChat(chatRoomId, context)
                            .then((imagesList) {
                          for (int i = 0; i < imagesList!.length; i++) {
                            if (imagesList[i]['message'] == map['message']) {
                              initialId = i;
                            }
                          }

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewImagesListPage(
                                        images: imagesList,
                                        id: initialId,
                                      )));
                        });
                      },
                      child: Hero(
                        tag: map['message'],
                        child: Container(
                          alignment:
                              map['message'] != "" ? null : Alignment.center,
                          height: size.height / 2.5,
                          width: size.width / 2.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(),
                          ),
                          child: map['message'] != ""
                              ? CachedNetworkImage(
                                  cacheKey: map['message'],
                                  fit: BoxFit.cover,
                                  imageUrl: map['message'],
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 60, vertical: 93),
                                    child: CircularProgressIndicator(
                                        color: Colors.black87,
                                        value: downloadProgress.progress),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )
                              : LoadingAnimationWidget.hexagonDots(
                                  color: Colors.black87, size: 20),
                        ),
                      ),
                    ),
                  );
  }
}
