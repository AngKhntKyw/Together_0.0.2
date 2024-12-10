import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:together_version_2/providers/add_status_provider.dart';
import 'package:together_version_2/services/status_services.dart';
import 'package:together_version_2/utils/utils.dart';

class ViewStoryPage extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> statusDataList;
  final int initialIndex;
  const ViewStoryPage(
      {super.key, required this.statusDataList, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: initialIndex);
    final size = MediaQuery.sizeOf(context);
    final fireAuth = FirebaseAuth.instance;
    final storyController = StoryController();
    return PageView.builder(
      controller: pageController,
      itemCount: statusDataList.length,
      itemBuilder: (context, index) {
        final statusData = statusDataList[index].data();
        List<dynamic> statusDataMap = statusData['imageList'];
        List<String> imageList = [];

        return Stack(
          children: [
            StoryView(
                controller: storyController,
                storyItems: [
                  ...statusDataMap.map((e) {
                    imageList.add(e['image']);
                    return StoryItem.pageImage(
                      captionOuterPadding: const EdgeInsets.all(30),
                      caption: Text(
                        Utils.changeIntoTimeAgo(e['createdAt']),
                        style: const TextStyle(color: Colors.white),
                      ),
                      url: e['image'],
                      controller: storyController,
                    );
                  }),
                ],
                indicatorHeight: IndicatorHeight.small,
                onStoryShow: (storyItem, index) {
                  context.read<AddStatusProvider>().setCurrentStoryIndex(index);
                },
                onComplete: () {
                  index == statusDataList.length - 1
                      ? Navigator.pop(context)
                      : pageController.nextPage(
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.bounceInOut);
                },
                onVerticalSwipeComplete: (direction) {
                  if (direction == Direction.down) {
                    Navigator.pop(context);
                  }
                }),
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: size.height / 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          backgroundImage: CachedNetworkImageProvider(
                              statusData['post_owner_profile']),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusData['post_owner_name'],
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    Offstage(
                      offstage: statusData['post_owner_uid'] !=
                          fireAuth.currentUser!.uid,
                      child: IconButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          imageList.removeAt(context
                              .read<AddStatusProvider>()
                              .currentStoryIndex);

                          await StatusServices.updateStatus(
                              context, statusData['status_id'], imageList);
                        },
                        icon: const Icon(Iconsax.trash, color: Colors.white),
                      ),
                    )
                  ],
                ))
          ],
        );
      },
    );
  }
}
