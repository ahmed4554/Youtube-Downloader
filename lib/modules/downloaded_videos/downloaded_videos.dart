import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_downloader/components/components.dart';
import 'package:youtube_downloader/cubit/cubit.dart';
import 'package:youtube_downloader/cubit/states.dart';

class DownloadedVideos extends StatelessWidget {
  const DownloadedVideos({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit,MainStates>(
      listener: (context, state) {
        
      },
      builder:(context,state) {
        return Container(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(
              height: 10,
            ),
            itemBuilder: (context, index) => BuildDownloadedItem(
              file: MainCubit.get(context).cachedVideos[index],
              index: index,
            ),
            itemCount: MainCubit.get(context).cachedVideos.length,
          ),
        ),
      );
      },
    );
  }
}
