import 'dart:developer';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayVideoPage extends StatefulWidget {
  final String videoUrl;

  const PlayVideoPage({
    super.key,
    required this.videoUrl,
  });

  @override
  State<PlayVideoPage> createState() => _PlayVideoPageState();
}

class _PlayVideoPageState extends State<PlayVideoPage> {
  late BetterPlayerController betterPlayerController;
  late BetterPlayerDataSource dataSource;

  @override
  void initState() {
    log("Video Url : ${widget.videoUrl}");

    dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
      cacheConfiguration: const BetterPlayerCacheConfiguration(
        useCache: true,
        maxCacheFileSize: 1024 * 1024 * 100,
        maxCacheSize: 1024 * 1024 * 100,
        preCacheSize: 1024 * 1024 * 10,
      ),
    );

    betterPlayerController = BetterPlayerController(
      betterPlayerDataSource: dataSource,
      const BetterPlayerConfiguration(
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enablePlayPause: false,
        ),
        autoDetectFullscreenAspectRatio: true,
        autoDetectFullscreenDeviceOrientation: true,
        fullScreenByDefault: false,
        autoPlay: true,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitDown,
          DeviceOrientation.portraitUp,
        ],
        fit: BoxFit.contain,
      ),
    );
    bool result = betterPlayerController.isVideoInitialized()!;

    log(result.toString());
    super.initState();
  }

  @override
  void dispose() {
    betterPlayerController.dispose();
    betterPlayerController.clearCache();
    log("DP");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BetterPlayer(controller: betterPlayerController),
    );
  }
}
