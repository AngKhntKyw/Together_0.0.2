import 'dart:io';
import 'package:together_version_2/services/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_manager/photo_manager.dart';

class ImagesGridPage extends StatelessWidget {
  final List<AssetEntity> assetList;
  final ScrollController scrollController;
  final String chatRoomId;

  const ImagesGridPage({
    super.key,
    required this.scrollController,
    required this.assetList,
    required this.chatRoomId,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      itemCount: assetList.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      addSemanticIndexes: false,
      itemBuilder: (context, index) {
        AssetEntity assetEntity = assetList[index];
        if (assetEntity.type == AssetType.image) {
          return Padding(
            padding: const EdgeInsets.all(1),
            child: InkWell(
              onTap: () async {
                Navigator.pop(context);
                await ChatServices.convertImageAssetEntityToFile(
                    assetEntity, chatRoomId);
              },
              child: FutureBuilder<File?>(
                future: assetEntity.file,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: LoadingAnimationWidget.hexagonDots(
                          color: Colors.black87, size: 20),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    );
                  } else if (snapshot.data != null) {
                    return Image.file(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return const Text('Unable to load image');
                  }
                },
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(1),
            child: InkWell(
              onTap: () async {
                Navigator.pop(context);
                await ChatServices.convertVideoAssetEntityToFile(
                    assetEntity, chatRoomId);
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: FutureBuilder<File?>(
                        future: assetEntity.file,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: LoadingAnimationWidget.hexagonDots(
                                  color: Colors.black87, size: 20),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            );
                          } else if (snapshot.data != null) {
                            return Image.file(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          } else {
                            return const Text('Unable to load image');
                          }
                        },
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child:
                            Icon(Icons.video_collection, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
