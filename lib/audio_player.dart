import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerScreen({super.key, required this.audioUrl});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setSourceUrl(widget.audioUrl);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (isPlaying) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.play(UrlSource(widget.audioUrl));
      }
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Player")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _togglePlayPause,
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            ),
          ],
        ),
      ),
    );
  }
}
