import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_downloader_plus/modules/audio/audio_screen.dart';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../modules/video/video_screen.dart';

class BuildVideoMetaDataItem extends StatelessWidget {
  const BuildVideoMetaDataItem({
    Key? key,
    required this.video,
  }) : super(key: key);
  final Video video;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: BorderRadius.circular(20),
            elevation: 5,
            shadowColor: Colors.red,
            child: Image(
              image: NetworkImage(
                'https://img.youtube.com/vi/${video.id}/0.jpg',
              ),
              fit: BoxFit.fill,
            )),
        const SizedBox(
          height: 15,
        ),
        Text(
          video.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          video.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const Icon(
              FontAwesomeIcons.thumbsUp,
              color: Colors.red,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              video.watchPage!.videoLikeCount.toString(),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }
}

class BuildButtomAppBarItem extends StatelessWidget {
  BuildButtomAppBarItem({
    Key? key,
    required this.icon,
    required this.label,
    this.index,
  }) : super(key: key);
  final IconData icon;
  final String label;
  int? index;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainStates>(
      listener: (context, state) {},
      builder: (context, state) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: MainCubit.get(context).currentIndex == index
                ? Colors.red
                : Colors.grey,
          ),
          if (MainCubit.get(context).currentIndex == index)
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}

class BuildDownloadedItem extends StatelessWidget {
  const BuildDownloadedItem(
      {Key? key, required this.file, required this.index, required this.image})
      : super(key: key);
  final File file;
  final String image;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: BorderRadius.circular(20),
            elevation: 5,
            shadowColor: Colors.red,
            child: Image(
              image: FileImage(
                File(image),
              ),
              fit: BoxFit.fill,
            )),
        const SizedBox(
          height: 15,
        ),
        Text(
          file.uri.pathSegments.last.replaceAll('.mp4', ''),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          height: 40,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          width: double.infinity,
          child: MaterialButton(
            height: 40,
            color: Colors.red,
            onPressed: () {
              MainCubit.get(context).playVideo(index);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoScreen(index: index),
                ),
              );
            },
            child: const Text(
              'Watch',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class BuildDownloadedItemVideo extends StatelessWidget {
  const BuildDownloadedItemVideo(
      {Key? key, required this.file, required this.index})
      : super(key: key);
  final File file;
  final int index;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AudioScreen(audio: file),
          ),
        );
      },
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(
                Icons.audiotrack_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                file.uri.pathSegments.last.replaceAll('.mp3', ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
      ),
    );
  }
}
