import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucimo_slogove/buttons/audio_record_button.dart';
import 'package:ucimo_slogove/buttons/play_audio_button.dart';
import 'package:ucimo_slogove/dialogs/alert_syllable_dialog.dart';
import 'package:ucimo_slogove/services/audio_record.dart';
import 'package:ucimo_slogove/services/audio_service.dart';
import 'package:ucimo_slogove/buttons/cancel_dialog_button.dart';

class AddSyllableDialog extends StatefulWidget {
  final Function onAdded;

  const AddSyllableDialog({
    required this.onAdded,
    super.key,
  });

  @override
  AddSyllableDialogState createState() => AddSyllableDialogState();
}

class AddSyllableDialogState extends State<AddSyllableDialog> {
 
  String _newSyllable = '';
  String _newCategory = '';
  late bool newAudio;
  late bool isRecording;
  late bool isPlaying;
  late ScrollController _scrollController;

  AudioService _audioService = AudioService();
  AudioRecord _audioRecord = AudioRecord();

  @override
  void initState() {
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

  void _displayAlertDialog(bool isValid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? syllables =  prefs.getStringList('syllables');

    
      showDialog
      (
        context: context,
        builder: (BuildContext context) 
        {
          return AlertSyllableDialog
          (
            getCategory: getCategory,
            newAudio: newAudio,
            newSyllable: _newSyllable.toLowerCase(),
            syllablesList: syllables!.isNotEmpty ? syllables : syllables ,
            isValid: isValid,
            checkAudio: true,
          );
        },
      );

  }

  Widget buildPlayButton() {
    return PlayAudioButton
    (
      onPressed: () {
        _audioService.playSound("temp_temp");
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

  Widget buildCancelButton(Orientation orientation) 
  {
    return CancelDialogButton
    (
      onPressed: () 
      {
        Navigator.of(context).pop();
      },
      orientation: orientation,
    );
  }

  Widget buildSaveButton(Orientation orientation) 
  {
    return Padding
    (
      padding: orientation == Orientation.landscape
          ? EdgeInsets.symmetric(horizontal: 8.0)
          : EdgeInsets.symmetric(vertical: 8.0),
      child: Container
      (
        padding: EdgeInsets.all(5.0),
        alignment: Alignment.center,
        child: SizedBox
        (
          width: orientation == Orientation.landscape
              ? MediaQuery.of(context).size.width / 2.75
              : MediaQuery.of(context).size.width / 1.5,
          child: TextButton
          (
            onPressed:() {
              addNewSyllable();
              widget.onAdded();
              setState( () => {} );
            },
            style: ButtonStyle
            (
              padding: WidgetStateProperty.resolveWith
              (
                (states) => EdgeInsets.all(20.0)
              ),
              backgroundColor: WidgetStateColor.resolveWith
              (
                (states) =>  Color.fromARGB(255, 0, 86, 199)
              ),
              shape: WidgetStateProperty.resolveWith<OutlinedBorder?>
              (
                (Set<WidgetState> states) {
                  return RoundedRectangleBorder
                  (
                    borderRadius: BorderRadius.circular(15.0),
                  );
                },
              ),
            ),
            child: Text(
              'SPREMI PROMJENE',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 25.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addNewSyllable() async 
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String>? syllables = prefs.getStringList('syllables');
    final List<String>? syllablesDivided = prefs.getStringList('syllablesDivided');
    List<String>? selectedSyllables = prefs.getStringList('selectedSyllables');

    _newSyllable = _newSyllable.toLowerCase();
    String newSyll = _newSyllable.replaceAll("-", "");
    final List<String>? syllablesCategory;

    setState(() {
      _newCategory = getCategory(_newSyllable);
    });

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

    
    if(isValid == false || _newSyllable == "" || _newCategory == "" || newAudio == false || _newSyllable == "-" || syllables!.contains(newSyll) || !_newSyllable.contains("-") || getCategory(_newSyllable).isEmpty ){
      return _displayAlertDialog(isValid);
    }
    
    if(_newCategory== "slogovi dva slova"){
      syllablesCategory = prefs.getStringList('2Slova');
    }
    else{
      syllablesCategory = prefs.getStringList('3Slova');
    }

    syllables.add(newSyll);
    prefs.setStringList('syllables', syllables);
  
    if(selectedSyllables != null)
    {
      selectedSyllables.add(newSyll);
      prefs.setStringList('selectedSyllables', selectedSyllables);
    }

    if(syllablesDivided != null)
    {
      syllablesDivided.add(_newSyllable);
      prefs.setStringList('syllablesDivided', syllablesDivided);
    }

    if(syllablesCategory!= null)
    {
      syllablesCategory.add(newSyll);
      _newCategory == "slogovi dva slova" ?
      prefs.setStringList('2Slova', syllablesCategory) : prefs.setStringList('3Slova', syllablesCategory); 
    }

    prefs.remove("temp");
    prefs.setBool(newSyll, false);

    if (newAudio == true) {
      _newSyllable = _newSyllable.toLowerCase();
      await _audioRecord.saveAudio(_newSyllable.replaceAll('-', ''), _newSyllable.replaceAll('-', ''));
      Navigator.of(context).pop(true); 
    }

    setState(() => {});
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
                  height: orientation == Orientation.landscape ? MediaQuery.of(context).size.height / 1.5 : MediaQuery.of(context).size.height / 2.0 ,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: 
                        [
                          TextFormField
                          (
                            maxLength: 5,
                            initialValue: "-",
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
                                              syllable: "temp",
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
                                            ignoring: isRecording || !newAudio,
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
                                          child: IgnorePointer
                                          (
                                            ignoring: isPlaying,
                                            child: AudioRecordButton
                                            (
                                              syllable: "temp",
                                              isRecording: isRecording,
                                              newAudio: newAudio,
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
                                            ignoring: isRecording || !newAudio,
                                            child: buildPlayButton()
                                          )
                                        ),
                                      ), 
                                    ]
                                  ),
                                ),
                              ], 
                            ),
                          ) 
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
              )
            ],
          );
        }
      );
      }
    );
  }
}