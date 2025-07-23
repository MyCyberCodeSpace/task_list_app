import 'dart:io';
import 'package:flutter/material.dart';
import 'package:task_list_app/core/widgets/main_video_player.dart';
import 'package:video_player/video_player.dart';

class MediaFullScreen extends StatefulWidget {
  final File? mediaFile;
  final String? mediaUrl;
  const MediaFullScreen({super.key, this.mediaFile, this.mediaUrl});

  @override
  State<MediaFullScreen> createState() => _MediaFullScreenState();
}

class _MediaFullScreenState extends State<MediaFullScreen> {
  VideoPlayerController? _videoControllerLocal;
  VideoPlayerController? _videoControllerUrl;

  bool isVideoLocal = false;
  bool isVideoNetwork = false;

  @override
  void initState() {
    super.initState();

    if (widget.mediaFile != null) {
      final path = widget.mediaFile!.path.toLowerCase();
      isVideoLocal =
          path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.avi');
      if (isVideoLocal) {
        _videoControllerLocal =
            VideoPlayerController.file(widget.mediaFile!)
              ..initialize().then((_) {
                setState(() {});
              });
      }
    } else if (widget.mediaUrl != null) {
      final path = widget.mediaUrl!.toLowerCase().trim();
      isVideoNetwork =
          path.contains('.mp4') ||
          path.contains('.mov') ||
          path.contains('.avi');
      if (isVideoNetwork) {
        _videoControllerUrl =
            VideoPlayerController.networkUrl(
                Uri.parse(widget.mediaUrl!),
              )
              ..initialize().then((_) {
                setState(() {});
              });
      }
    }
  }

  @override
  void dispose() {
    _videoControllerLocal?.dispose();
    _videoControllerUrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isVideoLocal || isVideoNetwork) {
      if (isVideoLocal) {
        return MainVideoPlayer(
          videoController: _videoControllerLocal!,
        );
      } else {
        return MainVideoPlayer(videoController: _videoControllerUrl!);
      }
    } else {
      if (widget.mediaFile != null) {
        return Scaffold(
          appBar: AppBar(),
          backgroundColor: Colors.black,
          body: Center(
            child: Image.file(
              widget.mediaFile!,
              fit: BoxFit.contain,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
        );
      } else {
        if (widget.mediaUrl != null) {
          if (widget.mediaUrl != '') {
            return Scaffold(
              appBar: AppBar(),
              backgroundColor: Colors.black,
              body: Image.network(
                widget.mediaUrl!,
                fit: BoxFit.contain,
                height: double.infinity,
                width: double.infinity,
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text(
                  "You don't have any media to display here... :(",
                ),
              ),
            );
          }
        } else {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(
                "You don't have any media to display here... :(",
              ),
            ),
          );
        }
      }
    }
  }
}
