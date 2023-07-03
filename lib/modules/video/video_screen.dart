import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

import '../../constant/constant.dart';
import '../../cubit/cubit.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({
    super.key,
    required this.index,
  });
  final int index;

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  void dispose() {
    videoPlayerController!.dispose();
    chewieController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: Text(
            MainCubit.get(context)
                .cachedVideos[widget.index]
                .uri
                .pathSegments
                .last,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )),
      body: videoPlayerController != null &&
              videoPlayerController!.value.isInitialized
          ? Center(
              child: Chewie(
              controller: chewieController as ChewieController,
            ))
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
    );
  }
}
