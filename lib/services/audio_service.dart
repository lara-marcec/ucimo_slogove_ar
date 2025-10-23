import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'syllable_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class AudioService {
  late final SyllableService _syllableService = SyllableService();
  late AudioPlayer _audioPlayer;

  AudioService() {
    _audioPlayer = AudioPlayer();
  }

  Future<String> playRandomSyllable() async {
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool? izgovor = prefs.getBool('izgovor');

    await _syllableService.loadSyllableFilenames();
    final List<String> syllableList = _syllableService.getSelectedSyllableFilenames(); 
    print('selected syllables list: ');
    print(syllableList);
    
    if (syllableList.isNotEmpty) {
      final random = Random();

      final newSyllableIndex = random.nextInt(syllableList.length );

      final filename = syllableList[newSyllableIndex];
      
      if(izgovor == true){
        await playSound(filename);
      }
      
      return filename;
    }
    throw Exception('No syllable filenames loaded');
  }


  Future<void> playSound(String filename) async 
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    filename = filename.replaceAll('đ', 'dd')
            .replaceAll('ž', 'zh')
            .replaceAll('č', 'ch')
            .replaceAll('ć', 'cc')
            .replaceAll('š', 'sh');

    final bool? isInAssets = prefs.getBool(filename);
    print("filename in play sound: $filename");
    if(isInAssets == true) 
    {
      final source = AssetSource("sounds/$filename"".mp3");

      try{
        await _audioPlayer.play(source);
      }
      catch(e)
      {
        return;
      }
      
    }
    else
    {
      final appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/$filename''.mp3';

      try{
        await _audioPlayer.play(UrlSource(filePath));
      }
      catch(e)
      {
        return;
      }      
    }

  }

  void dispose() {
    _audioPlayer.dispose();
  }

  AudioPlayer getAudioPlayer() {
    return _audioPlayer;
  }



}
