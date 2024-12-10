import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:together_version_2/pages/auth_pages/authenticate.dart';
import 'package:together_version_2/utils/utils.dart';

class AuthServices {
  static final fireAuth = FirebaseAuth.instance;
  static final fireStore = FirebaseFirestore.instance;
  static final fireMessage = FirebaseMessaging.instance;

  static Future<UserCredential?> createAccount(
      String name, String email, String password, BuildContext context) async {
    try {
      UserCredential user = await fireAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await user.user!.updateDisplayName(name);
      String? fcmToken = await fireMessage.getToken();

      await user.user!.updatePhotoURL(
          "https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o=");
      await fireStore.collection('users').doc(fireAuth.currentUser!.uid).set({
        "uid": fireAuth.currentUser!.uid,
        "name": name,
        "email": email,
        "fcmToken": fcmToken!,
        "isOnline": true,
        "lastOnline": Timestamp.now(),
        "inChat": true,
        "profileImage":
            "https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o=",
        "coverImage":
            "https://images.unsplash.com/photo-1512682479844-0fa51f42b4a4?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      });

      return user;
    } on FirebaseAuthException catch (e) {
      log("Create account error : $e");
      // ignore: use_build_context_synchronously
      Utils.showSnackBarMessage(context, e.message!);
      return null;
    }
  }

  static Future<UserCredential?> logIn(
      String email, String password, BuildContext context) async {
    try {
      UserCredential user = await fireAuth.signInWithEmailAndPassword(
          email: email, password: password);
      log(user.toString());
      return user;
    } on FirebaseAuthException catch (e) {
      log("Log in error : $e");
      // ignore: use_build_context_synchronously
      Utils.showSnackBarMessage(context, e.message!);
      return null;
    }
  }

  static Future logOut(BuildContext context) async {
    try {
      await fireAuth.signOut().then((value) => {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const Authenticate(),
                ),
                (route) => false),
          });
    } on FirebaseAuthException catch (e) {
      log("log out error : $e");
      // ignore: use_build_context_synchronously
      Utils.showSnackBarMessage(context, e.message!);
    }
  }
}
