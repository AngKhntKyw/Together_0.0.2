import 'dart:developer';
import 'package:together_version_2/pages/add_member_page.dart';
import 'package:together_version_2/pages/group_chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final fireStore = FirebaseFirestore.instance;
  final fireAuth = FirebaseAuth.instance;
  List groupList = [];
  bool isLoading = true;

  void getAvailableGroups() async {
    try {
      await fireStore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .collection('groups')
          .get()
          .then((value) {
        setState(() {
          groupList = value.docs;
          isLoading = false;
        });
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    getAvailableGroups();
    log(groupList.length.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: const Text("Groups"),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: LoadingAnimationWidget.hexagonDots(
                  color: Colors.black87, size: 20),
            )
          : groupList.isNotEmpty
              ? ListView.builder(
                  itemCount: groupList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupChatRoom(
                                groupChatId: groupList[index]['id'],
                                groupName: groupList[index]['name'],
                              ),
                            ));
                      },
                      leading: const CircleAvatar(
                        backgroundColor: Colors.black87,
                        child: Icon(Icons.group, color: Colors.white),
                      ),
                      title: Text(groupList[index]['name']),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.black87),
                    );
                  },
                )
              : Container(
                  height: size.height,
                  width: size.width,
                  alignment: Alignment.center,
                  child: const Text("There is no group."),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddMemberPage(),
              ));
        },
        tooltip: "create group",
        child: const Icon(
          Iconsax.edit,
          color: Colors.white,
        ),
      ),
    );
  }
}
