import 'dart:developer';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:youtube_downloader_plus/cubit/states.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../components/components.dart';
import '../constant/constant.dart';
import '../modules/downloaded_audios/downloaded_audios.dart';
import '../modules/downloaded_videos/downloaded_videos.dart';
import '../modules/search_screen/search_screen.dart';

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

  List<Widget> screens =  [
    const SearchScreen(),
    DownloadedVideos(),
    DownloadedAudios(),
  ];

  List<String> titles = [
    'YouTube Downloader',
    'Downloaded Videos',
    'Downloaded Audios'
  ];

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
      final dir =
          await Directory('${appDocDir.path}/videos/').create(recursive: true);
      entities = await dir.list().toList();
      cachedVideos = entities.whereType<File>().toList();
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

  void deleteFileAudio(int index) async {
    final File deletedFile = audiosCache[index];
    deletedFile.delete();
    audiosCache.removeAt(index);
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
    getDownloadedAudios();
    getThumbnails();
    log(appDocDir.path);
  }

  Video? video;

  var count = 0;
  double progress = 0;
  List<Video?> searchHistory = [];
  StreamManifest? videoManifest;
  AudioOnlyStreamInfo? audoOnly;
  File? file;
  MuxedStreamInfo? videoInfo;
  late Directory appDocDir;
  void getVideoMetaData(String videoUrl) async {
    emit(GetVideoMetaDataLoadingState());

    try {
      video = await yt!.videos.get(videoUrl);
      emit(GetVideoMetaDataSuccessState());
      getVideoManifest();
      getDownloadedVideo();
    } catch (e) {
      log(e.toString());
      emit(GetVideoMetaDataErrorState());
    }
  }

  void getVideoManifest() async {
    emit(GetVideoManifestLoadingState());
    await yt!.videos.streamsClient
        .getManifest(videoController.text)
        .then((value) {
      videoManifest = value;
      videoInfo = videoManifest!.muxed.withHighestBitrate();
      audoOnly = videoManifest!.audioOnly.withHighestBitrate();
      emit(GetVideoManifestSuccessState());
    }).catchError((e) {
      emit(GetVideoManifestErrorState());
      log(e.toString());
    });
  }

  void createFolderForVideos() async {
    await Directory('${appDocDir.path}/videos/')
        .create(recursive: true)
        .then((value) {
      videos = value;
      log(value.path.toLowerCase());
    });
    if (cachedVideos.isNotEmpty) {
      for (int i = 0; i < cachedVideos.length; i++) {
        if (cachedVideos[i].path.split('/').last.contains('${video!.title}')) {
          log('error');
        } else {
          downloadAndPrepareVideo();
        }
      }
    } else {
      downloadAndPrepareVideo();
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

  void downloadAndPrepareVideo() async {
    var len = videoInfo!.size.totalBytes;
    if (videoInfo != null) {
      var stream = yt!.videos.streamsClient.get(videoInfo as StreamInfo);
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

  // working with audios

  late Directory audios;
  List<File> audiosCache = [];

  void createFolderForAudio() async {
    await Directory('${appDocDir.path}/audios/')
        .create(recursive: true)
        .then((value) {
      audios = value;
    });
    if (audiosCache.isNotEmpty) {
      for (int i = 0; i < audiosCache.length; i++) {
        if (audiosCache[i]
            .path
            .split('/')
            .last
            .contains('${video!.title}')) {
          log('error');
        } else {
          downloadAndPrepareAudioOnly();
        }
      }
    } else {
      downloadAndPrepareAudioOnly();
    }
  }

  List<FileSystemEntity>? audiosEntity;
  void getDownloadedAudios() async {
    if (audiosCache.isEmpty) {
      final dir = Directory('${appDocDir.path}/audios/');
      audiosEntity = await dir.list().toList();
      audiosCache = audiosEntity!.whereType<File>().toList();
      emit(GetAudioCachesSuccess());
    }
  }

  void downloadAndPrepareAudioOnly() async {
    var len = audoOnly!.size.totalBytes;
    if (audoOnly != null) {
      await Permission.storage.request().then((value) async {
        var stream = yt!.videos.streamsClient.get(audoOnly as StreamInfo);
        file = File(
          '${audios.path}${video!.title.replaceAll(r'\', '').replaceAll('/', '').replaceAll('*', '').replaceAll('?', '').replaceAll('"', '').replaceAll('<', '').replaceAll('>', '').replaceAll('|', '')}',
        );
        var fileStream = file!.openWrite(mode: FileMode.writeOnlyAppend);
        emit(DownloadVideoLoadingsState());
        await for (final data in stream) {
          count = count + data.length;
          progress = count / len;
          log(progress.toString());
          emit(ProgressUpadateState());
          fileStream.add(data);
        }
        await fileStream.close().then((value) {
          progress = 0;
        });
        emit(DownloadAudioSucces());
        audiosCache = [];
        getDownloadedAudios();
        log('done');
      });
    }
  }
}
