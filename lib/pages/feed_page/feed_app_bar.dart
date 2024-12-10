import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';

class FeedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FeedAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final fireAuth = FirebaseAuth.instance;

    return AppBar(
      surfaceTintColor: Colors.white,
      title: const Text('Home'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.topToBottom,
                fullscreenDialog: true,
                maintainStateData: true,
                child: const ProfilePage(),
                inheritTheme: true,
                ctx: context,
                matchingBuilder: const CupertinoPageTransitionsBuilder(),
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.black87,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  foregroundImage: CachedNetworkImageProvider(
                    cacheKey: fireAuth.currentUser!.photoURL!,
                    fireAuth.currentUser!.photoURL!,
                  ),
                  child: LoadingAnimationWidget.hexagonDots(
                      color: Colors.black87, size: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
