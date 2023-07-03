import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/cubit.dart';
import '../../cubit/states.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;
  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: animationController);
    animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    // initialize dio object
    super.initState();
  }

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
          floatingActionButton: FloatingActionBubble(
            iconData: Icons.download_rounded,
            iconColor: Colors.white,
            backGroundColor:c.video==null?Colors.grey: Colors.red,
            animation: animation,

            // On pressed change animation state
            onPress: () {
              if (c.video != null) {
                animationController.isCompleted
                    ? animationController.reverse()
                    : animationController.forward();
              }
            },
            items: [
              Bubble(
                icon: Icons.video_collection_outlined,
                iconColor: c.video == null ? Colors.grey : Colors.red,
                title: 'Download Video',
                titleStyle: const TextStyle(
                  color: Colors.white,
                ),
                bubbleColor: Colors.red,
                onPress: c.video == null
                    ? () {}
                    : () {
                        c.createFolderForVideos();
                      },
                // ),
              ),
              Bubble(
                icon: Icons.audiotrack_rounded,
                iconColor: c.video == null ? Colors.grey : Colors.red,
                title: 'Download audio',
                titleStyle: const TextStyle(
                  color: Colors.white,
                ),
                bubbleColor: Colors.red,
                onPress: c.video == null
                    ? () {}
                    : () {
                        c.createFolderForAudio();
                      },
                // ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.red,
            currentIndex: c.currentIndex,
            onTap: (index) {
              c.changeIndex(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                ),
                label: 'search',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.video_collection_rounded,
                ),
                label: 'Video',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.audiotrack_rounded,
                ),
                label: 'Audio',
              ),
            ],
          ),
        );
      },
    );
  }
}
