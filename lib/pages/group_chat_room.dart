import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/pages/group_info_page.dart';
import 'package:together_version_2/pages/view_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:uuid/uuid.dart';

class GroupChatRoom extends StatefulWidget {
  final String groupChatId;
  final String groupName;
  const GroupChatRoom(
      {super.key, required this.groupChatId, required this.groupName});

  @override
  State<GroupChatRoom> createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  final messageController = TextEditingController();
  final fireStore = FirebaseFirestore.instance;
  final fireAuth = FirebaseAuth.instance;
  final fireStorage = FirebaseStorage.instance;

  File? imageFile;
  int status = 1;

  void onMessage() async {
    if (messageController.text.isNotEmpty) {
      log("Thi");
      Map<String, dynamic> chatData = {
        "sendBy": fireAuth.currentUser!.displayName,
        "message": messageController.text,
        "type": "text",
        "time": Timestamp.now(),
      };
      messageController.clear();

      await fireStore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  Future<void> getImage() async {
    await ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        imageFile = File(value.path);
        uploadImage();
      }
    });
  }

  Future<void> uploadImage() async {
    String fileName = Uuid().v1();

    await fireStore
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendBy": fireAuth.currentUser!.displayName,
      "message": "",
      "type": "image",
      "time": Timestamp.now(),
    });

    var ref = fireStorage.ref().child('images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!).catchError(
      (error) async {
        await fireStore
            .collection('groups')
            .doc(widget.groupChatId)
            .collection('chats')
            .doc(fileName)
            .delete();

        status = 0;
        return error;
      },
      test: (error) => error is Exception,
    );
    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await fireStore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .update({
        "message": imageUrl,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Text(widget.groupName),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupInfoPage(
                        groupName: widget.groupName,
                        groupId: widget.groupChatId,
                      ),
                    ));
              },
              icon: const Icon(Icons.more_vert))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
                width: size.width,
                child: StreamBuilder(
                  stream: fireStore
                      .collection('groups')
                      .doc(widget.groupChatId)
                      .collection('chats')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return messageTile(size,
                              snapshot.data!.docs[index].data(), fireAuth);
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              // height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: SizedBox(
                // height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  children: [
                    SizedBox(
                      // height: size.height / 12,
                      width: size.width / 1.28,
                      child: TextField(
                        maxLines: 5,
                        minLines: 1,
                        controller: messageController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: getImage,
                            icon: const Icon(
                              Icons.image,
                              color: Colors.black87,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onMessage,
                      icon: const Icon(
                        Icons.near_me_rounded,
                        size: 30,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget messageTile(
      Size size, Map<String, dynamic> map, FirebaseAuth fireAuth) {
    return Builder(
      builder: (context) {
        if (map['type'] == 'text') {
          return Container(
            width: size.width,
            alignment: map['sendBy'] == fireAuth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.black87,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    map['sendBy'],
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  SizedBox(
                    height: size.height / 200,
                  ),
                  Text(
                    map['message'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        } else if (map['type'] == 'image') {
          return Container(
            height: size.height / 3.5,
            width: size.width,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            alignment: map['sendBy'] == fireAuth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ViewImage(imageUrl: map['message'])));
              },
              child: Hero(
                tag: map['message'],
                child: Container(
                  alignment: map['message'] != "" ? null : Alignment.center,
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
                              (context, url, downloadProgress) => Padding(
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
        } else if (map['type'] == 'notify') {
          return Container(
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black54,
              ),
              child: Text(
                map['message'],
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
