import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/pages/chat_page/chat_detail_page.dart';
import 'package:together_version_2/pages/chat_page/video_call_page.dart';
import 'package:together_version_2/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color surfaceTintColor;
  final Color backgroundColor;
  final Map<String, dynamic> userMap;
  final String chatRoomId;
  const ChatAppBar(
      {super.key,
      required this.surfaceTintColor,
      required this.backgroundColor,
      required this.userMap,
      required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            fullscreenDialog: true,
            maintainStateData: true,
            child: ChatDetailPage(
              userMap: userMap,
              chatRoomId: chatRoomId,
            ),
            inheritTheme: true,
            ctx: context,
            matchingBuilder: const CupertinoPageTransitionsBuilder(),
          ),
        );
      },
      child: AppBar(
        surfaceTintColor: surfaceTintColor,
        backgroundColor: backgroundColor,
        title: SizedBox(
          child: Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    child: LoadingAnimationWidget.hexagonDots(
                        color: Colors.black87, size: 20),
                    backgroundColor: Colors.white,
                    foregroundImage: CachedNetworkImageProvider(
                        cacheKey: userMap['profileImage'],
                        userMap['profileImage']),
                  ),
                  CircleAvatar(
                    radius: 6,
                    backgroundColor:
                        userMap['isOnline'] ? Colors.green : Colors.transparent,
                  )
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userMap['name'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    userMap['isOnline']
                        ? "active now"
                        : Utils.changeIntoTimeAgo(userMap['lastOnline']),
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VideoCallPage(),
                    ));
              },
              icon: const Icon(Iconsax.video5, color: Colors.black87)),
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    fullscreenDialog: true,
                    maintainStateData: true,
                    child: ChatDetailPage(
                      userMap: userMap,
                      chatRoomId: chatRoomId,
                    ),
                    inheritTheme: true,
                    ctx: context,
                    matchingBuilder: const CupertinoPageTransitionsBuilder(),
                  ),
                );
              },
              icon: const Icon(Iconsax.info_circle5, color: Colors.black87))
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
