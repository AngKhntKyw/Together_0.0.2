import 'package:together_version_2/providers/add_post_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class ImageListWidget extends StatelessWidget {
  const ImageListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      key: UniqueKey(),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: context.watch<AddPostProvider>().imageFileList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              context.read<AddPostProvider>().pickImagesList();
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(
                  context.watch<AddPostProvider>().imageFileList[index],
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: InkWell(
                    onTap: () {
                      context.read<AddPostProvider>().removeImageFromImageList(
                          context.read<AddPostProvider>().imageFileList[index]);
                    },
                    child: const CircleAvatar(
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
          return const Divider(
            color: Colors.transparent,
          );
        },
      ),
    );
  }
}
