import 'package:flutter/material.dart';

class PostText extends StatelessWidget {
  final String postText;
  const PostText({
    super.key,
    required this.postText,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      postText,
    );
  }
}
