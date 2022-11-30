import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_downloader/cubit/cubit.dart';
import 'package:youtube_downloader/cubit/states.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({
    required this.index,
  });
  final int index;

  @override
  State<VideoScreen> createState() => _VideoScreenState();

}

class _VideoScreenState extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              MainCubit.get(context).videoPlayerController!.dispose();
              MainCubit.get(context).chewieController!.dispose();
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: Text(
            MainCubit.get(context).cachedVideos[widget.index].uri.pathSegments.last,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )),
      body: BlocConsumer<MainCubit, MainStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var c = MainCubit.get(context);
          return c.videoPlayerController != null &&
                  c.videoPlayerController!.value.isInitialized
              ? Center(child: Chewie(controller: c.chewieController as ChewieController,))
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                );
        },
      ),
    );
  }
}
