import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ucimo_slogove/services/file_service.dart';

class AudioRecord
{
  late String _filePath;
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  bool get isRecording => recorder.isRecording;
  
  bool newAudio = false;

  Future<bool> initRecorder() async
  {
    var status = await Permission.microphone.request();

    while(status == PermissionStatus.denied)
    {
      status = await Permission.microphone.request();
    }
    
    if(status != PermissionStatus.granted)
    {
      openAppSettings();
      return false;
    }

    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));

    return true;
  }

  Future record() async
  {
    if(!isRecorderReady) return;
    
    await recorder.startRecorder(toFile: 'audio_temp');
  }



  Future<String> stop(String syllable) async
  {
    syllable = syllable.replaceAll('đ', 'dd')
      .replaceAll('ž', 'zh')
      .replaceAll('č', 'ch')
      .replaceAll('ć', 'cc')
      .replaceAll('š', 'sh');

    if(!isRecorderReady) return "";

    final path = await recorder.stopRecorder();
    
    String newFileName = '${syllable}_temp.mp3';
    Future<String> newPath = moveAudioFile(path!, newFileName);
    if(newPath.toString() == "error"){return "error";}
    newAudio = true;

    return newPath;
  }

  Future<void> saveAudio(String newSyllable, String oldSyllable) async
  {
    newSyllable = newSyllable.replaceAll('đ', 'dd')
      .replaceAll('ž', 'zh')
      .replaceAll('č', 'ch')
      .replaceAll('ć', 'cc')
      .replaceAll('š', 'sh');

    oldSyllable = oldSyllable.replaceAll('đ', 'dd')
      .replaceAll('ž', 'zh')
      .replaceAll('č', 'ch')
      .replaceAll('ć', 'cc')
      .replaceAll('š', 'sh');

    try{
      await saveAudioFile('${oldSyllable}_temp', newSyllable);
    }
    catch(e)
    {
      print("error in saveAudio");
      return;
    }
    
    print('audio saved');
  }

  String getFilePath(){
    return _filePath;
  }

  Future<void> deleteTemporaryAudio(String syllable) async {
    syllable = syllable.replaceAll('đ', 'dd')
      .replaceAll('ž', 'zh')
      .replaceAll('č', 'ch')
      .replaceAll('ć', 'cc')
      .replaceAll('š', 'sh');
    
    await deleteTempFile('${syllable}_temp');
    print('temp file deleted');
  }

  Future<void> saveExistingAudio(String syllable, String oldSyllable) async
  {
    syllable = syllable.replaceAll('đ', 'dd')
      .replaceAll('ž', 'zh')
      .replaceAll('č', 'ch')
      .replaceAll('ć', 'cc')
      .replaceAll('š', 'sh');
    
    oldSyllable = oldSyllable.replaceAll('đ', 'dd')
      .replaceAll('ž', 'zh')
      .replaceAll('č', 'ch')
      .replaceAll('ć', 'cc')
      .replaceAll('š', 'sh');
      
    try{
      await saveAudioFile(oldSyllable, syllable);
    }
    catch(e)
    {
      print("error in saveExistingAudio");
      return;
    }
    
    print('existing audio saved');
  }
  
  Future<void> disposeRecorder() async {
    await recorder.closeRecorder();
  }
}