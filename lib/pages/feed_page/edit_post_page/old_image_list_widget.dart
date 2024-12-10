import 'package:cached_network_image/cached_network_image.dart';
import 'package:together_version_2/providers/edit_post_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class OldImageListWidget extends StatelessWidget {
  const OldImageListWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: context.watch<EditPostProvider>().oldImageStringList.length,
        itemBuilder: (context, index) {
          return Stack(
            alignment: Alignment.topRight,
            children: [
              InkWell(
                onTap: () {
                  context.read<EditPostProvider>().pickImagesList();
                },
                child: CachedNetworkImage(
                  cacheKey: context
                      .watch<EditPostProvider>()
                      .oldImageStringList[index],
                  imageUrl: context
                      .watch<EditPostProvider>()
                      .oldImageStringList[index],
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: InkWell(
                  onTap: () {
                    context
                        .read<EditPostProvider>()
                        .removeFromOldImageStringList(context
                            .read<EditPostProvider>()
                            .oldImageStringList[index]);
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
