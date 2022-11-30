import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:youtube_downloader/components/components.dart';
import 'package:youtube_downloader/cubit/cubit.dart';
import 'package:youtube_downloader/cubit/states.dart';

class DownloadedVideos extends StatelessWidget {
  const DownloadedVideos({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return MainCubit.get(context).cachedVideos.isEmpty ||
                MainCubit.get(context).thumbnails.isEmpty
            ? SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Lottie.asset('assets/lotties/nodata.json'),
              )
            : Container(
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                    itemBuilder: (context, index) => Dismissible(
                      background: Container(
                        padding: const EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.red,
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              child: Text(
                                'Delete This File',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Delete This File',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      key: ValueKey<File>(
                          MainCubit.get(context).cachedVideos[index]),
                      onDismissed: (DismissDirection direction) {
                        MainCubit.get(context).deleteFile(index);
                      },
                      child: BuildDownloadedItem(
                        file: MainCubit.get(context).cachedVideos[index],
                        image: MainCubit.get(context).thumbnails[index],
                        index: index,
                      ),
                    ),
                    itemCount: MainCubit.get(context).cachedVideos.length,
                  ),
                ),
              );
      },
    );
  }
}
