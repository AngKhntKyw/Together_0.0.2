import 'package:together_version_2/pages/feed_page/add_post_page/video_widget.dart';
import 'package:together_version_2/providers/add_post_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class VideoListWidget extends StatelessWidget {
  const VideoListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      key: UniqueKey(),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: context.watch<AddPostProvider>().videoFileList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              context.read<AddPostProvider>().pickVideosList();
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                VideoWidget(
                    key: UniqueKey(),
                    videoUrl: context
                        .watch<AddPostProvider>()
                        .videoFileList[index]
                        .path,
                    videoList: [],
                    initialIndex: 0),
                Positioned(
                  top: 5,
                  right: 5,
                  child: InkWell(
                    onTap: () {
                      context.read<AddPostProvider>().removeVideoFromVideoList(
                          context.read<AddPostProvider>().videoFileList[index]);
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
                )
              ],
            ),
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
