import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:together_version_2/services/feed_services.dart';

class AddPostProvider with ChangeNotifier {
  String _postText = '';
  String get postText => _postText;

  List<File> _imageFileList = [];
  List<File> get imageFileList => _imageFileList;

  List<File> _videoFileList = [];
  List<File> get videoFileList => _videoFileList;

  bool _isPosting = false;
  bool get isPosting => _isPosting;

  void typePostText(String text) {
    _postText = text;
    log(_postText);
    notifyListeners();
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
    _isPosting = false;
    imageFileList.clear();
    videoFileList.clear();
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

  void setValuesForEditFeed(
      String postText, List<File> imageList, List<File> videoList) {
    _postText = postText;
    _imageFileList = imageList;
    _videoFileList = videoList;
    notifyListeners();
  }
}
