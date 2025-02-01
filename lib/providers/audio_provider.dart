import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio_file.dart';
import '../models/note.dart';
import '../helpers/database_helper.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  bool isPlaying = false;
  Duration? duration;
  Duration position = Duration.zero;
  AudioFile? currentAudioFile;
  List<Note> currentNotes = [];

  AudioPlayer get audioPlayer => _audioPlayer;

  void init() {
    // Oynatma durumu değişikliklerini dinle
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying = state.playing;
      notifyListeners();
    });

    // Pozisyon değişikliklerini dinle
    _audioPlayer.positionStream.listen((pos) {
      position = pos;
      notifyListeners();
    });

    // Süre değişikliklerini dinle
    _audioPlayer.durationStream.listen((dur) {
      duration = dur;
      notifyListeners();
    });

    // Hata durumunda
    _audioPlayer.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        print('Bir hata oluştu: $e');
      },
    );
  }

  Future<void> setCurrentAudioFile(AudioFile audioFile) async {
    try {
      currentAudioFile = audioFile;
      await _audioPlayer.setFilePath(audioFile.filePath);
      init(); // Stream dinleyicilerini başlat
      await loadNotes();
      notifyListeners();
    } catch (e) {
      print('Ses dosyası yüklenirken hata: $e');
    }
  }

  Future<void> loadNotes() async {
    if (currentAudioFile != null && currentAudioFile!.id != null) {
      currentNotes =
          await _databaseHelper.getNotesForAudio(currentAudioFile!.id!);
      notifyListeners();
    }
  }

  Future<void> playPause() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      print('Oynatma/duraklatma hatası: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Ses konumu değiştirme hatası: $e');
    }
  }

  Future<void> addNote(String text) async {
    try {
      if (currentAudioFile != null && currentAudioFile!.id != null) {
        final note = Note(
          audioId: currentAudioFile!.id!,
          text: text,
          timestamp: position.inSeconds,
        );
        await _databaseHelper.insertNote(note);
        await loadNotes();
      }
    } catch (e) {
      print('Not ekleme hatası: $e');
    }
  }

  Future<void> deleteNote(int noteId) async {
    try {
      await _databaseHelper.deleteNote(noteId);
      await loadNotes();
    } catch (e) {
      print('Not silme hatası: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
