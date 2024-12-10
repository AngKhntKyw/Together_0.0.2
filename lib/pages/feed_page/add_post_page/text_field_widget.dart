import 'package:together_version_2/providers/add_post_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
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
        context.read<AddPostProvider>().typePostText(value);
      },
    );
  }
}
