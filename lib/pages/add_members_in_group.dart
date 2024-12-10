import 'dart:developer';
import 'package:together_version_2/pages/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddMembersInGroup extends StatefulWidget {
  final String groupId, groupName;
  final List membersList;
  const AddMembersInGroup(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.membersList});

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  List membersList = [];
  final fireStore = FirebaseFirestore.instance;
  final fireAuth = FirebaseAuth.instance;
  bool isLoading = false;
  final searchController = TextEditingController();
  Map<String, dynamic>? userMap;

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

  void onAddMembers() async {
    log(userMap.toString());
    final nav = Navigator.of(context);
    membersList.add({
      "name": userMap!['name'],
      "email": userMap!['email'],
      "uid": userMap!['uid'],
      "isAdmin": false,
    });
    await fireStore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    });

    await fireStore
        .collection('users')
        .doc(fireAuth.currentUser!.uid)
        .collection('groups')
        .doc(widget.groupId)
        .set({
      "name": widget.groupName,
      "id": widget.groupId,
    });

    nav.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const BottomNavBar(),
        ),
        (route) => false);
  }

  @override
  void initState() {
    membersList = widget.membersList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add members'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flexible(
            //     child: ListView.builder(
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   itemCount: membersList.length,
            //   itemBuilder: (context, index) {
            //     return ListTile(
            //       onTap: () {},
            //       leading: const Icon(Icons.account_circle),
            //       title: Text(membersList[index]['name']),
            //       subtitle: Text(membersList[index]['email']),
            //       // trailing: const Icon(Icons.close),
            //     );
            //   },
            // )),
            // SizedBox(height: size.height / 20),
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
                          color: Colors.white, size: 20))
                  : ElevatedButton(
                      onPressed: onSearch,
                      child: const Text("Search"),
                    ),
            ),
            userMap != null
                ? ListTile(
                    onTap: onAddMembers,
                    leading: const Icon(Icons.account_box),
                    title: Text(userMap!['name']),
                    subtitle: Text(userMap!['email']),
                    trailing: const Icon(Icons.add),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
