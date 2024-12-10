// ignore_for_file: use_build_context_synchronously

import 'package:together_version_2/pages/chat_page/draggable_scrollable_sheet_page.dart';
import 'package:together_version_2/providers/chat_inputs_provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ChatInputs extends StatefulWidget {
  final TextEditingController messageController;
  final FocusNode messageFocusNode;
  final String emoji;
  final Size size;
  final void Function() onMessageSend;
  final void Function() getImage;
  final void Function() takePhoto;
  final String chatRoomId;

  const ChatInputs({
    super.key,
    required this.messageController,
    required this.messageFocusNode,
    required this.onMessageSend,
    required this.getImage,
    required this.size,
    required this.takePhoto,
    required this.emoji,
    required this.chatRoomId,
  });

  @override
  State<ChatInputs> createState() => _ChatInputsState();
}

class _ChatInputsState extends State<ChatInputs> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(
              child: Row(
                children: [
                  Offstage(
                    offstage:
                        context.watch<ChatInputsProviders>().message.isEmpty,
                    child: IconButton(
                      onPressed: () {
                        widget.messageFocusNode.unfocus();
                        context
                            .read<ChatInputsProviders>()
                            .doNotFocusTextField();
                      },
                      icon: const Icon(
                        Iconsax.arrow_down4,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // File picker Button
                  Offstage(
                    offstage:
                        context.watch<ChatInputsProviders>().message.isNotEmpty,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Iconsax.add_circle5,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Camera picker Button
                  Offstage(
                    offstage:
                        context.watch<ChatInputsProviders>().message.isNotEmpty,
                    child: IconButton(
                      onPressed: widget.takePhoto,
                      icon: const Icon(
                        Iconsax.camera5,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Gallery picker Button
                  Offstage(
                    offstage:
                        context.watch<ChatInputsProviders>().message.isNotEmpty,
                    child: IconButton(
                      onPressed: () async {
                        PermissionStatus status =
                            await Permission.storage.status;

                        if (status.isDenied) {
                          // Request storage permission
                          status = await Permission.storage.request();
                        }

                        if (status.isGranted) {
                          // Permission granted, proceed with accessing storage
                          // Your logic for handling storage access
                          // ignore: use_build_context_synchronously
                          showModalBottomSheet(
                            enableDrag: true,
                            isDismissible: true,
                            shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            showDragHandle: true,
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            elevation: 0,
                            builder: (context) {
                              return DraggableScrollableSheetPage(
                                chatRoomId: widget.chatRoomId,
                              );
                            },
                          );
                        } else {
                          // Permission denied, handle accordingly
                        }
                      },
                      icon: const Icon(
                        Iconsax.gallery5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      child: TextField(
                        maxLines: 4,
                        minLines: 1,
                        focusNode: widget.messageFocusNode,
                        controller: widget.messageController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(8),
                          suffixIcon: IconButton(
                            onPressed: () {
                              widget.messageFocusNode.unfocus();
                              context
                                  .read<ChatInputsProviders>()
                                  .doNotFocusTextField();
                              context.read<ChatInputsProviders>().emojiShowing
                                  ? context
                                      .read<ChatInputsProviders>()
                                      .doNotShowEmoji()
                                  : context
                                      .read<ChatInputsProviders>()
                                      .showEmoji();
                            },
                            icon: Icon(
                              !context.read<ChatInputsProviders>().emojiShowing
                                  ? Iconsax.emoji_happy
                                  : Iconsax.emoji_happy5,
                              color: Colors.black87,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          context
                              .read<ChatInputsProviders>()
                              .typeMessage(value);
                        },
                        onTap: () {
                          context.read<ChatInputsProviders>().focusTextField();
                          context.read<ChatInputsProviders>().doNotShowEmoji();
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onMessageSend,
                    icon:
                        context.watch<ChatInputsProviders>().message.isNotEmpty
                            ? const Icon(
                                Iconsax.send_15,
                                size: 30,
                                color: Colors.black87,
                              )
                            : Text(
                                widget.emoji,
                                style: const TextStyle(fontSize: 25),
                              ),
                  ),
                ],
              ),
            ),
            Offstage(
              offstage: !context.read<ChatInputsProviders>().emojiShowing,
              child: SizedBox(
                height: widget.size.height / 3,
                width: widget.size.width,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    context
                        .read<ChatInputsProviders>()
                        .typeMessage(emoji.toString());
                  },
                  onBackspacePressed: () {},
                  textEditingController: widget.messageController,
                  config: const Config(
                    emojiSizeMax: 24,
                    columns: 7,
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    gridPadding: EdgeInsets.zero,
                    bgColor: Colors.white,
                    indicatorColor: Colors.black87,
                    iconColor: Colors.grey,
                    iconColorSelected: Colors.black87,
                    backspaceColor: Colors.black87,
                    skinToneDialogBgColor: Colors.white,
                    skinToneIndicatorColor: Colors.grey,
                    enableSkinTones: true,
                    recentTabBehavior: RecentTabBehavior.RECENT,
                    recentsLimit: 28,
                    noRecents: Text(
                      'No Recents',
                      style: TextStyle(fontSize: 20, color: Colors.black26),
                      textAlign: TextAlign.center,
                    ), // Needs to be const Widget
                    loadingIndicator:
                        SizedBox.shrink(), // Needs to be const Widget
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    categoryIcons: CategoryIcons(),
                    buttonMode: ButtonMode.MATERIAL,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
