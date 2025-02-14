import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../models/audio_file.dart';
import '../models/note.dart';
import '../widgets/banner_ad_widget.dart';

class PlayerScreen extends StatefulWidget {
  final AudioFile audioFile;

  const PlayerScreen({
    super.key,
    required this.audioFile,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final TextEditingController _noteController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AudioProvider>(context, listen: false);
    await provider.setCurrentAudioFile(widget.audioFile);
    setState(() => _isLoading = false);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours > 0 ? '${duration.inHours}:' : '';
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours$minutes:$seconds';
  }

  Widget _buildAudioSlider(AudioProvider audioProvider) {
    final duration = audioProvider.duration?.inSeconds.toDouble() ?? 0;
    final position = audioProvider.position.inSeconds.toDouble();
    // Pozisyon sürenin dışına çıkmasını engelle
    final clampedPosition = position.clamp(0, duration);

    final width = MediaQuery.of(context).size.width - 40;

    return Stack(
      children: [
        // Not işaretleri
        SizedBox(
          height: 30,
          width: width,
          child: Stack(
            children: audioProvider.currentNotes.map((note) {
              final position =
                  duration > 0 ? (note.timestamp / duration) * width : 0;
              return Positioned(
                left: position
                    .clamp(0.0, width)
                    .toDouble(), // Sınırlar içinde tut
                top: 0,
                child: Column(
                  children: [
                    Container(
                      width: 3,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        // Slider
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 16,
              ),
              activeTrackColor: Colors.blue.shade700,
              inactiveTrackColor: Colors.blue.shade100,
              thumbColor: Colors.blue.shade700,
              overlayColor: Colors.blue.shade700.withOpacity(0.2),
            ),
            child: Slider(
              value:
                  clampedPosition.toDouble(), // Sınırlandırılmış değeri kullan
              min: 0,
              max: duration,
              onChanged: (value) {
                audioProvider.seekTo(Duration(seconds: value.toInt()));
              },
            ),
          ),
        ),
      ],
    );
  }

  // Post-it tarzı not widget'ı
  Widget _buildNoteCard(
      Note note, AudioProvider audioProvider, bool isCurrentPosition) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                audioProvider.seekTo(Duration(seconds: note.timestamp));
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sol taraftaki zaman göstergesi
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatDuration(Duration(seconds: note.timestamp)),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Not metni
                    Expanded(
                      child: Text(
                        note.text,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Sağ taraftaki butonlar
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          iconSize: 20,
                          icon: Icon(
                            Icons.play_circle_outline,
                            color: Colors.blue.shade700,
                          ),
                          onPressed: () {
                            audioProvider
                                .seekTo(Duration(seconds: note.timestamp));
                            if (!audioProvider.isPlaying) {
                              audioProvider.playPause();
                            }
                          },
                        ),
                        IconButton(
                          iconSize: 20,
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade400,
                          ),
                          onPressed: () => audioProvider.deleteNote(note.id!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AudioProvider>(
              builder: (context, audioProvider, child) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: [
                    // Üst kısım - Başlık ve müzik ikonu
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Icon(
                            Icons.music_note,
                            size: 60,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.audioFile.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Ses çubuğu ve kontroller
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildAudioSlider(audioProvider),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatDuration(audioProvider.position),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _formatDuration(audioProvider.duration ??
                                        Duration.zero),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          IconButton(
                            iconSize: 48,
                            onPressed: () => audioProvider.playPause(),
                            icon: Icon(
                              audioProvider.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Not ekleme alanı
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              style: const TextStyle(fontFamily: 'Poppins'),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                hintText: 'Not ekle...',
                                hintStyle:
                                    const TextStyle(fontFamily: 'Poppins'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              if (_noteController.text.isNotEmpty) {
                                audioProvider.addNote(_noteController.text);
                                _noteController.clear();
                              }
                            },
                            icon: Icon(
                              Icons.add_circle,
                              color: Colors.blue.shade700,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Notlar listesi
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: audioProvider.currentNotes.length,
                        itemBuilder: (context, index) {
                          final note = audioProvider.currentNotes[index];
                          final isCurrentPosition =
                              (audioProvider.position.inSeconds -
                                          note.timestamp)
                                      .abs() <
                                  1;
                          return _buildNoteCard(
                              note, audioProvider, isCurrentPosition);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const BannerAdWidget(), // Banner reklamı en alta ekle
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
