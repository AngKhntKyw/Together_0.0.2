import 'package:together_version_2/pages/chat_list_page.dart';
import 'package:together_version_2/pages/feed_page.dart';
import 'package:together_version_2/pages/group_chats_page.dart';
import 'package:together_version_2/pages/user_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const FeedPage(),
    const ChatListPage(),
    const GroupChatPage(),
    UserProfilePage(userId: FirebaseAuth.instance.currentUser!.uid),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black87,
        currentIndex: currentIndex,
        showSelectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        iconSize: 25,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            tooltip: "Feed",
            icon: Icon(Iconsax.home),
            activeIcon: Icon(Iconsax.home_15),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            tooltip: "Chat",
            icon: Icon(Iconsax.message),
            activeIcon: Icon(Iconsax.message5),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            tooltip: "Groups",
            icon: Icon(Iconsax.people),
            activeIcon: Icon(Iconsax.people5),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            tooltip: "Profile",
            icon: Icon(Iconsax.profile_circle),
            activeIcon: Icon(Iconsax.profile_circle5),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
