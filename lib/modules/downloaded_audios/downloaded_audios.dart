import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../components/components.dart';
import '../../cubit/cubit.dart';
import '../../cubit/states.dart';

class DownloadedAudios extends StatefulWidget {
  DownloadedAudios({Key? key}) : super(key: key);

  @override
  State<DownloadedAudios> createState() => _DownloadedAudiosState();
}

class _DownloadedAudiosState extends State<DownloadedAudios> {
  bool isRight = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return MainCubit.get(context).audiosCache.isEmpty
            ? SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Lottie.asset('assets/lotties/nodata.json'),
              )
            : SizedBox(
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
                          children: [
                            if (isRight == false)
                              const Expanded(
                                child: Text(
                                  'Delete This File',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            if (isRight == true)
                              const Expanded(
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
                          MainCubit.get(context).audiosCache[index]),
                      onDismissed: (DismissDirection direction) {
                        if (direction == DismissDirection.endToStart) {
                          isRight = true;
                          setState(() {});
                        } else {
                          isRight = false;
                          setState(() {});
                        }
                        MainCubit.get(context).deleteFileAudio(index);
                      },
                      child: BuildDownloadedItemVideo(
                        file: MainCubit.get(context).audiosCache[index],
                        index: index,
                      ),
                    ),
                    itemCount: MainCubit.get(context).audiosCache.length,
                  ),
                ),
              );
      },
    );
  }
}
