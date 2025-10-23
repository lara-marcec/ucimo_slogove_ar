import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucimo_slogove/buttons/save_category_button.dart';
import 'package:ucimo_slogove/screens/management_page.dart';
import 'package:ucimo_slogove/services/croatian_alphabet_sort.dart';
import 'package:ucimo_slogove/styles/button_style_yellow.dart';
import 'package:ucimo_slogove/styles/text_style.dart';

class CategoryRoute extends StatefulWidget
{
  const CategoryRoute({super.key});

  @override
  CategoryRouteState createState() => CategoryRouteState();
}

class CategoryRouteState extends State<CategoryRoute>
{
  late ScrollController _scrollController;
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredSyllableFilenames = [];

  bool checkAll = false;
  bool checkTwo = false;
  bool checkThree = false;

  bool ignoreTwo = false;
  bool ignoreThree = false;

  List<String> _selectedSyllables = [];
  List<String> _syllables = [];

  @override
  void initState()
  {
    loadSharedPrefs();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose()
  {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadSyllableFilenames(List<String> syllableList)
  {
    setState(() {
      syllableList = syllableList.toList()..sort(croatianSort);
      _filteredSyllableFilenames = syllableList;
    }); 
  }

  void _filterSyllables(String query, List<String> syllableList)
  {
    setState(() {
      _filteredSyllableFilenames = syllableList.where((filename) {
        filename = filename.replaceAll('.mp3', '').replaceAll('sounds/', '').replaceAll('dd', 'đ')
                    .replaceAll('zh', 'ž').replaceAll('ch', 'č').replaceAll('cc', 'ć').replaceAll('sh', 'š');
        return filename.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> loadSharedPrefs() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? selectedSyllables = prefs.getStringList('selectedSyllables');
    List<String>? syllables = prefs.getStringList('syllables');

    setState(() {
      _syllables = syllables!;
      _selectedSyllables = selectedSyllables!;
    });

    if(selectedSyllables!.isEmpty)
    {
      prefs.setBool('checkAll',  false);
      prefs.setBool('checkTwo', false);
      prefs.setBool('checkThree', false);
    }
    else
    {
      prefs.setBool('checkAll', prefs.getBool('checkAll') ?? true);
      prefs.setBool('checkTwo', prefs.getBool('checkTwo') ?? true);
      prefs.setBool('checkThree', prefs.getBool('checkThree') ?? true);
    }

    bool cAll = prefs.getBool('checkAll')!;
    bool cTwo = prefs.getBool('checkTwo')!;
    bool cThree = prefs.getBool('checkThree')!;

    final List<String>? syllablesThree = prefs.getStringList('3Slova');
    final List<String>? syllablesTwo = prefs.getStringList('2Slova');

    bool containsThree = true;
    if(syllablesThree != null)
    {
      for(String s in syllablesThree)
      {
        if(!selectedSyllables.contains(s) )
        {
          containsThree = false;
          break;
        }
      }
    }
    else
    {
      containsThree = false;
    }

    if(containsThree)
    {
      cThree = true; prefs.setBool('checkThree', true);
    }

    bool contains = true;
    if(syllablesTwo != null)
    {
      for(String s in syllablesTwo)
      {
        if(!selectedSyllables.contains(s) )
        {
          contains = false;
          break;
        }
      }
    }
    else{
      contains = false;
    }

    if(contains)
    {
      cTwo = true; prefs.setBool('checkTwo', true);
    }

    if(syllablesTwo!.isEmpty){
      cTwo = false;
      setState(() {
        ignoreTwo = true;
      });
    }
    else{
      setState(() {
        ignoreTwo = false;
      });
    }

    
    if(syllablesThree!.isEmpty){
      cThree = false;
      setState(() {
        ignoreThree = true;
      });
    }
    else{
      setState(() {
        ignoreThree = false;
      });
    }

    if((cThree == true && cTwo == true) || (cThree == true && ignoreTwo == true) || (cTwo == true && ignoreThree == true))
    {
      cAll = true;
      prefs.setBool('checkAll', true);
    }
    else
    {
      cAll = false;
      prefs.setBool('checkAll', false);
    }

    prefs.setBool('checkTwo', cTwo);
    prefs.setBool('checkThree', cThree);
    setState(() {
      checkThree = cThree;
      checkAll = cAll;
      checkTwo = cTwo;
    });
  
    if(syllables != null) {
      syllables = syllables.toList()..sort(croatianSort);
    }

    selectedSyllables = selectedSyllables.toList()..sort(croatianSort);
    
    setState(() {
      _selectedSyllables = selectedSyllables!;
    });
  }
  TextStyle textStyle()
  {
    return TextStyle
    (
      fontFamily: 'Tahoma',
      letterSpacing: 1.75,
      fontSize: 25.0,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    );
  }

  TextStyle ignoreTextStyle()
  {
    return TextStyle
    (
      fontFamily: 'Tahoma',
      fontSize: 25.0,
      color: Color.fromARGB(255, 88, 88, 88),
    );
  }

  Widget buildSaveButton()
  {
    return SaveButton
    (
      onPressed: ()
      {
        _saveSelectedSyllables(_selectedSyllables, true);
        setState((){});
        Navigator.of(context).pop();
      },
    );
  }

  Widget buildOkButton()
  {
    return Center(
      child: ElevatedButton
      (
        onPressed: () { Navigator.of(context).pop(); },
        style: buttonStyleYellow(),
        child: Text
        (
          "OK", style: textStyleButtonBlack(),
        ),
        
      ),
    );
  }
  
  void _removeAllTwo(bool remove) async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? syllablesTwo = prefs.getStringList('2Slova');
    if(syllablesTwo != null) {
      for(String s in syllablesTwo)
      {
        if(remove == true)
        {
          if(_selectedSyllables.contains(s))
          {
            _selectedSyllables.remove(s);
          }
        }
        else
        {
          if(!_selectedSyllables.contains(s))
          {
            _selectedSyllables.add(s);
          }
        }
      }
      prefs.setBool('checkTwo', !remove);
      bool? cT = prefs.getBool('checkThree');
      prefs.setBool('checkAll', cT! && remove);
      prefs.setStringList('selectedSyllables', _selectedSyllables);
    }
  }

  void _removeAllThree(bool remove) async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? syllablesThree = prefs.getStringList('3Slova');

    if(syllablesThree != null)
    {
      for(String s in syllablesThree)
      {
        if(remove == true)
        {
          if(_selectedSyllables.contains(s))
          {
            _selectedSyllables.remove(s);
          }
        }
        else
        {
          if(!_selectedSyllables.contains(s))
          {
            _selectedSyllables.add(s);
          }
        }
      }
      prefs.setBool('checkThree', !remove);
      bool? cT = prefs.getBool('checkTwo');
      prefs.setBool('checkAll', cT! && remove);
      prefs.setStringList('selectedSyllables', _selectedSyllables);
    }
  }

  void _saveSelectedSyllables(List<String> selectedSyll, bool setBySelectedList) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(setBySelectedList == true)
    {
      _selectedSyllables = selectedSyll;
      prefs.setStringList('selectedSyllables', selectedSyll);
    }
    else
    {
      if(checkAll) //oznaci sve
      {
        List<String>? tempSelectedSyllables = prefs.getStringList('syllables');
        if(tempSelectedSyllables != null){
          _selectedSyllables = tempSelectedSyllables;
          prefs.setStringList('selectedSyllables', tempSelectedSyllables);
        }
      }
      else if(checkTwo && !checkThree)
      {
        List<String>? tempSelectedSyllables = prefs.getStringList('2Slova');
        if(tempSelectedSyllables != null){
          _selectedSyllables.addAll(tempSelectedSyllables);
          prefs.setStringList('selectedSyllables', _selectedSyllables);
        }
      }
      else if(checkThree && !checkTwo)
      {
        List<String>? tempSelectedSyllables = prefs.getStringList('3Slova');
        if(tempSelectedSyllables != null){
          _selectedSyllables.addAll(tempSelectedSyllables);
          prefs.setStringList('selectedSyllables', _selectedSyllables);
        }
      }
      else {
        _selectedSyllables = selectedSyll;
        prefs.setStringList('selectedSyllables', selectedSyll);
      }
    }

    prefs.setBool('checkAll', checkAll);
    prefs.setBool('checkTwo', checkTwo);
    prefs.setBool('checkThree', checkThree);

    print(prefs.getStringList('selectedSyllables'));
    List<String> selected = prefs.getStringList('selectedSyllables')!;
    setState(() {
      _selectedSyllables = selected;
    });
  }

  void saveNoSyllableSate(int s){
    setState(() {
      if(s == 2){
        checkTwo = false;
      }
      else if(s == 3){
        checkThree = false;
      }
    });
  }

  Future<void> _displayAlertDialog() async {
    return showDialog
    (
      context: context,
      builder: (BuildContext context)
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
                  actionsPadding: EdgeInsets.all(15.0),
                  contentPadding: EdgeInsets.only(left: 25.0, right:25.0, top:10.0, bottom: 10.0),
                  title: Text
                  (
                    "Odaberite barem jedan slog!",
                    textAlign: TextAlign.center,
                    style: textStyleDialog()
                  ),
                  actions:
                  [
                    Container
                    (
                      alignment: Alignment.center,
                      child: ElevatedButton
                      (
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: buttonStyleYellow(),
                        child:Text
                        (
                          "OK",
                          textAlign: TextAlign.center,
                          style: textStyleDialog(),
                        ),
                      ),
                    )
                  ]
                );
              }
            );
          }
        );
      }
    );
  }

  Future<void> _showCategoryThreeDialog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? syllables3Letters =  prefs.getStringList('3Slova');

    _loadSyllableFilenames(syllables3Letters!);

    return showDialog
    (
      context: context,
      builder: (BuildContext context)
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
                  surfaceTintColor: const Color.fromARGB(0, 255, 255, 255),
                  actionsPadding: EdgeInsets.all(15.0),
                  contentPadding: EdgeInsets.only(left: 25.0, right:25.0, top:10.0, bottom: 10.0),
                  title: Text
                  (
                    "slogovi tri slova",
                    textAlign: TextAlign.center,
                    style: TextStyle
                    (
                      fontWeight: FontWeight.w600,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  content: syllables3Letters.isNotEmpty ? Column
                  (
                    children: [
                      Expanded
                      (
                        child: Scrollbar
                        (
                          controller: _scrollController,
                          radius: Radius.circular(15.0),
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 20.0,
                          interactive: true,
                          child: SingleChildScrollView
                          (
                            physics: ScrollPhysics(),
                            controller: _scrollController,
                            child: Container
                            (
                              padding: EdgeInsets.only(right: 30.0),
                              child: SizedBox
                              (
                                width: orientation == Orientation.landscape ? MediaQuery.of(context).size.width / 2.5 : MediaQuery.of(context).size.width / 1.5,
                                child: Column
                                (
                                  children:
                                  [
                                    Padding
                                    (
                                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                                      child: Row
                                        (
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children:
                                          [
                                            Transform.scale
                                            (
                                              scale: 1.3,
                                              child: Checkbox
                                              (
                                                activeColor: Color.fromARGB(255, 0, 86, 199),
                                                value: checkThree,
                                                onChanged: (bool? value)
                                                {
                                                  setState
                                                  (()
                                                    {
                                                      checkThree = value!;
                                                      checkAll = (  (checkThree && checkTwo) || (checkTwo && ignoreThree) ) ? true : false;
                                                    }
                                                  );
                                                  if(checkThree == false)
                                                  {
                                                    _removeAllThree(true);
                                                  }
                                                  else
                                                  {
                                                    _removeAllThree(false);
                                                  }
                                                }
                                              ),
                                            ),
                                            Align
                                            (
                                              alignment: Alignment.center,
                                              child: FittedBox
                                              (
                                                fit:BoxFit.scaleDown,
                                                child: Text
                                                (
                                                  "ODABERI SVE",
                                                  style: textStyleInfo(),
                                                ),
                                              ),
                                            ),
                                          ]
                                        ),
                                    ),
                                    Container
                                    (
                                      color: Colors.white,
                                      child: Padding
                                      (
                                        padding: const EdgeInsets.all(10.0),
                                        child: TextField
                                        (
                                          controller: _searchController,
                                          onChanged: (query) { _loadSyllableFilenames(syllables3Letters); _filterSyllables(query, syllables3Letters); setState(() {}); },
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
                              
                                    Padding
                                    (
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child: ListView.builder
                                      (
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: _filteredSyllableFilenames.length,
                                        itemBuilder: (context, index)
                                        {
                                          var syllable = _filteredSyllableFilenames[index];
                                          return Row
                                          (
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container
                                              (
                                                padding: EdgeInsets.only(left:25.0, top:5.0, bottom:5.0),
                                                alignment: Alignment.center,
                                                child: Text
                                                (
                                                  syllable,
                                                  style: TextStyle
                                                  (
                                                    fontFamily: 'Tahoma',
                                                    fontSize: 24.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Container
                                              (
                                                padding: EdgeInsets.only(right:25.0),
                                                alignment: Alignment.center,
                                                child: Transform.scale
                                                (
                                                  scale: 1.3,
                                                  child: Checkbox
                                                  (
                                                    activeColor: Color.fromARGB(255, 0, 86, 199),
                                                    value: _selectedSyllables.contains(syllable),
                                                    onChanged: (bool? value) {
                                                        setState
                                                        (() {
                                                          if (value ?? false) {
                                                            _selectedSyllables.add(syllable);
                                                          } else {
                                                            _selectedSyllables.remove(syllable);
                                                          }
                                                          setState( () {
                                                            checkAll = false;
                                                            checkThree = false;
                                                          });
                                                          
                                                          bool checked = true;
                                                          for(String s in syllables3Letters){
                                                            if(!_selectedSyllables.contains(s)){
                                                              checked = false;
                                                              break;
                                                            }
                                                          }
                                                          if(checked == true){
                                                            setState(() {
                                                              checkThree = true;
                                                              checkAll = checkThree && checkTwo;
                                                            });
                                                          }
                                                        });
                                                        _saveSelectedSyllables(_selectedSyllables, true);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ) :
                  Container
                  (
                    
                    padding: EdgeInsets.all(15.0),
                    child: Text
                    (
                      "Nema slogova u ovoj kategoriji.",
                      style: textStyleInfo(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  actions: syllables3Letters.isNotEmpty ? <Widget>
                  [
                    
                    buildSaveButton()
                  ] : <Widget>
                  [
                    buildOkButton(),
                  ],
                );
              },
            );
          }
        );
      },
    );
  }

  Future<void> _showCategoryTwoDialog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? syllables2Letters = prefs.getStringList('2Slova');

    _loadSyllableFilenames(syllables2Letters!);
    return showDialog
    (
    context: context,
    builder: (BuildContext context)
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
                surfaceTintColor: Color.fromARGB(0, 255, 255, 255),
                actionsPadding: EdgeInsets.all(15.0),
                contentPadding: EdgeInsets.only(left: 15.0, right:15.0, top:10.0, bottom: 10.0),
                title: Text
                (
                  "slogovi dva slova",
                  textAlign: TextAlign.center,
                  style: TextStyle
                  (
                    fontWeight: FontWeight.w600,
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
                content: syllables2Letters.isNotEmpty ? Column
                (
                  children: [
                    Expanded
                    (
                      child: Scrollbar
                      (
                        controller: _scrollController,
                        radius: Radius.circular(15.0),
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 20.0,
                        interactive: true,
                
                        child: SingleChildScrollView
                        (
                          controller: _scrollController,
                          child: Container
                          (
                            padding: EdgeInsets.only(right: 30.0),
                            child: SizedBox
                            (
                              width: orientation == Orientation.landscape ? MediaQuery.of(context).size.width / 2.5 : MediaQuery.of(context).size.width / 1.5,
                              child: Column
                              (
                                children:
                                [
                                  Padding
                                  (
                                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                                    child: Row
                                    (
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children:
                                      [
                                        Transform.scale
                                        (
                                          scale: 1.3,
                                          child: Checkbox
                                          (
                                            activeColor: Color.fromARGB(255, 0, 86, 199),
                                            value: checkTwo,
                                            onChanged: (bool? value)
                                            {
                                              setState
                                              (()
                                                {
                                                  checkTwo = value!;
                                                  checkAll = ( (checkThree && checkTwo) || (checkTwo && ignoreThree)  ) ? true : false;
                                                }
                                              );

                                              if(checkTwo == false)
                                              {
                                                _removeAllTwo(true);
                                              }
                                              else
                                              {
                                                _removeAllTwo(false);
                                              }
                                            }
                                          ),
                                        ),
                                        Align
                                        (
                                          alignment: Alignment.center,
                                          child: FittedBox
                                          (
                                            fit:BoxFit.scaleDown,
                                            child: Text
                                            (
                                              "ODABERI SVE",
                                              style: textStyleInfo(),
                                            ),
                                          ),
                                        ),
                                      ]
                                    ),
                                  ),
                                  Container
                                  (
                                    color: Colors.white,
                                    child: Padding
                                    (
                                      padding: const EdgeInsets.all(10.0),
                                      child: TextField
                                      (
                                        controller: _searchController,
                                        onChanged: (query) { _loadSyllableFilenames(syllables2Letters); _filterSyllables(query, syllables2Letters); setState(() {}); },
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
                                  Padding
                                  (
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: ListView.builder
                                    (
                                      
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _filteredSyllableFilenames.length,
                                      itemBuilder: (context, index)
                                      {
                                        var syllable = _filteredSyllableFilenames[index];
                                        return Row
                                        (
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container
                                            (
                                              padding: EdgeInsets.only(left:25.0, top:5.0, bottom:5.0),
                                              alignment: Alignment.center,
                                              child: Text
                                              (
                                                syllable,
                                                style: TextStyle
                                                (
                                                  fontFamily: 'Tahoma',
                                                  fontSize: 24.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Container
                                            (
                                              padding: EdgeInsets.only(right:25.0),
                                              alignment: Alignment.center,
                                              child: Transform.scale
                                              (
                                                scale: 1.3,
                                                child: Checkbox
                                                (
                                                  activeColor: Color.fromARGB(255, 0, 86, 199),
                                                  value: _selectedSyllables.contains(syllable),
                                                  onChanged: (bool? value) {
                                                    setState (()
                                                    {
                                                      if (value ?? false)
                                                      {
                                                        _selectedSyllables.add(syllable);
                                                      } else
                                                      {
                                                        _selectedSyllables.remove(syllable);
                                                      }
                                                      setState( ()
                                                      {
                                                        checkTwo = false;
                                                        checkAll = checkThree && checkTwo;
                                                      });
                                                      bool checked = true;
                                                      for(String s in syllables2Letters){
                                                        if(!_selectedSyllables.contains(s)){
                                                          checked = false;
                                                          break;
                                                        }
                                                      }
                                                      if(checked == true){
                                                        setState(() {
                                                          checkTwo = true;
                                                          checkAll = checkThree && checkTwo;
                                                        });
                                                      }
                                                    });
                                                    _saveSelectedSyllables(_selectedSyllables, true);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ]
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ) :
                Container
                (
                  padding: EdgeInsets.all(15.0),
                  child: Text
                  (
                    "Nema slogova u ovoj kategoriji.",
                    style: textStyleInfo(),
                    textAlign: TextAlign.center,
                  ),
                ),
                actions: syllables2Letters.isNotEmpty ? <Widget>
                [
                  buildSaveButton()
                ] : <Widget>
                [
                  buildOkButton(),
                ],
              );
            }
          );
        }
      );
    },
  );
}
  
  Future<List<String>> getSyllables(int n) async {

    final SharedPreferences prefs =  await SharedPreferences.getInstance();

    if(n == 2)
    {
      final List<String>? syllables2Letters =  prefs.getStringList('2Slova');

      if(syllables2Letters!.isEmpty){
        setState(() {
          checkTwo = false;
        });
      }

      return syllables2Letters;
    }

    else if(n == 3){
      final List<String>? syllables3Letters =  prefs.getStringList('3Slova');
      
      if(syllables3Letters!.isEmpty){
        setState(() {
          checkThree = false;
        });
      }

      return syllables3Letters;
    }
    else{ return []; }
    
  }

  @override
  Widget build (BuildContext context)
  {
    return Scaffold
    (
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar
      (
        leading: BackButton
        (
          onPressed: () {
            if(_selectedSyllables.isEmpty || _syllables.isEmpty )
            {
              _displayAlertDialog();
            }
            else
            {
              Navigator.pop(context);
            }
          },
        ),
        toolbarHeight: (MediaQuery.of(context).size.height / 8),
        title: Text("Kategorije"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white
      ),
      body: _syllables.isEmpty ? Container
      (
        alignment: Alignment.center,
        child: Column
        (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
          [
            Padding
            (
              padding: const EdgeInsets.all(20.0),
              child: Text
              (
                "Nema slogova za odabir. Dodajte novi slog i pokušajte ponovno.",
                style: textStyleDialog(),
                textAlign: TextAlign.center,
              ),
            ),
            Padding
            (
              padding: const EdgeInsets.all(20.0),
              child: SizedBox
              (
                width: MediaQuery.of(context).size.width / 1.25,
                child: ElevatedButton.icon
                (
                  style: ElevatedButton.styleFrom
                  (
                    alignment: Alignment.centerLeft,
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: Color.fromARGB(255, 217, 237, 255),
                    foregroundColor: Color.fromARGB(255, 49, 49, 49),
                    padding: const EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                    textStyle: TextStyle
                    (
                      fontFamily: 'Tahoma',
                      letterSpacing: 1.75,
                      fontWeight: FontWeight.w500,
                      fontSize: 28.0,
                    ),
                  ),
                  icon:Padding
                  (
                    padding: const EdgeInsets.all(15.0),
                    child: Icon
                    (
                      Icons.build,
                      size: 30.0,
                      color:Color.fromARGB(255, 0, 86, 199)
                    ),
                  ),
                  label: Text
                  (
                    "Upravljanje slogovima",
                    style: textStyleMenu(),
                  ),
                  onPressed: ()
                  {
                    Navigator.of(context).pop();
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ManagementRoute()));
                  },
                ),
              ),
            ),
          ]
        ),
      ) : SingleChildScrollView
      (
        child: Container
        (
          alignment: Alignment.center,
          margin: EdgeInsets.all(10),
          child: Column
          (
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:
            [
              Padding
              (
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                
                child: SizedBox
                (
                  width: MediaQuery.of(context).size.width / 1.25,
                  child: Container
                  (
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration
                    (
                      color: Color.fromARGB(255, 255, 239, 92),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Row
                    (
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:
                      [
                        Transform.scale
                        (
                          scale: 1.4,
                          child: Checkbox
                          (
                            activeColor: Colors.black,
                            value: checkAll,
                            onChanged: (bool? value)
                            {
                              setState
                              (()
                                {
                                  checkAll = value!;
                                  checkThree = ignoreThree ? false : value;
                                  checkTwo = ignoreTwo ? false : value;
                                  _saveSelectedSyllables([], false);
                                }
                              );
                            }
                          ),
                        ),
                        Flexible
                        (
                          child: Padding
                          (
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text
                            (
                              'ODABERI SVE',
                              style: textStyle(),
                            ),
                          ),
                        ),
                      ]
                    ),
                  ),
                  ),
                ),
                Padding
                (
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox
                  (
                    width: MediaQuery.of(context).size.width / 1.25,
                    child: Container
                    (
                      padding: EdgeInsets.all(15.0),
                        decoration: BoxDecoration
                        (
                          color: Color.fromARGB(255, 217, 237, 255),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      child: Row
                      (
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                        [
                          IgnorePointer
                          (
                            ignoring: ignoreTwo,
                            child: Transform.scale
                            (
                              scale: 1.4,
                              child: Checkbox
                              (
                                activeColor: Colors.black,
                                value: checkTwo,
                                onChanged: (bool? value)
                                {
                                  setState
                                  (()
                                    {
                                      checkTwo = value!;
                                      checkAll = ( (checkThree && checkTwo) || (checkTwo && ignoreThree)) ? true : false; 
                                    }
                                  );
                            
                                  if(checkTwo == false)
                                  {
                                    _removeAllTwo(true);
                                  }
                                  else
                                  {
                                    _removeAllTwo(false);
                                  }
                                  
                                }
                              ),
                            ),
                          ),
                          Flexible
                          (
                            child: Padding
                            (
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text
                              (
                                'SLOGOVI DVA SLOVA',
                                style: ignoreTwo ? ignoreTextStyle() : textStyle(),
                              ),
                            ),
                          ),
                          IconButton
                          (
                            iconSize: 32.0,
                            onPressed: () =>
                            {
                              _showCategoryTwoDialog(),
                            },
                            icon: Icon(Icons.more_vert),
                          )
                        ]
                      ),
                    ),
                  ),
                ),
                Padding
                (
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox
                  (
                    width: MediaQuery.of(context).size.width / 1.25,
                    child: Container
                    (
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration
                      (
                        color: Color.fromARGB(255, 217, 237, 255),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Row
                      (
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                        [
                          IgnorePointer
                          (
                            ignoring: ignoreThree,
                            child: Transform.scale
                            (
                              scale: 1.4,
                              child: Checkbox
                              (
                                activeColor: Colors.black,
                                value: checkThree,
                                onChanged: (bool? value)
                                {
                                  setState
                                  (()
                                    {
                                      checkThree = value!;
                                      checkAll = ( (checkTwo && checkThree) || (checkThree && ignoreTwo) ) ? true : false;
                                    }
                                  );
                                  if(checkThree == false)
                                  {
                                    _removeAllThree(true);
                                  }
                                  else
                                  {
                                    _removeAllThree(false);
                                  }
                                }
                              ),
                            ),
                          ),
                          Flexible
                          (
                            child: Padding
                            (
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text
                              (
                                'SLOGOVI TRI SLOVA',
                                style: ignoreThree ? ignoreTextStyle() : textStyle(),
                              ),
                            ),
                          ),
                          IconButton
                          (
                            iconSize: 32.0,
                            onPressed: () =>
                            {
                              _showCategoryThreeDialog(),
                            },
                            icon: Icon(Icons.more_vert),
                          )
                        ]
                      ),
                    ),
                  ),
                ),
                Padding
                (
                  padding: const EdgeInsets.symmetric(vertical: 45.0, horizontal: 20.0),
                  child: SizedBox
                  (
                    width: MediaQuery.of(context).size.width / 1.25,
                    child: Container
                    (
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration
                      (
                        color: Color.fromARGB(255, 231, 231, 231),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Row
                      (
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                        [
                          Flexible
                          (
                            child: Padding
                            (
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text
                              (
                                _selectedSyllables.isEmpty ?
                                'Nema odabranih slogova. Molimo odaberite barem jedan slog.' : checkAll ?
                                'Odabrani su svi slogovi.' :
                                'ODABRANI SLOGOVI:\n\n${_selectedSyllables.join(', ')}',
                                style: textStyleInfo(),
                              ),
                            ),
                          ),
                        ]
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      );
    }
}
