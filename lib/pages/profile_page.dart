import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/pages/view_image.dart';
import 'package:together_version_2/services/auth_services.dart';
import 'package:together_version_2/services/user_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final fireAuth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final fireStorage = FirebaseStorage.instance;
  File? imageFile;
  bool isLoading = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  String? coverImage;

  void changeProfileImage() async {
    try {
      setState(() {
        isLoading = true;
      });
      await UserServices.changeProfileImage();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void changeCoverImage() async {
    try {
      setState(() {
        isLoading = true;
      });
      await UserServices.changeCoverImage();
      getCoverImage();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void changeEmail() async {
    try {
      setState(() {
        isLoading = true;
      });
      await UserServices.changeEmail(emailController.text, context);
      setState(() {
        isLoading = false;
        emailController.clear();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        emailController.clear();
      });
    }
  }

  void changeName() async {
    try {
      setState(() {
        isLoading = true;
      });
      await UserServices.changeName(nameController.text, context);
      setState(() {
        isLoading = false;
        nameController.clear();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        nameController.clear();
      });
    }
  }

  void setOffline() async {
    await fireStore.collection('users').doc(fireAuth.currentUser!.uid).update({
      "isOnline": false,
      "inChat": false,
      "lastOnline": Timestamp.now(),
    });
  }

  void getCoverImage() async {
    setState(() {
      isLoading = true;
    });
    final documentSnapShot = await fireStore
        .collection('users')
        .doc(fireAuth.currentUser!.uid)
        .get();
    setState(() {
      coverImage = documentSnapShot['coverImage'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    getCoverImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: const Text("Profile"),
      ),
      body: !isLoading
          ? SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.black87,
                      surfaceTintColor: Colors.white,
                      child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(15)),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                children: [
                                  Expanded(
                                      child: Container(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          InkWell(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ViewImage(
                                                          imageUrl:
                                                              coverImage!),
                                                )),
                                            child: Hero(
                                              tag: coverImage!,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            coverImage!),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.white,
                                              child: IconButton(
                                                onPressed: changeCoverImage,
                                                icon: const Icon(
                                                  Icons.camera_alt_rounded,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                                  Expanded(
                                    child: Container(
                                        color: Colors.transparent,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              fireAuth
                                                  .currentUser!.displayName!,
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              fireAuth.currentUser!.email!,
                                              style: const TextStyle(
                                                  color: Colors.black87),
                                            ),
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  InkWell(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewImage(
                                              imageUrl: fireAuth
                                                  .currentUser!.photoURL!),
                                        )),
                                    child: Hero(
                                      tag: fireAuth.currentUser!.photoURL!,
                                      child: CircleAvatar(
                                        radius: 62,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 58,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  cacheKey: fireAuth
                                                      .currentUser!.photoURL!,
                                                  fireAuth
                                                      .currentUser!.photoURL!),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: changeProfileImage,
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 15,
                                      child: Icon(
                                        Icons.change_circle,
                                        size: 25,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Iconsax.user_edit,
                                color: Colors.black87),
                            hintText: fireAuth.currentUser!.displayName,
                            suffixIcon: nameController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: changeName,
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              nameController.text = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Iconsax.personalcard,
                                color: Colors.black87),
                            hintText: fireAuth.currentUser!.email,
                            suffixIcon: emailController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: changeEmail,
                                    icon: const Icon(Icons.done,
                                        color: Colors.green),
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              emailController.text = value;
                            });
                          },
                        ),
                        const SizedBox(height: 80),
                        InkWell(
                          onTap: () {
                            AuthServices.logOut(context);
                            setOffline();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: size.width,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.black87,
                            ),
                            child: const Text(
                              "Log out",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: LoadingAnimationWidget.hexagonDots(
                  color: Colors.black87, size: 20),
            ),
    );
  }
}
