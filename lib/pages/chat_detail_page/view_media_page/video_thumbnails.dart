import 'package:together_version_2/services/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VideoThumbNails extends StatelessWidget {
  final dynamic videoUrl;
  final int index;
  final int currentIndex;

  const VideoThumbNails({
    super.key,
    required this.videoUrl,
    required this.index,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ChatServices.getThumbnail(videoUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.hexagonDots(
                color: Colors.black87, size: 20),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("${snapshot.error}"),
          );
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color:
                        currentIndex == index ? Colors.white : Colors.black87),
              ),
              height: 50,
              width: 50,
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
            ),
            Icon(
              currentIndex == index ? Icons.pause : Icons.play_circle_fill,
              color: Colors.white,
              size: 20,
            ),
          ],
        );
      },
    );
  }
}
