import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:together_version_2/services/feed_services.dart';

class EditPostProvider with ChangeNotifier {
  String _postText = '';
  String get postText => _postText;

  List<String> _oldImageStringList = [];
  List<String> get oldImageStringList => _oldImageStringList;

  List<String> _oldVideoStringList = [];
  List<String> get oldVideoStringList => _oldVideoStringList;

  List<File> _imageFileList = [];
  List<File> get imageFileList => _imageFileList;

  List<File> _videoFileList = [];
  List<File> get videoFileList => _videoFileList;

  bool _isPosting = false;
  bool get isPosting => _isPosting;

  void typePostText(String text) {
    _postText = text;
    log(_postText);
  }

  void pickImagesList() async {
    _imageFileList = await FeedServices.getImageList() ?? [];
    log(imageFileList.length.toString());
    notifyListeners();
  }

  void removeImageFromImageList(File imageFile) {
    final result = imageFileList.remove(imageFile);
    log(result.toString());
    notifyListeners();
  }

  void pickVideosList() async {
    _videoFileList = await FeedServices.getVideoList() ?? [];
    log(videoFileList.length.toString());
    notifyListeners();
  }

  void removeVideoFromVideoList(File videoFile) {
    final result = videoFileList.remove(videoFile);
    log(result.toString());
    notifyListeners();
  }

  Future<bool> clearLists() async {
    imageFileList.clear();
    videoFileList.clear();
    oldImageStringList.clear();
    oldVideoStringList.clear();
    _postText = '';
    _isPosting = false;
    return imageFileList.isEmpty && videoFileList.isEmpty ? true : false;
  }

  void startPosting() {
    _isPosting = true;
    notifyListeners();
  }

  void stopPosting() {
    _isPosting = false;
    imageFileList.clear();
    videoFileList.clear();
    _postText = '';
    notifyListeners();
  }

  void removeFromOldImageStringList(String image) {
    _oldImageStringList.remove(image);
    notifyListeners();
  }

  void removeFromOldVideoStringList(String video) {
    _oldVideoStringList.remove(video);
    notifyListeners();
  }
}
