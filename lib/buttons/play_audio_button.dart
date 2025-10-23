import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayAudioButton extends StatefulWidget {
  final VoidCallback onPressed;
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final Function(bool) setIsPlaying;

  const PlayAudioButton({
    required this.onPressed,
    required this.audioPlayer,
    required this.isPlaying,
    required this.setIsPlaying,
  });

  @override
  PlayAudioButtonState createState() => PlayAudioButtonState();
}

class PlayAudioButtonState extends State<PlayAudioButton> {
  late bool _isPlaying;
  late StreamSubscription<PlayerState> _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _isPlaying = false;

    _playerStateSubscription = widget.audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        if (mounted) { 
          setState(() {
            _isPlaying = true;
            widget.setIsPlaying(true);
          });
        }
      } else {
        if (mounted) { 
          setState(() {
            _isPlaying = false;
            widget.setIsPlaying(false);
          });
        }
      }
    });
  }

  bool get isPlaying => _isPlaying;

  @override
  void dispose() 
  {
    _playerStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return ElevatedButton
    (
      style: ButtonStyle
      (
        padding: WidgetStateProperty.resolveWith
        (
          (states) => EdgeInsets.all(15.0),
        ),
        backgroundColor: WidgetStateColor.resolveWith
        (
          (states) => Color.fromARGB(255, 217, 237, 255),
        ),
        foregroundColor: WidgetStateColor.resolveWith
        (
          (states) => Colors.black,
        ),
        shape: WidgetStateProperty.resolveWith<OutlinedBorder?>
        (
          (Set<WidgetState> states) 
          {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            );
          },
        ),
      ),
      onPressed: widget.onPressed,
      child: Row
      (
        children: [
          FittedBox
          (
            fit: BoxFit.scaleDown,
            child: Icon
            (
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 40.0,
              applyTextScaling: true,
            ),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'REPRODUCIRAJ',
                softWrap: true,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),


        ],
      ),
    );
  }
}
