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
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.lesson.type == 'video' && widget.lesson.youtubeId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: widget.lesson.youtubeId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      )..addListener(() {
          if (mounted && !_isPlayerReady) {
            if (_controller.value.isReady) {
              setState(() {
                _isPlayerReady = true;
                _isLoading = false;
              });
            }
          }
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
            if (widget.lesson.type == 'video' && widget.lesson.youtubeId != null)
              Column(
                children: [
                  Container(
                    height: 250,
                    color: Colors.black,
                    child: Stack(
                      children: [
                        YoutubePlayer(
                          controller: _controller,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: AppColors.primary,
                          topActions: const [
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.lesson.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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