import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucimo_slogove/services/croatian_alphabet_sort.dart';

class SyllableService
{
  late List<String> _syllableFilenames;
  late List<String> _selectedSyllableFilenames;

  SyllableService()
  {
    _syllableFilenames = [];
    _selectedSyllableFilenames = [];
  }

  Future<void> loadSyllableFilenames() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (prefs.containsKey('syllables')) {
      _syllableFilenames = prefs.getStringList('syllables')!;
      _selectedSyllableFilenames = prefs.getStringList('selectedSyllables')!;
      
      _syllableFilenames = _syllableFilenames.toList()..sort(croatianSort);
      _selectedSyllableFilenames = _selectedSyllableFilenames.toList()..sort(croatianSort);

      return;
    }
    else{
      loadDefaultSyllables(); 
    }
    
    return;
  }
  

  Future<void> loadSyllablesDivided() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String>? syllFilenames = prefs.getStringList('syllables');

    if(prefs.getStringList('syllablesDivided') != null ){
      return;
    }

    List<String> syllDivided = [];

    for(String syll in syllFilenames!) {
      if( syll.length == 2 ) {
        String tempString = '${syll[0]}-${syll[1]}';
        syllDivided.add(tempString);
      }
      else if( syll.length == 3 ){
        if(syll.startsWith('nj') || syll.startsWith('lj') || syll.startsWith('dž')) {
          String tempString = '${syll[0]}${syll[1]}-${syll[2]}';
          syllDivided.add(tempString);
        }
        else{
          String tempString = '${syll[0]}-${syll[1]}${syll[2]}';
          syllDivided.add(tempString);
        }
      }
      else if( syll.length == 4 ){
        String tempString = '${syll[0]}-${syll[1]}${syll[2]}${syll[3]}';
        syllDivided.add(tempString);
      }
    }

    syllDivided = syllDivided.toList()..sort(croatianSort);

    prefs.setStringList('syllablesDivided', syllDivided);
    
  }

  List<String> getSyllableFilenames()
  {
    return _syllableFilenames;
  }

  List<String> getSelectedSyllableFilenames()  {
    return _selectedSyllableFilenames;
  }

  Future<void> loadSyllableCategories() async 
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? syllables = prefs.getStringList('syllables');

    if(prefs.getStringList('2Slova') != null || prefs.getStringList('3Slova') != null){
      return;
    }

    List<String> category2Letters = [];
    List<String> category3Letters = [];
    
    for(String s in syllables!) 
    {
      if(s.length == 2)
      {
        category2Letters.add(s);
      }
      else if(s.length >= 3)
      {
        if(s.startsWith('nj') || s.startsWith('lj') || s.startsWith('dž') || s.contains("nj") || s.contains('lj') || s.contains('dž') ) 
        {
          category2Letters.add(s);
        }
        else {
          category3Letters.add(s);
        }
      }
    }
    category3Letters = category3Letters.toList()..sort(croatianSort);
    category2Letters = category2Letters.toList()..sort(croatianSort); 

    prefs.setStringList('2Slova', category2Letters);
    prefs.setStringList('3Slova', category3Letters);
  }

  Future<void> loadDefaultSyllables() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? defaultSyllables = prefs.getStringList('syllables');

    if(defaultSyllables == null)
    {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      defaultSyllables = manifestMap.keys
          .where((String key) => key.startsWith('assets/sounds/'))
          .map((String key) => key
              .replaceFirst('assets/', '')
              .replaceAll('.mp3', '')
              .replaceAll('sounds/', '')
              .replaceAll('dd', 'đ')
              .replaceAll('zh', 'ž')
              .replaceAll('ch', 'č')
              .replaceAll('cc', 'ć')
              .replaceAll('sh', 'š'))
          .toList();
      defaultSyllables = defaultSyllables.toList()..sort(croatianSort);
      prefs.setStringList('syllables', defaultSyllables);
    }

    for(String s in defaultSyllables) 
    {
      s = s.replaceAll('đ', 'dd')
        .replaceAll('ž', 'zh')
        .replaceAll('č', 'ch')
        .replaceAll('ć', 'cc')
        .replaceAll('š', 'sh');

      if(prefs.getBool(s) == null){
        prefs.setBool(s, true);
      }
      
    }

    prefs.setStringList('selectedSyllables', defaultSyllables);
    

    return;
  }

}