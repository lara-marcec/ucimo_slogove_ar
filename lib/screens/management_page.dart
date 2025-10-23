import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucimo_slogove/dialogs/add_syllable_dialog.dart';
import 'package:ucimo_slogove/dialogs/delete_syllable_dialog.dart';
import 'package:ucimo_slogove/dialogs/edit_syllable_dialog.dart';
import 'package:ucimo_slogove/services/syllable_service.dart';


class ManagementRoute extends StatefulWidget 
{
  const ManagementRoute({super.key});

  @override
  ManagementRouteState createState() => ManagementRouteState();
}

class ManagementRouteState extends State<ManagementRoute> {
  late SyllableService _syllableService;
  late ScrollController _scrollController;
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredSyllableFilenames = [];
    
  @override
  void initState() {
    super.initState();
    _syllableService = SyllableService();
    _scrollController = ScrollController();
    _loadSyllableFilenames();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _deleteSyllable(String syllable) async 
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? syllables =  prefs.getStringList('syllables');
    final List<String>? selectedSyllables =  prefs.getStringList('selectedSyllables');
    final List<String>? syllablesTwo =  prefs.getStringList('2Slova');
    final List<String>? syllablesThree =  prefs.getStringList('3Slova');
    showDialog
    (
      context: context,
      builder: (BuildContext context) 
      {
        return DeleteSyllableDialog
        (
          syllable: syllable,
          onDeleteConfirmed: () async {
            if ( syllables != null && selectedSyllables != null
            && syllablesTwo != null && syllablesThree != null ) 
            {
              Set<String> keys = prefs.getKeys();

              for (String key in keys) {
                dynamic value = prefs.get(key);
              print('$key: $value');
              }
              selectedSyllables.removeWhere((s) => s == syllable);
              syllables.removeWhere((s) => s == syllable);
              syllablesTwo.removeWhere((s) => s == syllable);
              syllablesThree.removeWhere((s) => s == syllable);
              await prefs.remove(syllable);
              await prefs.setStringList('syllables', syllables);
              await prefs.setStringList('selectedSyllables', selectedSyllables);
              await prefs.setStringList('3Slova', syllablesThree);
              await prefs.setStringList('2Slova', syllablesTwo);


              for (String key in keys) {
                dynamic value = prefs.get(key);
                print('$key: $value');
              }

            }

            print(prefs.getStringList('syllables'));
            setState(() {
              _loadSyllableFilenames();
            },);
          },
        );
      },
    );
  }

  void _addSyllable () async
  {
    showDialog
    (
      context: context,
      builder: (BuildContext context)
      {
        return AddSyllableDialog
        (
          onAdded: () async {
            setState(() {
              _loadSyllableFilenames();
            },);
          }
        );
      },
    );
    
  }

  Future<void> _editSyllable(String syllable) async
  { 
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? syllables2Letters = prefs.getStringList('2Slova');
    String category = "";
    if(syllables2Letters != null){
      if(syllables2Letters.contains(syllable))
      {
        category = "slogovi dva slova";
      }
      else
      {
        final List<String>? syllables3Letters = prefs.getStringList('3Slova');
        if(syllables3Letters != null && syllables3Letters.contains(syllable))
        {
          category = "slogovi tri slova";
        }
      }
    }
    String divided = "";
    List<String>? syllDivided = prefs.getStringList('syllablesDivided');

    if(syllDivided != null)
    {
      for (int i = 0; i < syllDivided.length; i++) {
        String temp = syllDivided[i].replaceAll("-", "");
        if (temp == syllable) {
          divided = syllDivided[i];
        }
      }
    }

    final bool? result = await showDialog
    (
      context: context,
      builder: (BuildContext context)
      {
        return EditSyllableDialog
        (
          syllable: syllable,
          category: category,
          sDivided: divided,
        );
      },
    );
    if (result == true) {
      setState(() {
        _loadSyllableFilenames();
      });
    }
  }

  Future<void> _loadSyllableFilenames() async
  {
    await _syllableService.loadSyllableFilenames();
    _filteredSyllableFilenames = _syllableService.getSyllableFilenames();
    setState(() {});
  }

  void _filterSyllables(String query)
  {
    setState(() {
      _filteredSyllableFilenames = _syllableService.getSyllableFilenames().where((filename) {
        filename = filename.replaceAll('.mp3', '').replaceAll('sounds/', '').replaceAll('dd', 'đ')
                    .replaceAll('zh', 'ž').replaceAll('ch', 'č').replaceAll('cc', 'ć').replaceAll('sh', 'š');
        return filename.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }


  @override
  Widget build (BuildContext context)
  {
    return StatefulBuilder
    (
      builder: (BuildContext context, setState) {
        return Scaffold
        (
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: AppBar
          (
            toolbarHeight: (MediaQuery.of(context).size.height / 8),
            title: Text("Upravljanje slogovima"),
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            actions:
            [
              Container
                (
                  alignment: Alignment.centerRight,
                  child: IconButton
                  (
                    padding: EdgeInsets.all(15.0),
                    iconSize: 30,
                    onPressed: () {
                      _addSyllable();
                    },
                    icon: Icon(Icons.add_circle_outline, color:const Color.fromARGB(255, 31, 31, 31)),
                    alignment: Alignment.center,
                  ),
                ),
            ]
          ),
          
          body: OrientationBuilder
          (
            builder: (context, orientation)
            {
              return Center
              (
              child: Padding
                (
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column
                  (
                    children: [
                      Container
                      (
                        color: Colors.white,
                        child: Padding
                        (
                          padding: const EdgeInsets.all(10.0),
                          child: TextField
                          (
                            controller: _searchController,
                            onChanged: _filterSyllables,
                            decoration: InputDecoration
                            (
                              filled: true,
                              fillColor: Color.fromARGB(255, 255, 239, 92),
                              labelText: 'Pretraži slogove',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ),
                      Expanded
                      (
                      child: Padding
                      (
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Scrollbar
                        (
                          controller: _scrollController,
                          radius: Radius.circular(15.0),
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 20.0,
                          interactive: true,
                          child: Container
                          (
                            alignment: AlignmentDirectional.topStart,
                            padding: EdgeInsets.only(left: 10.0),
                            child: SizedBox
                            (
                              width: MediaQuery.of(context).size.width - 50.0,
                              child: ListView.builder
                              (
                                controller: _scrollController,
                                itemCount: _filteredSyllableFilenames.length,
                                itemBuilder: (context, index)
                                {
                                  var syllableFilename = _filteredSyllableFilenames[index];
                                  syllableFilename = syllableFilename.replaceAll('.mp3', '').replaceAll('sounds/', '').replaceAll('dd', 'đ')
                                    .replaceAll('zh', 'ž').replaceAll('ch', 'č').replaceAll('cc', 'ć').replaceAll('sh', 'š');
                                  return Padding
                                  (
                                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                                    child: ListTile
                                    (
                                      tileColor: Color.fromARGB(255, 217, 237, 255),
                                      contentPadding: EdgeInsets.only(left: 20.0, right: 5.0),
                                      minVerticalPadding: 20.0,
                                      title: Text
                                      (
                                        syllableFilename,
                                        style: TextStyle
                                        (
                                          fontFamily: 'Tahoma',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                          fontSize: 25.0,
                                        ),
                                      ),
                                      trailing: Row
                                      (
                                        mainAxisSize: MainAxisSize.min,
                                        children:
                                        [
                                          IconButton
                                          (
                                            padding: EdgeInsets.zero,
                                            onPressed: ()
                                            {
                                              _editSyllable(syllableFilename);
                                            },
                                            icon: Icon(Icons.edit),
                                          ),
                                          IconButton
                                          (
                                            padding: EdgeInsets.zero,
                                            onPressed: ()
                                            {
                                              _deleteSyllable(syllableFilename);
                                              
                                            },
                                            icon: Icon(Icons.delete),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        );
      }
    );
  }
}