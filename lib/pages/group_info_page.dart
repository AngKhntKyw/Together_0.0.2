import 'dart:developer';
import 'package:together_version_2/pages/add_members_in_group.dart';
import 'package:together_version_2/pages/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class GroupInfoPage extends StatefulWidget {
  final String groupName, groupId;
  const GroupInfoPage(
      {super.key, required this.groupName, required this.groupId});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final fireStore = FirebaseFirestore.instance;
  final fireAuth = FirebaseAuth.instance;
  final fireStorage = FirebaseStorage.instance;
  List membersList = [];
  bool isLoading = true;

  void getMembersList() async {
    await fireStore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((value) {
      setState(() {
        membersList = value['members'];
        isLoading = false;
      });
    });
  }

  void removeUser(int index) async {
    Navigator.of(context).pop();
    String uid = membersList[index]['uid'];
    setState(() {
      isLoading = true;
    });
    membersList.removeAt(index);
    await fireStore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    });

    await fireStore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .doc(widget.groupId)
        .delete();
    setState(() {
      isLoading = false;
    });
  }

  void showRemoveDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: ListTile(
            onTap: () {
              removeUser(index);
            },
            title: const Text("Remove this user"),
          ),
        );
      },
    );
  }

  bool checkAdmin() {
    bool isAdmin = false;
    for (var element in membersList) {
      if (element['uid'] == fireAuth.currentUser!.uid) {
        isAdmin = element['isAdmin'];
      }
    }
    log(isAdmin.toString());
    return isAdmin;
  }

  void onLeaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });
      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['uid'] == fireAuth.currentUser!.uid) {
          membersList.removeAt(i);
        }
      }

      await fireStore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });
      await fireStore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavBar(),
          ),
          (route) => false);
    }
  }

  @override
  void initState() {
    getMembersList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        surfaceTintColor: Colors.white,
      ),
      body: isLoading
          ? Container(
              width: size.width,
              height: size.height,
              alignment: Alignment.center,
              child: LoadingAnimationWidget.hexagonDots(
                  color: Colors.black87, size: 20),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // const Align(alignment: Alignment.centerLeft, child: BackButton()),
                    SizedBox(
                      height: size.height / 8,
                      width: size.width / 1.1,
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.black87,
                            child: Icon(Icons.group, color: Colors.white),
                          ),
                          SizedBox(width: size.width / 20),
                          Text(widget.groupName),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height / 50),
                    SizedBox(
                      width: size.width / 1.1,
                      child: Text("${membersList.length} members"),
                    ),

                    checkAdmin()
                        ? ListTile(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddMembersInGroup(
                                    groupId: widget.groupId,
                                    groupName: widget.groupName,
                                    membersList: membersList,
                                  ),
                                )),
                            leading: const Icon(Icons.add),
                            title: const Text(
                              "add members",
                            ),
                          )
                        : const SizedBox(),
                    Flexible(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: membersList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => checkAdmin()
                                ? membersList[index]['isAdmin']
                                    ? null
                                    : showRemoveDialog(index)
                                : null,
                            leading: const Icon(Icons.account_circle),
                            title: Text(membersList[index]['name']),
                            subtitle: Text(membersList[index]['email']),
                            trailing: Text(
                                membersList[index]['isAdmin'] ? "Admin" : ""),
                          );
                        },
                      ),
                    ),
                    ListTile(
                      onTap: onLeaveGroup,
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        "Leave group",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
