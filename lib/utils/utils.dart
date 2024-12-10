import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class Utils {
  static void showSnackBarMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      showCloseIcon: false,
      closeIconColor: Colors.white,
      content: Text(message),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      dismissDirection: DismissDirection.horizontal,
    ));
  }

  static String changeIntoTimeAgo(Timestamp time) {
    final dateTime = time.toDate();
    final timeAgoString = timeago.format(dateTime, locale: 'en');
    return timeAgoString;
  }

  static final player = AudioPlayer();
  static void loadSound(String audioFilePath) async {
    await player.setPlayerMode(PlayerMode.lowLatency); // For quicker playback
    await player.setReleaseMode(ReleaseMode.stop); // Release after playing once
    await player.setSourceAsset(audioFilePath);
    await player.play(
      AssetSource(audioFilePath),
      mode: PlayerMode.mediaPlayer,
    );
  }
}
