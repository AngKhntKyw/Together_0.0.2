// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:together_version_2/utils/utils.dart';
import 'package:uuid/uuid.dart';

class StatusServices {
  static final fireAuth = FirebaseAuth.instance;
  static final fireStore = FirebaseFirestore.instance;
  static final fireMessage = FirebaseMessaging.instance;
  static final fireStorage = FirebaseStorage.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllStatus() {
    return fireStore
        .collection('status')
        .orderBy('time', descending: true)
        .snapshots(includeMetadataChanges: false);
  }

  static Future<void> createStatus(File imageFile, BuildContext context) async {
    var statusId = const Uuid().v1();
    String fileName = const Uuid().v1();
    var ref = fireStorage.ref().child('status_images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile);
    String imageUrl = await uploadTask.ref.getDownloadURL();

    // Check if there are old status
    List<Map<String, dynamic>> statusImageUrls = [
      {"image": imageUrl, "createdAt": DateTime.now()}
    ];
    final statusesSnapshot = await fireStore
        .collection('status')
        .where('post_owner_uid', isEqualTo: fireAuth.currentUser!.uid)
        .get();

    if (statusesSnapshot.docs.isNotEmpty) {
      final statusImageUrls = List<Map<String, dynamic>>.from(
          statusesSnapshot.docs[0].data()['imageList']);

      statusImageUrls.add({"image": imageUrl, "createdAt": DateTime.now()});
      await fireStore
          .collection('status')
          .doc(statusesSnapshot.docs[0].id)
          .update({
        'imageList': statusImageUrls,
      });
      return;
    } else {
      statusImageUrls = [
        {"image": imageUrl, "createdAt": DateTime.now()}
      ];
    }

    try {
      await fireStore.collection('status').doc().set(
        {
          "status_id": statusId,
          "time": Timestamp.now(),
          "post_owner_uid": fireAuth.currentUser!.uid,
          "imageList": statusImageUrls,
          'post_owner_name': fireAuth.currentUser!.displayName,
          'post_owner_profile': fireAuth.currentUser!.photoURL,
        },
      );
    } on FirebaseException catch (e) {
      Utils.showSnackBarMessage(context, '$e');
    } catch (e) {
      Utils.showSnackBarMessage(context, e.toString());
    }
  }

  static Future<void> updateStatus(
      BuildContext context, String statusId, List<String> imageList) async {
    try {
      final statusesSnapshot = await fireStore
          .collection('status')
          .where('post_owner_uid', isEqualTo: fireAuth.currentUser!.uid)
          .get();
      if (statusesSnapshot.docs[0].data()['imageList'].length < 1) {
        await fireStore
            .collection('status')
            .doc(statusesSnapshot.docs[0].id)
            .delete();
      }
      await fireStore
          .collection('status')
          .doc(statusesSnapshot.docs[0].id)
          .update({
        'imageList': imageList,
      });
    } on FirebaseException catch (e) {
      Utils.showSnackBarMessage(context, '$e');
      log(e.toString());
    } catch (e) {
      Utils.showSnackBarMessage(context, '$e');
      log(e.toString());
    }
  }
}
