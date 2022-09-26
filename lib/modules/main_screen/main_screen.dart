import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_downloader/cubit/cubit.dart';
import 'package:youtube_downloader/cubit/states.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var c = MainCubit.get(context);
        return Scaffold(
          extendBody: true,
          backgroundColor: const Color(0xffE7E7E1),
          appBar: AppBar(
            title: Text(
              c.titles[c.currentIndex],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: c.screens[c.currentIndex],
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            backgroundColor: c.video == null ? Colors.grey : Colors.red,
            onPressed: c.video == null
                ? null
                : () {
                    c.getStream();
                  },
            child: state is DownloadVideoLoadingsState
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Icon(
                    Icons.download,
                  ),
          ),
          bottomNavigationBar: BottomAppBar(
              notchMargin: 10,
              shape: const CircularNotchedRectangle(),
              child: Row(
                children: List.generate(c.screens.length, (index) {
                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        c.changeIndex(index);
                        if (c.currentIndex == 1) {
                          c.getDownloadedVideo();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                        child: c.bottomAppBarItem[index],
                      ),
                    ),
                  );
                }),
              )),
        );
      },
    );
  }
}
