import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MainVideoPlayer extends StatefulWidget {
  
  final VideoPlayerController videoController;
  const MainVideoPlayer({super.key, required this.videoController});

  @override
  State<MainVideoPlayer> createState() => _MainVideoPlayerState();
}

class _MainVideoPlayerState extends State<MainVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: Center(
        child: widget.videoController.value.isInitialized
            ? AspectRatio(
                aspectRatio: widget.videoController.value.aspectRatio,
                child: VideoPlayer(widget.videoController),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            widget.videoController.value.isPlaying
                ? widget.videoController.pause()
                : widget.videoController.play();
          });
        },
        child: Icon(
          widget.videoController.value.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
        ),
      ),
    );
  }
}
