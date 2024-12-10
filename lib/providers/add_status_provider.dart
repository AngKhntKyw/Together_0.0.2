import 'dart:developer';
import 'package:flutter/material.dart';

class AddStatusProvider with ChangeNotifier {
  bool _isPosting = false;
  bool get isPosting => _isPosting;

  int _currentStoryIndex = 0;
  int get currentStoryIndex => _currentStoryIndex;

  void startPostingStatus() {
    _isPosting = true;
    notifyListeners();
  }

  void stopPostingStatus() {
    _isPosting = false;
    notifyListeners();
  }

  void setCurrentStoryIndex(int index) {
    _currentStoryIndex = index;
    log("CurrentIndex : $currentStoryIndex");
  }
}
