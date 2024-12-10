import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:together_version_2/utils/utils.dart';
import 'package:uuid/uuid.dart';

class FeedServices {
  static final fireAuth = FirebaseAuth.instance;
  static final fireStore = FirebaseFirestore.instance;
  static final fireMessage = FirebaseMessaging.instance;
  static final fireStorage = FirebaseStorage.instance;

// Get all posts
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllPosts() {
    return fireStore
        .collection('feed')
        .orderBy('time', descending: true)
        .snapshots(includeMetadataChanges: false);
  }

  static Future<File?> getImage() async {
    final imageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      return File(imageFile.path);
    } else {
      return null;
    }
  }

  static Future<List<File>?> getImageList() async {
    final imageXFileList =
        await ImagePicker().pickMultiImage(requestFullMetadata: true);
    List<File> imageFileList = [];
    if (imageXFileList.isNotEmpty) {
      for (XFile image in imageXFileList) {
        imageFileList.add(File(image.path));
      }
      return imageFileList;
    } else {
      return null;
    }
  }

  static Future<List<File>?> getVideoList() async {
    final videoXFileList =
        await ImagePicker().pickMultipleMedia(requestFullMetadata: true);
    List<File> videoFileList = [];
    if (videoXFileList.isNotEmpty) {
      for (XFile image in videoXFileList) {
        videoFileList.add(File(image.path));
      }
      return videoFileList;
    } else {
      return null;
    }
  }

  static Future<void> createPost(
      File imageFile, String postText, BuildContext context) async {
    String fileName = const Uuid().v1();
    var ref = fireStorage.ref().child('feed_images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile);
    String imageUrl = await uploadTask.ref.getDownloadURL();

    //
    List<File> imageFileList = [];
    List<String> imageStringList = [];

    for (File image in imageFileList) {
      String fileName = const Uuid().v1();
      var ref = fireStorage.ref().child('feed_images').child("$fileName.jpg");
      var uploadTask = await ref.putFile(image);
      String imageUrl = await uploadTask.ref.getDownloadURL();
      imageStringList.add(imageUrl);
    }

    //

    try {
      await fireStore.collection('feed').add(
        {
          "post_text": postText,
          "image": imageUrl,
          "time": Timestamp.now(),
          "post_owner_uid": fireAuth.currentUser!.uid,
          "imageList": [],
          'post_owner':
              fireStore.collection('users').doc(fireAuth.currentUser!.uid),
        },
      ).then((value) {
        value.collection('post_owner').doc('postOwnerDocument').set({
          "owner": fireStore.collection('users').doc(fireAuth.currentUser!.uid),
        });
        value.collection('react').doc('reactDocument').set({
          "react": [],
          "comment": [],
        });
      });
    } on FirebaseException catch (e) {
      Utils.showSnackBarMessage(context, e.code);
    }
  }

  static Future<void> createPostWithImages(List<File> videoFileList,
      List<File> imageFileList, String postText, BuildContext context) async {
    //
    List<String> imageStringList = [];
    List<String> videoStringList = [];

    for (File image in imageFileList) {
      String fileName = const Uuid().v1();
      var ref = fireStorage.ref().child('feed_images').child("$fileName.jpg");
      var uploadTask = await ref.putFile(image);
      String imageUrl = await uploadTask.ref.getDownloadURL();
      imageStringList.add(imageUrl);
    }

    for (File video in videoFileList) {
      String fileName = const Uuid().v1();
      var ref = fireStorage.ref().child('feed_videos').child("$fileName.mp4");
      var uploadTask = await ref.putFile(video);
      String videoUrl = await uploadTask.ref.getDownloadURL();
      videoStringList.add(videoUrl);
    }

    //

    try {
      await fireStore.collection('feed').add(
        {
          "post_text": postText,
          "time": Timestamp.now(),
          "post_owner_uid": fireAuth.currentUser!.uid,
          "imageList": imageStringList,
          "videoList": videoStringList,
        },
      ).then((value) {
        value.collection('post_owner').doc('postOwnerDocument').set({
          "owner": fireStore.collection('users').doc(fireAuth.currentUser!.uid),
        });
        value.collection('react').doc('reactDocument').set({
          "react": [],
          "comment": [],
        });
      });
    } on FirebaseException catch (e) {
      Utils.showSnackBarMessage(context, e.code);
    }
  }

  static Future<void> reactPost(
      String postId, BuildContext context, List<dynamic> postReact) async {
    try {
      await fireStore
          .collection('feed')
          .doc(postId)
          .collection('react')
          .doc('reactDocument')
          .update({"react": postReact});
    } on FirebaseException catch (e) {
      Utils.showSnackBarMessage(context, e.code);
    }
  }

  static Future<void> commentPost(
      String postId, BuildContext context, List<dynamic> postComment) async {
    try {
      fireStore
          .collection('feed')
          .doc(postId)
          .collection('react')
          .doc('reactDocument')
          .update({"comment": postComment});
    } on FirebaseException catch (e) {
      Utils.showSnackBarMessage(context, e.code);
    }
  }

  static Future<void> deletePost(String postId, BuildContext context) async {
    try {
      fireStore
          .collection('feed')
          .doc(postId)
          .delete()
          .whenComplete(() => log("PPL"));

      WriteBatch batch = fireStore.batch();

      QuerySnapshot reactQuery = await fireStore
          .collection('feed')
          .doc(postId)
          .collection('react')
          .get();
      for (QueryDocumentSnapshot document in reactQuery.docs) {
        batch.delete(document.reference);
      }
      QuerySnapshot postOwnerQuery = await fireStore
          .collection('feed')
          .doc(postId)
          .collection('post_owner')
          .get();
      for (QueryDocumentSnapshot document in postOwnerQuery.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();

      //
    } on FirebaseException catch (e) {
      Utils.showSnackBarMessage(context, e.code);
    }
  }

  static Future<void> editPost(String postId, File? imageFile, String postText,
      String? oldImageUrl, BuildContext context) async {
    // Check if user update image or not

    if (oldImageUrl != null) {
      try {
        await fireStore.collection('feed').doc(postId).update({
          "post_text": postText,
        });
      } on FirebaseException catch (e) {
        Utils.showSnackBarMessage(context, e.code);
      }
    } else {
      String fileName = const Uuid().v1();
      var ref = fireStorage.ref().child('feed_images').child("$fileName.jpg");
      var uploadTask = await ref.putFile(imageFile!);
      String imageUrl = await uploadTask.ref.getDownloadURL();

      try {
        await fireStore.collection('feed').doc(postId).update({
          "post_text": postText,
          "image": imageUrl,
        });
      } on FirebaseException catch (e) {
        Utils.showSnackBarMessage(context, e.code);
      }
    }
  }

  static Future<void> editPostWithImages(
      String postId,
      String postText,
      List<File> imageFileList,
      List<String> oldImageUrl,
      List<File> videoFileList,
      List<String> oldVideoUrl,
      BuildContext context) async {
    // Check if user update image or not

    try {
      List<String> imageStringList = [];
      List<String> videoStringList = [];
      if (imageFileList.isNotEmpty) {
        for (File image in imageFileList) {
          String fileName = const Uuid().v1();
          var ref =
              fireStorage.ref().child('feed_images').child("$fileName.jpg");
          var uploadTask = await ref.putFile(image);
          String imageUrl = await uploadTask.ref.getDownloadURL();
          imageStringList.add(imageUrl);
        }
      }

      if (videoFileList.isNotEmpty) {
        for (File video in videoFileList) {
          String fileName = const Uuid().v1();
          var ref =
              fireStorage.ref().child('feed_videos').child("$fileName.mp4");
          var uploadTask = await ref.putFile(video);
          String videoUrl = await uploadTask.ref.getDownloadURL();
          videoStringList.add(videoUrl);
        }
      }

      await fireStore.collection('feed').doc(postId).update({
        "post_text": postText,
        "imageList": imageStringList.isNotEmpty ? imageStringList : oldImageUrl,
        "videoList": videoStringList.isNotEmpty ? videoStringList : oldVideoUrl,
      });
    } on FirebaseException catch (e) {
      Utils.showSnackBarMessage(context, e.code);
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserPost(
      String userId) {
    return fireStore
        .collection('feed')
        .where('post_owner_uid', isEqualTo: userId)
        .snapshots(includeMetadataChanges: false);
  }

  static saveNetworkImage(String image, BuildContext context) async {
    var response = await Dio()
        .get(image, options: Options(responseType: ResponseType.bytes));

    Utils.showSnackBarMessage(context,
        response.statusCode == 200 ? "Saved to phone." : "Fail to save.");

    await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
        quality: 80, isReturnImagePathOfIOS: true);
  }
}
