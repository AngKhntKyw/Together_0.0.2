import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:together_version_2/utils/utils.dart';
import 'package:uuid/uuid.dart';

class UserServices {
  static final fireAuth = FirebaseAuth.instance;
  static final fireStore = FirebaseFirestore.instance;
  static final fireMessage = FirebaseMessaging.instance;
  static final fireStorage = FirebaseStorage.instance;

  static Future<void> changeProfileImage() async {
    String fileName = const Uuid().v1();
    File? imageFile;
    await ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        imageFile = File(value.path);
      }
    });
    var ref = fireStorage.ref().child('profile_images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!);
    String imageUrl = await uploadTask.ref.getDownloadURL();
    await fireAuth.currentUser!.updatePhotoURL(imageUrl);
    await fireStore.collection('users').doc(fireAuth.currentUser!.uid).update({
      "profileImage": imageUrl,
    });
  }

  static Future<void> changeCoverImage() async {
    String fileName = const Uuid().v1();
    File? imageFile;
    await ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        imageFile = File(value.path);
      }
    });
    var ref = fireStorage.ref().child('cover_images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!);
    String imageUrl = await uploadTask.ref.getDownloadURL();
    await fireStore.collection('users').doc(fireAuth.currentUser!.uid).update({
      "coverImage": imageUrl,
    });
  }

  static Future<void> changeEmail(String email, BuildContext context) async {
    try {
      await fireAuth.currentUser!.updateEmail(email);
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      Utils.showSnackBarMessage(context, e.code);
    }
  }

  static Future<void> changeName(String name, BuildContext context) async {
    try {
      await fireAuth.currentUser!.updateDisplayName(name);
      await fireStore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .update({
        "name": name,
      });
      // ignore: use_build_context_synchronously
      Utils.showSnackBarMessage(context, "Changed name successfully.");
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      Utils.showSnackBarMessage(context, e.code);
    }
  }
}
