import 'package:together_version_2/pages/feed_page/add_post_page/video_widget.dart';
import 'package:together_version_2/pages/feed_page/feed_video_widget/play_video_list_page.dart';
import 'package:flutter/material.dart';

class ViewFeedVideosListVerticallyPage extends StatefulWidget {
  final List<String> videoList;
  final int initialIndex;
  const ViewFeedVideosListVerticallyPage({
    super.key,
    required this.videoList,
    required this.initialIndex,
  });

  @override
  State<ViewFeedVideosListVerticallyPage> createState() =>
      _ViewFeedVideosListVerticallyPageState();
}

class _ViewFeedVideosListVerticallyPageState
    extends State<ViewFeedVideosListVerticallyPage> {
  late ScrollController _controller;
  @override
  void initState() {
    super.initState();
    _controller = ScrollController(
      initialScrollOffset: widget.initialIndex == widget.videoList.length - 1
          ? (widget.initialIndex * 350) - 350
          : widget.initialIndex * 350,
      keepScrollOffset: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          automaticallyImplyLeading: true,
        ),
        body: Dismissible(
          movementDuration: const Duration(milliseconds: 10),
          resizeDuration: const Duration(milliseconds: 10),
          key: UniqueKey(),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              Navigator.of(context).pop();
            }
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                itemCount: widget.videoList.length,
                controller: _controller,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayVideoListPage(
                                videoList: widget.videoList,
                                initialIndex: widget.initialIndex),
                          ));
                    },
                    child: Hero(
                      tag: widget.videoList[index],
                      child: Container(
                          color: const Color.fromARGB(255, 234, 234, 234),
                          height: 350,
                          child: VideoWidget(
                            videoUrl: widget.videoList[index],
                            videoList: widget.videoList,
                            initialIndex: index,
                          )),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    color: Colors.transparent,
                  );
                },
              ),
            ),
          ),
        ));
  }
}
