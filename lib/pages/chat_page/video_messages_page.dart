import 'package:together_version_2/pages/chat_page/play_video_page.dart';
import 'package:together_version_2/services/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VideoMessages extends StatelessWidget {
  final String videoUrl;
  const VideoMessages({
    super.key,
    required this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
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
            SizedBox(
              height: size.height / 2.5,
              width: size.width / 2.5,
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayVideoPage(videoUrl: videoUrl),
                    ));
              },
              icon: const Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        );
      },
    );
  }
}
