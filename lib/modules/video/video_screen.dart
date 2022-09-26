import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_downloader/cubit/cubit.dart';
import 'package:youtube_downloader/cubit/states.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({
    required this.index,
  });
  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              MainCubit.get(context).videoPlayerController!.dispose();
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: Text(
            MainCubit.get(context).cachedVideos[index].uri.pathSegments.last,
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
              ? InkWell(
                  onTap: () {
                    c.videoPlayerController!.value.isPlaying
                        ? c.pauseVideo()
                        : c.videoPlayerController!.play().then((value) {
                            c.emit(VideoingPlayin());
                          });
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: AspectRatio(
                      aspectRatio: c.videoPlayerController!.value.aspectRatio,
                      child: Stack(
                        children: [
                          VideoPlayer(c.videoPlayerController!),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: VideoProgressIndicator(
                                c.videoPlayerController
                                    as VideoPlayerController,
                                allowScrubbing: true,
                              ),
                            ),
                          ),
                          state is VideoingPlayin ||
                                  c.videoPlayerController!.value.isPlaying
                              ? const SizedBox()
                              : Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  color: Colors.red.withOpacity(.3),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                )
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
