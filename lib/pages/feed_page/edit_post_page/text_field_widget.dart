import 'package:together_version_2/providers/edit_post_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController postTextController;
  final String text;
  const TextFieldWidget({
    super.key,
    required this.postTextController,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: postTextController,
      expands: false,
      obscureText: false,
      maxLines: null,
      minLines: null,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        filled: true,
        fillColor: Colors.grey[200],
        hintText: "What's on your mind today?",
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      scrollPhysics: const ClampingScrollPhysics(),
      onChanged: (value) {
        context.read<EditPostProvider>().typePostText(value);
      },
    );
  }
}
