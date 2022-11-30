import 'dart:developer';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
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
  List<String> thumbnails = [];

  void getDownloadedVideo() async {
    if (cachedVideos.isEmpty) {
      final dir = Directory('${appDocDir.path}/videos/');
      entities = await dir.list().toList();
      cachedVideos = entities.whereType<File>().toList();
      log(cachedVideos.toString());
      getThumbnails();
      emit(GetCachedVideosState());
    }
  }

  void deleteFile(int index) async {
    final File deletedFile = cachedVideos[index];
    deletedFile.delete();
    cachedVideos.removeAt(index);
    thumbnails.removeAt(index);
    emit(FileDeletedState());
  }

  Directory? thumbnail;
  Directory? videos;

  void getThumbnails() async {
    if (thumbnails.isEmpty) {
      thumbnail = await Directory('${appDocDir.path}/thumnails/')
          .create(recursive: true);
      for (var elment in cachedVideos) {
        await VideoThumbnail.thumbnailFile(
          video: elment.path,
          thumbnailPath: thumbnail!.path,
          imageFormat: ImageFormat.PNG,
          quality: 10,
        ).then((value) {
          thumbnails.add(value as String);
          emit(GetThumnailsSuccess());
          log(thumbnails.length.toString());
        }).catchError((e) {
          emit(GetThumnailsError());
          log(e.toString());
        });
      }
    }
  }

  void initialAppDirectory() async {
    appDocDir = await getApplicationDocumentsDirectory();
      getDownloadedVideo();
      getThumbnails();
    log(appDocDir.path);
  }

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  Video? video;

  var count = 0;
  double progress = 0;
  List<Video?> searchHistory = [];
  StreamManifest? manifest;
  File? file;
  MuxedStreamInfo? streamInfo;
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
    await Directory('${appDocDir.path}/videos/')
        .create(recursive: true)
        .then((value) {
      videos = value;
      log(value.path.toLowerCase());
    });
    if (cachedVideos.isNotEmpty) {
      for (int i = 0; i < cachedVideos.length; i++) {
        if (cachedVideos[i].path.contains('${video!.title}.mp4')) {
          log('error');
        } else {
          downloadAndPrepareFile();
        }
      }
    } else {
      downloadAndPrepareFile();
    }
  }

  void playVideo(int index) {
    videoPlayerController = VideoPlayerController.file(cachedVideos[index])
      ..initialize().then((value) {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController as VideoPlayerController,
          allowFullScreen: true,
          allowMuting: true,
          allowPlaybackSpeedChanging: true,
          allowedScreenSleep: false,
        );
        emit(VideoingPlayin());
      }).catchError((e) {});
  }

  void clearSearchItem() {
    video = null;
    videoController.clear();
    emit(ClearSearchItemState());
  }

  void downloadAndPrepareFile() async {
    var len = streamInfo!.size.totalBytes;
    if (streamInfo != null) {
      var stream = yt!.videos.streamsClient.get(streamInfo as StreamInfo);
      await Permission.storage.request().then((value) async {
        file = File('${videos!.path}${video!.title}.mp4');
        var fileStream = file!.openWrite(mode: FileMode.writeOnlyAppend);
        emit(DownloadVideoLoadingsState());
        // await stream.pipe(fileStream);
        await for (final data in stream) {
          count += data.length;
          progress = (count / len) / 2;
          log(progress.toString());
          emit(ProgressUpadateState());
          fileStream.add(data);
        }
        await fileStream.close().then((value) {
          progress = 0;
        });
        emit(DownloadVideoSuccessState());
        cachedVideos = [];
        thumbnails = [];
        getDownloadedVideo();
        getThumbnails();
        emit(GetCachedVideosState());
        log('done');
      });
    } else {
      emit(DownloadVideoErrorState());
    }
  }
}
