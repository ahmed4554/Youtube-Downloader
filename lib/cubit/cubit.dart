import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_downloader/components/components.dart';
import 'package:youtube_downloader/cubit/states.dart';
import 'package:youtube_downloader/modules/downloaded_videos/downloaded_videos.dart';
import 'package:youtube_downloader/modules/search_screen/search_screen.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MainCubit extends Cubit<MainStates> {
  MainCubit() : super(InitialState());
  static MainCubit get(BuildContext context) => BlocProvider.of(context);
  late YoutubeExplode? yt;
  var videoController = TextEditingController();
  var globalKey = GlobalKey<FormState>();
  void initialYouTubeClient() {
    yt = YoutubeExplode();
    emit(InitialYouTubeClientState());
  }

  List<Widget> screens = const [
    SearchScreen(),
    DownloadedVideos(),
  ];

  List<String> titles = ['YouTube Downloader', 'Downloaded Videos'];

  List<BuildButtomAppBarItem> bottomAppBarItem = [
    BuildButtomAppBarItem(
      icon: Icons.search,
      label: 'Search',
      index: 0,
    ),
    BuildButtomAppBarItem(
      icon: Icons.menu,
      label: 'Downloaded ',
      index: 1,
    ),
  ];

  int currentIndex = 0;

  void changeIndex(int index) {
    currentIndex = index;
    emit(ChangeCurrentIndexState());
  }

  List<FileSystemEntity> entities = [];
  List<File> cachedVideos = [];

  void getDownloadedVideo() async {
    final dir = Directory(appDocDir.path);
    entities = await dir.list().toList();
    cachedVideos = entities.whereType<File>().toList();
    emit(GetCachedVideosState());
  }

  void initialAppDirectory() async {
    appDocDir = await getApplicationDocumentsDirectory();
    log(appDocDir.path);
  }

  VideoPlayerController? videoPlayerController;

  Video? video;
  var count = 0;
  List<Video?> searchHistory = [];
  StreamManifest? manifest;
  File? file;
  var streamInfo;
  late Directory appDocDir;
  void getVideoMetaData(String videoUrl) async {
    emit(GetVideoMetaDataLoadingState());
    await yt!.videos.get(videoUrl).then((value) {
      video = value;
      getVideoManifest();
      getDownloadedVideo();
      emit(GetVideoMetaDataSuccessState());
    }).catchError((e) {
      log(e.toString());
      emit(GetVideoMetaDataErrorState());
    });
  }

  void getVideoManifest() async {
    emit(GetVideoManifestLoadingState());
    await yt!.videos.streamsClient
        .getManifest(videoController.text)
        .then((value) {
      manifest = value;
      streamInfo = manifest!.muxed.withHighestBitrate();
      emit(GetVideoManifestSuccessState());
    }).catchError((e) {
      emit(GetVideoManifestErrorState());
      log(e.toString());
    });
  }

  void getStream() async {
    for (int i = 0; i < cachedVideos.length; i++) {
      if (cachedVideos[i].path.contains('${video!.title}.mp4')) {
        log('error');
      } else {
        if (streamInfo != null) {
          var stream = yt!.videos.streamsClient.get(streamInfo);
          await Permission.storage.request();
          file = File('${appDocDir.path}/${video!.title}.mp4');
          var fileStream = file!.openWrite(mode: FileMode.writeOnlyAppend);
          emit(DownloadVideoLoadingsState());
          await stream.pipe(fileStream);
          await fileStream.flush();
          await fileStream.close();
          emit(DownloadVideoSuccessState());
          log('done');
          return;
        } else {
          emit(DownloadVideoErrorState());
        }
      }
    }
  }

  void playVideo(int index) {
    videoPlayerController = VideoPlayerController.file(cachedVideos[index])
      ..initialize().then((value) {
        videoPlayerController!.play();
        emit(VideoingPlayin());
      }).catchError((e) {});
  }

  void pauseVideo() {
    videoPlayerController!.pause();
    emit(PauseVideo());
  }
}
