import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_list_app/core/screens/media_entire_screen.dart';

class UserImagePicker extends StatefulWidget {
  final String? mediaUrl;
  final void Function(File) onPickImage;

  const UserImagePicker({
    super.key,
    required this.onPickImage,
    this.mediaUrl,
  });
  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? selectedMedia;

  @override
  void initState() {
    super.initState();
  }

  bool isVideoLocal() {
    if (selectedMedia != null) {
      final path = selectedMedia!.path.toLowerCase();
      return path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.avi');
    }
    return false;
  }

  bool isVideoNetwork() {
    if (widget.mediaUrl != null) {
      final path = widget.mediaUrl!.toLowerCase().trim();
      return path.contains('.mp4') ||
          path.contains('.mov') ||
          path.contains('.avi');
    }
    return false;
  }

  bool anyVideoWasSelected() {
    final file = selectedMedia;
    if (file != null) {
      return isVideoLocal();
    }
    if (widget.mediaUrl != null) {
      return isVideoNetwork();
    }
    return false;
  }

  void _takeMedia(String type, String source) async {
    final ImagePicker picker = ImagePicker();
    XFile? pickedFile;

    if (type == 'image') {
      pickedFile = await picker.pickImage(
        source: source == 'camera'
            ? ImageSource.camera
            : ImageSource.gallery,
      );
    } else if (type == 'video') {
      pickedFile = await picker.pickVideo(
        source: source == 'camera'
            ? ImageSource.camera
            : ImageSource.gallery,
      );
    }

    if (pickedFile == null) return;

    setState(() {
      selectedMedia = File(pickedFile!.path);
    });

    widget.onPickImage(selectedMedia!);
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    Widget? contentPlay;

    if (anyVideoWasSelected()) {
      contentPlay = const Icon(
        Icons.play_circle_fill,
        size: 64,
        color: Colors.white,
      );
    } else if (selectedMedia != null && !isVideoLocal()) {
      imageProvider = FileImage(selectedMedia!);
    } else if (widget.mediaUrl != null && !isVideoNetwork()) {
      if (widget.mediaUrl != '') {
        imageProvider = NetworkImage(widget.mediaUrl!);
      } else {
        imageProvider = null;
      }
    } else {
      imageProvider = null;
    }

    return Column(
      children: [
        GestureDetector(
          child: CircleAvatar(
            radius: 80,
            backgroundColor: Colors.grey,
            foregroundImage: imageProvider,
            child: contentPlay,
          ),

          onTap: () {
            if (selectedMedia != null || widget.mediaUrl != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => MediaFullScreen(
                    mediaFile: selectedMedia,
                    mediaUrl: widget.mediaUrl,
                  ),
                ),
              );
            }
          },
        ),
        Text('Select your media'),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              _takeMedia('image', 'camera'),
                          child: Text("Camera"),
                        ),

                        ElevatedButton(
                          onPressed: () =>
                              _takeMedia('image', 'gallery'),
                          child: Text("Gallery"),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Text("Image"),
            ),

            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              _takeMedia('video', 'camera'),
                          child: Text("Camera"),
                        ),

                        ElevatedButton(
                          onPressed: () =>
                              _takeMedia('video', 'gallery'),
                          child: Text("Gallery"),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Text("Video"),
            ),
          ],
        ),
      ],
    );
  }
}
