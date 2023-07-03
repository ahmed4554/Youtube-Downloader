import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:youtube_downloader_plus/constant/constant.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({
    super.key,
    required this.audio,
  });
  final File audio;

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  AudioPlayer player = AudioPlayer();
  Duration musicLen = Duration.zero;
  Duration newPos = Duration.zero;
  bool isPlaying = false;
  bool isCompleted = false;
  @override
  void initState() {
    setAudio();
    player.onPositionChanged.listen((event) {
      newPos = event;
      setState(() {});
    });
    player.onPlayerStateChanged.listen((event) {
      isPlaying = event == PlayerState.playing;
      setState(() {});
    });
    player.onDurationChanged.listen((event) {
      musicLen = event;
      setState(() {});
    });

    super.initState();
  }

  Future<void> setAudio() async {
    player.setReleaseMode(ReleaseMode.loop);
    try {
      await player.play(DeviceFileSource(widget.audio.path),mode: PlayerMode.mediaPlayer,);
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          widget.audio.path.split('/').last.replaceAll('mp3', ''),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset('assets/lotties/music.json'),
            const SizedBox(
              height: 10,
            ),
            Slider(
              min: 0,
              max: musicLen.inSeconds.toDouble(),
              value: newPos.inSeconds.toDouble(),
              onChanged: (value) async {
                final Duration duration = Duration(seconds: value.toInt());
                await player.seek(duration);
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  printDuration(newPos),
                ),
                Text(
                  printDuration(musicLen),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            CircleAvatar(
              backgroundColor: Colors.red,
              radius: 25,
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  isPlaying ? player.pause() : player.resume();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
