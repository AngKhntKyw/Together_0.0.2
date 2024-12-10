import 'dart:developer';
import 'package:flutter/material.dart';

class ChatInputsProviders with ChangeNotifier {
  String _message = "";
  String get message => _message;

  bool _emojiShowing = false;
  bool get emojiShowing => _emojiShowing;

  bool _textFieldHasFocus = false;
  bool get textFieldHasFocus => _textFieldHasFocus;

  void typeMessage(String value) {
    _message = value;
    log(_message);
    notifyListeners();
  }

  void clearTextField() {
    _message = "";
    notifyListeners();
  }

  void showEmoji() {
    _emojiShowing = true;
    notifyListeners();
  }

  void doNotShowEmoji() {
    _emojiShowing = false;
    notifyListeners();
  }

  void focusTextField() {
    _textFieldHasFocus = true;
    notifyListeners();
  }

  void doNotFocusTextField() {
    _textFieldHasFocus = false;
    notifyListeners();
  }
}
