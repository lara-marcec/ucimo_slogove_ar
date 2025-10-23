import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:ucimo_slogove/services/audio_record.dart';

class AudioRecordButton extends StatefulWidget 
{
  final String syllable;
  final bool newAudio;
  final bool isRecording;
  final Function(bool) setNewAudio;
  final Function(bool) setIsRecording;

  const AudioRecordButton
  (
    {
      super.key,
      required this.syllable,
      required this.newAudio,
      required this.setNewAudio,
      required this.setIsRecording,
      required this.isRecording,
    }
  );

  @override
  AudioRecordButtonState createState() => AudioRecordButtonState();
}

class AudioRecordButtonState extends State<AudioRecordButton> 
{
  late final AudioRecord _audioRecord;
  late AudioPlayer _audioPlayer;
  late String _filePath = '';

  @override
  void initState() 
  {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioRecord = AudioRecord();
    _initRecorder();
  }
  bool get isRecording => _audioRecord.isRecording;

  Future<void> _initRecorder() async {
    bool result = await _audioRecord.initRecorder();
    if(!result){Navigator.of(context).pop(); return;}
  }


  @override
  Widget build(BuildContext context) {
     return Center
     (
       child: ElevatedButton
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
        child: Row
        (
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon 
              (
                _audioRecord.isRecording ? Icons.stop : Icons.mic,
                size: 40.0,
                applyTextScaling: true,
              ),
            ),
            Flexible
            (
              child: FittedBox
              (
                fit: BoxFit.scaleDown,
                child: Text
                (
                _audioRecord.isRecording ? "ZAUSTAVI SNIMANJE" : "POKRENI SNIMANJE",
                softWrap: true,
                style: TextStyle
                (
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
        onPressed: () async {
          if(_audioRecord.isRecording) 
          {
            widget.setIsRecording(false);
            print(widget.syllable);
            String path;
            
            path = await _audioRecord.stop(widget.syllable);
            if(path == "error") 
            {
              Navigator.of(context).pop();
            }

            setState(() {
              _filePath = path;
              widget.setNewAudio(true);
            });
          }
          else
          {
            widget.setIsRecording(false);
            await _audioRecord.record();
          }
          setState(() {});
        },
      )
    );
  }

  @override
  void dispose() {
    _audioRecord.disposeRecorder();
    super.dispose();
  }
}
