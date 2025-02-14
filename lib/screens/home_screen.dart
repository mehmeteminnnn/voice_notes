import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../models/audio_file.dart';
import '../helpers/database_helper.dart';
import 'player_screen.dart';
import '../services/ad_service.dart';
import '../helpers/ad_helper.dart';
import '../widgets/banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AdService _adService = AdService();
  List<AudioFile> _audioFiles = [];
  Map<int, int> _noteCounts = {}; // Her ses dosyası için not sayısı

  @override
  void initState() {
    super.initState();
    _loadAudioFiles();
    _adService.loadInterstitialAd();
  }

  @override
  void dispose() {
    _adService.dispose();
    super.dispose();
  }

  Future<void> _loadAudioFiles() async {
    final audioFiles = await _databaseHelper.getAudioFiles();
    final noteCounts = <int, int>{};

    // Her ses dosyası için not sayısını al
    for (var file in audioFiles) {
      if (file.id != null) {
        final notes = await _databaseHelper.getNotesForAudio(file.id!);
        noteCounts[file.id!] = notes.length;
      }
    }

    setState(() {
      _audioFiles = audioFiles;
      _noteCounts = noteCounts;
    });
  }

  Future<void> _pickAudioFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && context.mounted) {
      String filePath = result.files.single.path!;
      String fileName = result.files.single.name;

      final audioFile = AudioFile(
        title: fileName,
        filePath: filePath,
      );

      await _databaseHelper.insertAudioFile(audioFile);
      await _loadAudioFiles();
    }
  }

  Future<void> _deleteAudioFile(AudioFile audioFile) async {
    await _databaseHelper.deleteAudioFile(audioFile.id!);
    await _loadAudioFiles();
  }

  Future<void> _navigateToPlayerScreen(AudioFile audioFile) async {
    await _adService.showInterstitialAd();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(audioFile: audioFile),
        ),
      ).then((_) => _loadAudioFiles());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Voice Notes',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _audioFiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade50,
                          ),
                          child: Icon(
                            Icons.music_note,
                            size: 80,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Ses dosyası seçerek başlayın',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () => _pickAudioFile(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade700,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade200,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ses Dosyası Ekle',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _audioFiles.length,
                    itemBuilder: (context, index) {
                      final audioFile = _audioFiles[index];
                      final noteCount = _noteCounts[audioFile.id] ?? 0;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.music_note,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          title: Text(
                            audioFile.title,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(
                                Icons.note_alt_outlined,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$noteCount not',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (noteCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$noteCount',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade400,
                                ),
                                onPressed: () => _deleteAudioFile(audioFile),
                              ),
                            ],
                          ),
                          onTap: () => _navigateToPlayerScreen(audioFile),
                        ),
                      );
                    },
                  ),
          ),
          const BannerAdWidget(),
        ],
      ),
      floatingActionButton: _audioFiles.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _navigateToPlayerScreen(_audioFiles[0]),
                backgroundColor: Colors.transparent,
                elevation: 0,
                label: Row(
                  children: [
                    const Icon(Icons.play_arrow),
                    const SizedBox(width: 8),
                    const Text(
                      'Ses Oynat',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
