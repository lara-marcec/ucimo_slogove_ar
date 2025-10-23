import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucimo_slogove/buttons/audio_record_button.dart';
import 'package:ucimo_slogove/buttons/play_audio_button.dart';
import 'package:ucimo_slogove/dialogs/alert_syllable_dialog.dart';
import 'package:ucimo_slogove/services/audio_record.dart';
import 'package:ucimo_slogove/services/audio_service.dart';
import 'package:ucimo_slogove/services/file_service.dart';
import 'package:ucimo_slogove/buttons/cancel_dialog_button.dart';
import 'package:ucimo_slogove/buttons/save_dialog_button.dart';

class EditSyllableDialog extends StatefulWidget {
  final String syllable;
  final String category;
  final String sDivided;

  const EditSyllableDialog({
    required this.syllable,
    required this.category,
    required this.sDivided,
    super.key,
  });

  @override
  EditSyllableDialogState createState() => EditSyllableDialogState();
}

class EditSyllableDialogState extends State<EditSyllableDialog> {
  String _newSyllable = '';
  String _newCategory = '';
  late ScrollController _scrollController;
  late bool newAudio;

  AudioRecord _audioRecord = AudioRecord();
  AudioService _audioService = AudioService();

  bool isRecording = false;
  bool isPlaying = false;

  @override
  void initState() {
    _newSyllable = widget.sDivided;
    _newCategory = widget.category;
    newAudio = false;
    isRecording = false;
    isPlaying = false;
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() 
  {
    _scrollController.dispose();
    super.dispose();
  }

  void _displayAlertDialog(bool isValid) async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? syllables =  prefs.getStringList('syllables');
    if(syllables!.isNotEmpty)
    {
      showDialog
      (
        context: context,
        builder: (BuildContext context) 
        {
          return AlertSyllableDialog
          (
            getCategory: getCategory,
            newAudio: newAudio,
            newSyllable: _newSyllable,
            syllablesList: syllables ,
            isValid: isValid,
            checkAudio: false,
          );
        },
      );
    }
    else
    {
      Navigator.of(context).pop();
      throw Exception();
    }
  }

  Future<void> saveAndReturnResult() async 
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? syllables =  prefs.getStringList('syllables');


    _newSyllable = _newSyllable.toLowerCase();
    final RegExp pattern = RegExp(r'^[a-zA-ZčČćĆđĐšŠžŽ-]+$');
    bool isValid = pattern.hasMatch(_newSyllable);

    if(isValid)
    {
      int hyphenCount = _newSyllable.split("-").length -1;
      if(hyphenCount != 1)
      {
        isValid = false;
      }
      else if(_newSyllable.startsWith("-") || _newSyllable.endsWith("-"))
      {
        isValid = false;
      }
    }

    String newSyll = _newSyllable.replaceAll("-", "");
    
    setState(() {
      _newCategory = getCategory(_newSyllable);
    });

    if(newSyll != widget.syllable || !isValid)
    {
      if(isValid == false || newSyll == "" || _newCategory == "" || syllables!.contains(newSyll) || !_newSyllable.contains("-") || getCategory(_newSyllable).isEmpty )
      {
        return _displayAlertDialog(isValid);
      }
    }
    
    await saveNewSyllable();
    await saveNewCategory();

    //saveAudio();

    if (newAudio == true) {
      await _audioRecord.saveAudio(newSyll, widget.syllable);
    }
    else if(newSyll != widget.syllable)
    {
      await _audioRecord.saveExistingAudio(newSyll, widget.syllable);
    }
    print(newAudio);
    
    Navigator.of(context).pop(true); 
  }

  Future<void> discardChanges() async {
    if(newAudio == true)
    {
      saveAudio();
      await _audioRecord.deleteTemporaryAudio(widget.syllable);
      
    }
  }

  Future<void> saveNewCategory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? syllables2Category = prefs.getStringList('2Slova');
    final List<String>? syllables3Category = prefs.getStringList('3Slova');
    String newSyll = _newSyllable.replaceAll("-", "");

    setState(() {
      _newCategory = getCategory(_newSyllable);
    });

    if(widget.category != _newCategory)
    {
      if(syllables3Category != null && syllables2Category != null)
      {
        if(widget.category == "slogovi dva slova")
        {
          syllables2Category.remove(newSyll);
          syllables3Category.add(newSyll);
        }
        else
        {
          syllables3Category.remove(newSyll);
          syllables2Category.add(newSyll);
        }
        prefs.setStringList('2Slova', syllables2Category);
        prefs.setStringList('3Slova', syllables3Category);
      }
    }
  }
  
  TextStyle inputStyle () {
    return TextStyle
    (
      
      fontSize: 20.0,
      color: Colors.black,

    );
  }

  TextStyle labelStyle () {
    return TextStyle
    (
      fontSize: 22.0,
      fontWeight: FontWeight.w600,
      color: Colors.black
    );
  }

  Widget buildPlayButton() 
  {
    return PlayAudioButton
    (
      onPressed: () {
        saveAudio();
        if(newAudio == true)
        {
          print("new audio is about to play");
          _audioService.playSound('${widget.syllable}_temp');
        }
        else
        {
          _audioService.playSound(widget.syllable);
        }
        
      },
      audioPlayer: _audioService.getAudioPlayer(),
      isPlaying: isPlaying,
      setIsPlaying: (bool value) {
        setState(() {
          isPlaying = !isPlaying;
        });
      },
    );
  }

  Future<void> saveAudio() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isInAssets = prefs.getBool(widget.syllable);
    if(isInAssets == true)
    { //true jedino za !newAudio
      copyAssetToFile(widget.syllable, widget.syllable);
    }
  }
  
  Future<void> saveNewSyllable() async 
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? syllables = prefs.getStringList('syllables');
    final List<String>? syllablesDivided = prefs.getStringList('syllablesDivided');
    List<String>? selectedSyllables = prefs.getStringList('selectedSyllables');
    final List<String>? syllablesCategory;
    if(widget.category == "slogovi dva slova"){
      syllablesCategory = prefs.getStringList('2Slova');
    }
    else{
      syllablesCategory = prefs.getStringList('3Slova');
    }

    _newSyllable = _newSyllable.toLowerCase();

    String newSyll = _newSyllable.replaceAll("-", "");
    if(syllables != null){
      for(String s in syllables) 
      {
        if(s == widget.syllable )
        {
          syllables.remove(s);
          syllables.add(newSyll);
          prefs.setStringList('syllables', syllables);
        }
      }
    }
    if(selectedSyllables != null){
      for(String s in selectedSyllables) 
      {
        if(s == widget.syllable )
        {
          selectedSyllables.remove(s);
          selectedSyllables.add(newSyll);
          prefs.setStringList('selectedSyllables', selectedSyllables);
        }
      }
    }
    if(syllablesDivided != null){
      for(String s in syllablesDivided) 
      {
        if(s == widget.sDivided )
        {
          syllablesDivided.remove(s);
          syllablesDivided.add(_newSyllable);
          prefs.setStringList('syllablesDivided', syllablesDivided);
        }
      }
    }

    if(syllablesCategory!= null){
      for(String s in syllablesCategory) 
      {
        if(s == widget.syllable )
        {
          syllablesCategory.remove(s);
          syllablesCategory.add(newSyll);
          widget.category == "slogovi dva slova" ?
          prefs.setStringList('2Slova', syllablesCategory) : prefs.setStringList('3Slova', syllablesCategory);
        }
      }
    }
    print(prefs.getStringList('syllables'));
  }
  
  String getCategory(String newSyll)
  {
    
    String s = newSyll.replaceAll("-", "");

    if(s.length == 2)
    {
      if( s.contains("nj") || s.contains('lj') || s.contains('dž') ) 
      {
        return "";
      }
      else {
        return "slogovi dva slova";
      }
    }
    else if(s.length == 3)
    {
      if(s.startsWith('nj') || s.startsWith('lj') || s.startsWith('dž') 
        || s.contains("nj") || s.contains('lj') || s.contains('dž') ) 
      {
        return "slogovi dva slova";
      }
      else {
        return "slogovi tri slova";
      }
    }
    else if(s.length == 4 && (s.contains("nj") || s.contains('lj') || s.contains('dž')) )
    {
      if(s.contains("nj"))
      {
        s = s.replaceFirst("nj", "");
        if(s.contains("nj") || s.contains('lj') || s.contains('dž'))
        {
          return "slogovi dva slova";
        }
        else 
        {
          return "slogovi tri slova";
        }
      }
      else if(s.contains("lj"))
      {
        s = s.replaceFirst("lj", "");
        if(s.contains("nj") || s.contains('lj') || s.contains('dž'))
        {
          return "slogovi dva slova";
        }
        else 
        {
          return "slogovi tri slova";
        }
      }
      else if(s.contains("dž"))
      {
        s = s.replaceFirst("dž", "");
        if(s.contains("nj") || s.contains('lj') || s.contains('dž'))
        {
          return "slogovi dva slova";
        }
        else 
        {
          return "slogovi tri slova";
        }
      }
      else 
      {
        return "slogovi tri slova";
      }
    }
    return "";
  }

  Widget buildCancelButton(Orientation orientation) 
  {
    return CancelDialogButton
    (
      onPressed: () 
      {
        discardChanges();
        Navigator.of(context).pop();
      },
      orientation: orientation,
    );
  }

  Widget buildSaveButton(Orientation orientation) 
    {
    return SaveDialogButton
    (
      onPressed: () {
        saveAndReturnResult();
      },
      orientation: orientation,
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return StatefulBuilder
    (
      builder: (BuildContext context, setState)
      {
      return OrientationBuilder
      (
        builder: (context, orientation) 
        {
          return AlertDialog
          (
            surfaceTintColor: Colors.transparent,
            actionsPadding: EdgeInsets.all(5.0),
            contentPadding: EdgeInsets.only(left: 15.0, right:15.0),
            content: Padding
            (
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Scrollbar
              (
                controller: _scrollController,
                radius: Radius.circular(15.0),
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 20.0,
                interactive: true,
                child: SizedBox
                (
                  width: orientation == Orientation.landscape ? MediaQuery.of(context).size.width / 2.5 : MediaQuery.of(context).size.width / 1.5,
                  height: orientation == Orientation.landscape ? MediaQuery.of(context).size.height / 2.0 : MediaQuery.of(context).size.height / 2.0 ,
                  child: SingleChildScrollView
                  (
                    controller: _scrollController,
                    child: Container
                    (
                      padding: EdgeInsets.only(right: 30.0),
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(10),
                      child: Column
                      (
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: 
                        [
                          TextFormField
                          (
                            maxLength: 5,
                            style: inputStyle(),
                            initialValue: widget.sDivided,
                            decoration: InputDecoration
                            (
                              labelStyle: labelStyle(),
                              labelText: "SLOG: "
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _newSyllable = newValue?.toLowerCase() ?? ''; 
                              });
                            },
                                    
                          ),
                          Container
                          (
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            alignment: Alignment.centerLeft,
                            child: 
                            getCategory(_newSyllable) != "" ? Text
                            (
                              "KATEGORIJA: ${getCategory(_newSyllable)}",
                              style: TextStyle
                              (
                                
                                fontSize: 17.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,

                              ),
                            ) : !_newSyllable.contains("-") &&  getCategory(_newSyllable) != "" ? 
                            Text
                            (
                              "Slog mora sadržavati oznaku za naglašavanje (primjer ispravnog unosa: k-ra).",
                              style: TextStyle
                              (
                                
                                fontSize: 17.0,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 184, 13, 1),

                              ),
                            ) :
                            Text
                            (
                              "Unesite slog duljine dva ili tri slova.",
                              style: TextStyle
                              (
                                
                                fontSize: 17.0,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 184, 13, 1),

                              ),
                            ),
                          ),
                                                              
                          Padding
                          (
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Center(
                              child: Column
                              (
                                children: 
                                [
                                  Container
                                  (
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text
                                    (
                                      "ZVUČNI ZAPIS: ", 
                                      style: TextStyle
                                      (
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600
                                      )
                                    )
                                  ),
                                  Container
                                  (
                                    alignment: Alignment.center,
                                    child: orientation == Orientation.landscape ? 
                                    Row
                                    (
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: 
                                      [
                                        Padding
                                        (
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox
                                          (
                                            width: MediaQuery.of(context).size.width / 3.2,
                                            child: IgnorePointer
                                            (
                                              ignoring: isPlaying,
                                              child: AudioRecordButton
                                              (
                                                syllable: widget.syllable,
                                                newAudio: newAudio,
                                                isRecording: isRecording,
                                                setNewAudio: (bool value) {
                                                  setState(() {
                                                    newAudio = value;
                                                  });
                                                },
                                                setIsRecording: (bool value) {
                                                  setState(() {
                                                    isRecording = !isRecording;
                                                  });
                                                },
                                              ),
                                            )
                                          ),
                                        ),
                                    
                                        Padding
                                        (
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox
                                          (
                                            width: MediaQuery.of(context).size.width / 3.2,
                                            child: IgnorePointer
                                            (
                                              ignoring: isRecording,
                                              child: buildPlayButton()
                                            )
                                          ),
                                        ), 
                                      ]
                                    ) :
                                    Column
                                    (
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: 
                                      [
                                        Padding
                                        (
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox
                                          (
                                            width: MediaQuery.of(context).size.width / 1.5,
                                            child:  IgnorePointer
                                            (
                                              ignoring: isPlaying,
                                              child: AudioRecordButton
                                              (
                                                syllable: widget.syllable,
                                                newAudio: newAudio,
                                                isRecording: isRecording,
                                                setNewAudio: (bool value) {
                                                  setState(() {
                                                    newAudio = value;
                                                  });
                                                },
                                                setIsRecording: (bool value) {
                                                  setState(() {
                                                    isRecording = !isRecording;
                                                  });
                                                },
                                                
                                              ),
                                            )
                                          ),
                                        ),
                                        Padding
                                        (
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox
                                          (
                                            width: MediaQuery.of(context).size.width / 1.5,
                                            child: IgnorePointer
                                            (
                                              ignoring: isRecording,
                                              child: buildPlayButton(),
                                            )
                                          ),
                                        ), 
                                      ]
                                    ),
                                  ),
                                ], 
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget> [
              Container
              (
                child: orientation == Orientation.landscape ? 
                Row
                (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: 
                  [
                    buildCancelButton(orientation),
                    buildSaveButton(orientation),
                  ]
                ) : 
                Column
                (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: 
                  [
                    buildCancelButton(orientation),
                    buildSaveButton(orientation),
                  ],
                )
              ),
            ],
          );
        }
      );
      }
    );
  }
  
}