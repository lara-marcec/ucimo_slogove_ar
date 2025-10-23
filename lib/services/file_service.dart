import 'dart:io';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> moveAudioFile(String sourcePath, String fileName) async {
  try
  {
    var status = await Permission.storage.request();
    print(status);
    while(status == PermissionStatus.denied) {
      status = await Permission.storage.request();
    }
    if(status != PermissionStatus.granted){
      openAppSettings();
      return "error";
    }

    final appDir = await getApplicationDocumentsDirectory();
    final newFilePath = '${appDir.path}/$fileName';

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(fileName.replaceAll('_temp.mp3', ''), false);
    
    File(sourcePath).copy(newFilePath);
    
    return newFilePath;
  }
  catch(e)
  {
    return "";
  }
}

Future<void> deleteTempFile(String tempFileName) async 
{
  var status = await Permission.storage.request();
  print(status);
  while(status == PermissionStatus.denied) {
    status = await Permission.storage.request();
  }
  if(status != PermissionStatus.granted){
    openAppSettings();
    return;
  }

  final Directory tempDir = await getApplicationDocumentsDirectory();
  final String tempPath = tempDir.path;
  final File tempFile = File('$tempPath/$tempFileName.mp3');
  tempFile.delete();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  
  File tempFile2 = File('$tempPath/${tempFileName.replaceAll('_temp', '')}.mp3');
  bool exists = await tempFile2.exists();

  if(!exists)
  {
    prefs.setBool(tempFileName.replaceAll('_temp', ''), true);
  }
}

Future<File?> saveAudioFile(String tempFileName, String newFileName) async { 
  try
  {
    var status = await Permission.storage.request();
    print(status);
    while(status == PermissionStatus.denied) {
      status = await Permission.storage.request();
    }
    if(status != PermissionStatus.granted){
      openAppSettings();
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Directory tempDir = await getApplicationDocumentsDirectory();
    final String tempPath = tempDir.path;

    File tempFile = File('$tempPath/$tempFileName.mp3');
    bool exists = await tempFile.exists();

    if(!exists)
    {
      if(prefs.getBool(tempFileName) != null && prefs.getBool(tempFileName) == true)
      {
        final ByteData bData = await rootBundle.load('assets/sounds/$tempFileName''.mp3');
        final File newFile = File('$tempPath/$newFileName.mp3');

        await newFile.writeAsBytes(bData.buffer.asUint8List(), flush: true);
        print("file saved frfr:  ${newFile.path} -------------------------------------------------------------------");

        prefs.setBool(newFileName, false);

        await tempFile.delete();

        return newFile;
      }
      print("$tempFile doesnt exist");
      tempFile = File('$tempPath/temp_temp.mp3');
    }

    final Uint8List data = await tempFile.readAsBytes();

    final File newFile = File('$tempPath/$newFileName.mp3');

    await newFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    print("file saved frfr:  ${newFile.path} -------------------------------------------------------------------");

    prefs.setBool(newFileName, false);

    await tempFile.delete();

    return newFile;
        
  }
  catch(e)
  {
    print("error in saveAudioFile");
    print(e);
    return null;
  }

}

Future<File> copyAssetToFile(String assetName, String newFileName) async {
  var status = await Permission.storage.request();
  print(status);
  while(status == PermissionStatus.denied) {
    status = await Permission.storage.request();
  }
  if(status != PermissionStatus.granted){
    openAppSettings();
    
  }

  assetName = assetName.replaceAll('đ', 'dd')
    .replaceAll('ž', 'zh')
    .replaceAll('č', 'ch')
    .replaceAll('ć', 'cc')
    .replaceAll('š', 'sh');

  final ByteData data = await rootBundle.load('assets/sounds/$assetName''.mp3');
  final Directory tempDir = await getApplicationDocumentsDirectory();
  final String tempPath = tempDir.path;
  final File tempFile = File('$tempPath/$newFileName''.mp3');
  
  await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
  print("file saved:  $tempPath");

  print("assetName: $assetName");
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(assetName);
  prefs.setBool(newFileName, false);

  return tempFile;
}
