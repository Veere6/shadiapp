// import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AudioController extends GetxController {
  final _isRecordPlaying = false.obs,
      isRecording = false.obs,
      isSending = false.obs,
      isUploading = false.obs;
  final _currentId = 999999.obs;
  final start = DateTime.now().obs;
  final end = DateTime.now().obs;
  String _total = "";
  String get total => _total;
  var completedPercentage = 0.0.obs;
  var currentDuration = 0.obs;
  var totalDuration = 0.obs;

  bool get isRecordPlaying => _isRecordPlaying.value;
  bool get isRecordingValue => isRecording.value;
  late final AudioPlayerService _audioPlayerService;
  late AudioPlayer _audioPlayer;
  int get currentId => _currentId.value;

  @override
  void onInit() {
    _audioPlayerService = AudioPlayerAdapter();
    _audioPlayer = AudioPlayer();

    // _audioPlayerService.getAudioPlayer.onDurationChanged.listen((duration) {
    //   totalDuration.value = duration.inMicroseconds;
    // });
    _audioPlayer.durationStream.listen((duration) {
      totalDuration.value = duration!.inMicroseconds;
    });

    _audioPlayer.positionStream.listen((duration) {
      currentDuration.value = duration.inMicroseconds;
      completedPercentage.value =
          currentDuration.value.toDouble() / totalDuration.value.toDouble();
    });
    // _audioPlayerService.getAudioPlayer.onPositionChanged.listen((duration) {
    //   currentDuration.value = duration.inMicroseconds;
    //   completedPercentage.value =
    //       currentDuration.value.toDouble() / totalDuration.value.toDouble();
    // });

    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        // Audio playback completed
        _isRecordPlaying.value = false;
      }
    });

    // _audioPlayerService.getAudioPlayer.onPlayerComplete.listen((event) async {
    //   await _audioPlayerService.getAudioPlayer.seek(Duration.zero);
    //   _isRecordPlaying.value = false;
    // });

    super.onInit();
  }

  @override
  void onClose() {
    _audioPlayerService.dispose();
    super.onClose();
  }

  Future<void> changeProg() async {
    if (isRecordPlaying) {

      _audioPlayer.durationStream.listen((duration) {
        totalDuration.value = duration!.inMicroseconds;
      });

      // _audioPlayerService.getAudioPlayer.onDurationChanged.listen((duration) {
      //   totalDuration.value = duration.inMicroseconds;
      // });



      _audioPlayer.positionStream.listen((duration) {
        currentDuration.value = duration.inMicroseconds;
        completedPercentage.value =
            currentDuration.value.toDouble() / totalDuration.value.toDouble();
      });

      // _audioPlayerService.getAudioPlayer.onPositionChanged.listen((duration) {
      //   currentDuration.value = duration.inMicroseconds;
      //   completedPercentage.value =
      //       currentDuration.value.toDouble() / totalDuration.value.toDouble();
      // });
    }
  }

  void onPressedPlayButton(int id, var content) async {
    _currentId.value = id;
    if (isRecordPlaying) {
      await _pauseRecord();
    } else {
      _isRecordPlaying.value = true;
      await _audioPlayerService.play(content);
    }
  }
  void onPressedPlayButton2(int id, var content) async {
    _currentId.value = id;
    if (isRecordPlaying) {
      await _pauseRecord();
    } else {
      _isRecordPlaying.value = true;
      await _audioPlayerService.playFile(content);
    }
  }
  void PauseAudio() async {
    _isRecordPlaying.value = false;
    await _audioPlayerService.pause();
  }

  calcDuration() {
    var a = end.value.difference(start.value).inSeconds;
    format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
    _total = format(Duration(seconds: a));
  }

  Future<void> _pauseRecord() async {
    _isRecordPlaying.value = false;
    await _audioPlayerService.pause();
  }
}

abstract class AudioPlayerService {
  void dispose();
  Future<void> play(String url);
  Future<void> playFile(String url);
  Future<void> resume();
  Future<void> pause();
  Future<void> release();

  AudioPlayer get getAudioPlayer;
}

class AudioPlayerAdapter implements AudioPlayerService {
  late AudioPlayer _audioPlayer;

  @override
  AudioPlayer get getAudioPlayer => _audioPlayer;

  AudioPlayerAdapter() {
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() async {
    await _audioPlayer.dispose();
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> play(String url) async {
    await _audioPlayer.setUrl(url); // Set the audio source from the URL
    await _audioPlayer.play(); // Play the audio
    print("playing ${url}");
  }

  @override
  Future<void> playFile(String url) async {
    await _audioPlayer.setFilePath(url); // Set the audio source from the URL
    await _audioPlayer.play(); // Play the audio
    // await _audioPlayer.play(UrlSource(url));
  }

  @override
  Future<void> release() async {
    await _audioPlayer.stop();
    // await _audioPlayer.release();
  }

  @override
  Future<void> resume() async {
    await _audioPlayer.play();
  }
}

class AudioDuration {
  static double calculate(Duration soundDuration) {
    if (soundDuration.inSeconds > 60) {
      return 70.w;
    } else if (soundDuration.inSeconds > 50) {
      return 65.w;
    } else if (soundDuration.inSeconds > 40) {
      return 60.w;
    } else if (soundDuration.inSeconds > 30) {
      return 55.w;
    } else if (soundDuration.inSeconds > 20) {
      return 50.w;
    } else if (soundDuration.inSeconds > 10) {
      return 45.w;
    } else {
      return 40.w;
    }
  }
}
