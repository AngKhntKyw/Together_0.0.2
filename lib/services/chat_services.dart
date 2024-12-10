import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:together_version_2/providers/chat_inputs_provider.dart';
import 'package:together_version_2/utils/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatServices {
  static final fireAuth = FirebaseAuth.instance;
  static final fireStore = FirebaseFirestore.instance;
  static final fireMessage = FirebaseMessaging.instance;
  static final fireStorage = FirebaseStorage.instance;
  static File? imageFile;
  static File? videoFile;
  static int status = 1;
  static List<File> imagesList = [];
  static List<File> videoList = [];

  static Future<void> uploadImage(String chatRoomId) async {
    String fileName = const Uuid().v1();

    await fireStore
        .collection('chatroom')
        .doc(chatRoomId)
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
            .collection('chatroom')
            .doc(chatRoomId)
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
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({
        "message": imageUrl,
      });
    }
  }

  static Future<void> uploadVideo(String chatRoomId) async {
    String fileName = const Uuid().v1();

    await fireStore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendBy": fireAuth.currentUser!.displayName,
      "message": "",
      "type": "video",
      "time": Timestamp.now(),
    });

    var ref = fireStorage.ref().child('images').child("$fileName.mp4");
    var uploadTask = await ref.putFile(videoFile!).catchError(
      (error) async {
        await fireStore
            .collection('chatroom')
            .doc(chatRoomId)
            .collection('chats')
            .doc(fileName)
            .delete();

        status = 0;
        return error;
      },
      test: (error) => error is Exception,
    );
    if (status == 1) {
      String videoUrl = await uploadTask.ref.getDownloadURL();
      await fireStore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({
        "message": videoUrl,
      });
    }
  }

  static Future<void> getImage(String chatRoomId) async {
    await ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        imageFile = File(value.path);
        uploadImage(chatRoomId);
      }
    });
  }

  static Future<void> getImagesList(String chatRoomId) async {
    await ImagePicker()
        .pickMultiImage(requestFullMetadata: false)
        .then((value) {
      List<File> imageFilesList = [];
      if (value.isNotEmpty) {
        for (XFile image in value) {
          imageFilesList.add(File(image.path));
        }
      }
      imagesList = imageFilesList;
      log(imagesList.length.toString());
    });
  }

  static Future<void> takePhoto(String chatRoomId) async {
    await ImagePicker().pickImage(source: ImageSource.camera).then((value) {
      if (value != null) {
        imageFile = File(value.path);
        log(imageFile.toString());
        uploadImage(chatRoomId);
      }
    });
  }

  static Future<void> convertImageAssetEntityToFile(
      AssetEntity assetEntity, String chatRoomId) async {
    await assetEntity.file.then((value) {
      if (value != null) {
        imageFile = File(value.path);
        log(imageFile.toString());
        uploadImage(chatRoomId);
      }
    });
  }

  static Future<void> convertVideoAssetEntityToFile(
      AssetEntity assetEntity, String chatRoomId) async {
    await assetEntity.file.then((value) {
      if (value != null) {
        videoFile = File(value.path);
        log(videoFile.toString());
        uploadVideo(chatRoomId);
      }
    });
  }

  static void onMessageSend(TextEditingController messageController,
      String chatRoomId, BuildContext context, String emoji) async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> message = {
        "sendBy": fireAuth.currentUser!.displayName,
        "message": messageController.text,
        "type": "text",
        "time": Timestamp.now(),
      };
      messageController.clear();
      context.read<ChatInputsProviders>().clearTextField();

      await fireStore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(message);
    } else {
      Map<String, dynamic> message = {
        "sendBy": fireAuth.currentUser!.displayName,
        "message": emoji,
        "type": "emoji",
        "time": Timestamp.now(),
      };
      await fireStore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(message);
    }
  }

  static Future<void> deleteConversation(
      String chatRoomId, BuildContext context) async {
    try {
      fireStore
          .collection('chatroom')
          .doc(chatRoomId)
          .delete()
          .whenComplete(() => log("CPL"));

      WriteBatch batch = fireStore.batch();

      QuerySnapshot querySnapshot = await fireStore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .get();
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      Utils.showSnackBarMessage(context, e.code);
    }
  }

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?>
      getPhotosInChat(String chatRoomId, BuildContext context) async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> imagesList = [];

    try {
      QuerySnapshot<Map<String, dynamic>> result = await fireStore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .where('type', isEqualTo: 'image')
          .get();

      for (int i = 0; i < result.docs.length; i++) {
        log(result.docs[i]['time'].toString());
        imagesList.add(result.docs[i]);
      }
      imagesList.sort((a, b) => a['time'].compareTo(b['time']));
      log(imagesList.length.toString());
      return imagesList;
    } on FirebaseException catch (e) {
      Utils.showSnackBarMessage(context, e.code);
      return null;
    }
  }

  static Future<Uint8List?> getThumbnail(String videoUrl) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      quality: 10,
    );
    return uint8list;
  }
}
