import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/pages/create_group_page.dart';
import 'package:together_version_2/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  List<Map<String, dynamic>> membersList = [];
  final fireStore = FirebaseFirestore.instance;
  final fireAuth = FirebaseAuth.instance;
  bool isLoading = false;
  final searchController = TextEditingController();
  Map<String, dynamic>? userMap;

  void getCurrentUserDetails() async {
    await fireStore
        .collection('users')
        .doc(fireAuth.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        membersList.add({
          "name": value['name'],
          "email": value['email'],
          "profileImage": value['profileImage'],
          "uid": value['uid'],
          "isAdmin": true,
        });
      });
    });
  }

  @override
  void initState() {
    getCurrentUserDetails();
    super.initState();
  }

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

  void onResultTap() {
    bool isAlreadyExist = false;
    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }
    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "name": userMap!['name'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "profileImage": userMap!['profileImage'],
          "isAdmin": false,
        });
        userMap = null;
      });
    } else {
      Utils.showSnackBarMessage(
          context, "${userMap!['name']} is already added.");
    }
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['uid'] != fireAuth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    } else {
      Utils.showSnackBarMessage(context, "You can't remove yourself.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add members'),
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: membersList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () => onRemoveMembers(index),
                  leading: CircleAvatar(
                    child: LoadingAnimationWidget.hexagonDots(
                        color: Colors.black87, size: 20),
                    backgroundColor: Colors.black87,
                    foregroundImage: CachedNetworkImageProvider(
                        cacheKey: membersList[index]['profileImage'],
                        membersList[index]['profileImage']),
                  ),
                  title: Text(membersList[index]['name']),
                  subtitle: Text(membersList[index]['email']),
                  trailing: const Icon(Icons.close),
                );
              },
            )),
            SizedBox(height: size.height / 20),
            Container(
              height: size.height / 14,
              width: size.width,
              alignment: Alignment.center,
              child: SizedBox(
                height: size.height / 14,
                width: size.width / 1.15,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      hintText: "Search",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
              ),
            ),
            SizedBox(height: size.height / 50),
            SizedBox(
              height: size.height / 20,
              child: isLoading
                  ? Container(
                      height: size.height / 12,
                      width: size.width / 12,
                      alignment: Alignment.center,
                      child: LoadingAnimationWidget.hexagonDots(
                          color: Colors.white, size: 30))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onSearch,
                      child: const Text(
                        "Search",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
            userMap != null
                ? ListTile(
                    onTap: onResultTap,
                    leading: CircleAvatar(
                      child: LoadingAnimationWidget.hexagonDots(
                          color: Colors.black87, size: 20),
                      backgroundColor: Colors.black87,
                      foregroundImage: CachedNetworkImageProvider(
                          cacheKey: userMap!['profileImage'],
                          userMap!['profileImage']),
                    ),
                    title: Text(userMap!['name']),
                    subtitle: Text(userMap!['email']),
                    trailing: const Icon(Icons.add),
                  )
                : const SizedBox(),
          ],
        ),
      ),
      floatingActionButton: membersList.length >= 2
          ? FloatingActionButton(
              backgroundColor: Colors.black87,
              child: const Icon(
                Iconsax.arrow_circle_right,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateGroupPage(membersList: membersList),
                    ));
              },
            )
          : const SizedBox(),
    );
  }
}
