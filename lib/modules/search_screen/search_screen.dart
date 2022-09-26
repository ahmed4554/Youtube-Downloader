import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:youtube_downloader/cubit/cubit.dart';
import 'package:youtube_downloader/cubit/states.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../components/components.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var c = MainCubit.get(context);
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: ListView(
              children: [
                Form(
                  key: c.globalKey,
                  child: Material(
                    borderRadius: BorderRadius.circular(50),
                    elevation: 10,
                    shadowColor: Colors.red.withOpacity(.4),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'This Field Must\'n be Empty';
                        } else {}
                      },
                      onFieldSubmitted: (value) {
                        if (c.globalKey.currentState!.validate()) {
                          c.getVideoMetaData(value);
                        }
                      },
                      controller: c.videoController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              c.getVideoMetaData(c.videoController.text);
                            },
                            icon: const Icon(Icons.info_outline_rounded)),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Enter Video URL or Video ID',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                c.video == null
                    ? Center(
                        child: Lottie.asset('assets/lotties/loading.json',
                            repeat: false),
                      )
                    : BuildVideoMetaDataItem(
                        video: c.video as Video,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
