// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:together_version_2/providers/add_status_provider.dart';
import 'package:together_version_2/services/status_services.dart';
import 'package:together_version_2/utils/utils.dart';

class AddStatusPage extends StatelessWidget {
  final File image;
  const AddStatusPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(child: Image.file(image)),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black87,
          child: context.watch<AddStatusProvider>().isPosting
              ? LoadingAnimationWidget.hexagonDots(
                  color: Colors.white, size: 20)
              : const Icon(Icons.check, color: Colors.white),
          onPressed: () async {
            context.read<AddStatusProvider>().startPostingStatus();
            //
            await StatusServices.createStatus(image, context);
            //
            Utils.loadSound('sound/comment.wav');
            context.read<AddStatusProvider>().stopPostingStatus();
            Navigator.pop(context);
          },
        ));
  }
}
