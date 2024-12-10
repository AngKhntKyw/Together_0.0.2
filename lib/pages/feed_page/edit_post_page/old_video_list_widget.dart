import 'package:together_version_2/pages/feed_page/add_post_page/video_widget.dart';
import 'package:together_version_2/providers/edit_post_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class OldVideoListWidget extends StatelessWidget {
  const OldVideoListWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: context.watch<EditPostProvider>().oldVideoStringList.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              InkWell(
                onTap: () {
                  context.read<EditPostProvider>().pickVideosList();
                },
                child: VideoWidget(
                  videoUrl: context
                      .watch<EditPostProvider>()
                      .oldVideoStringList[index],
                  videoList: [],
                  initialIndex: 0,
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: InkWell(
                  onTap: () {
                    context
                        .read<EditPostProvider>()
                        .removeFromOldVideoStringList(context
                            .read<EditPostProvider>()
                            .oldVideoStringList[index]);
                  },
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black,
                    child: Icon(
                      Iconsax.close_circle5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: Colors.transparent,
          );
        },
      ),
    );
  }
}
