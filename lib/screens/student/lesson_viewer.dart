import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/lesson_model.dart';
import '../../utils/constants.dart';

class LessonViewer extends StatefulWidget {
  final LessonModel lesson;
  const LessonViewer({super.key, required this.lesson});

  @override
  State<LessonViewer> createState() => _LessonViewerState();
}

class _LessonViewerState extends State<LessonViewer> {
  late YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    if (widget.lesson.type == 'video' && widget.lesson.youtubeId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: widget.lesson.youtubeId!,
        flags: const YoutubePlayerFlags(autoPlay: false),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.lesson.type == 'video' && _youtubeController != null)
              YoutubePlayer(controller: _youtubeController!),
            if (widget.lesson.type == 'video' && widget.lesson.youtubeId == null)
              const Card(
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No video available', style: TextStyle(color: Colors.white)),
                ),
              ),
            if (widget.lesson.type == 'document')
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('PDF Document - Coming Soon'),
                    ],
                  ),
                ),
              ),
            if (widget.lesson.type == 'text' && widget.lesson.textContent != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(widget.lesson.textContent!),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              widget.lesson.description,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            if (widget.lesson.duration != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Duration: ${widget.lesson.duration}', style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}