import 'package:together_version_2/providers/edit_post_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class NewImageListWidget extends StatelessWidget {
  const NewImageListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      key: UniqueKey(),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: context.watch<EditPostProvider>().imageFileList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              context.read<EditPostProvider>().pickImagesList();
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(
                  context.watch<EditPostProvider>().imageFileList[index],
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: InkWell(
                    onTap: () {
                      context.read<EditPostProvider>().removeImageFromImageList(
                          context
                              .read<EditPostProvider>()
                              .imageFileList[index]);
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
