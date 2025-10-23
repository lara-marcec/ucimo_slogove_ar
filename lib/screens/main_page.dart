import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucimo_slogove/dialogs/exit_alert_dialog.dart';
import 'package:ucimo_slogove/services/syllable_service.dart';
import 'package:ucimo_slogove/styles/button_style_yellow.dart';
import 'game_page.dart';
import 'menu_page.dart';

class MyHomePage extends StatefulWidget
{
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
{
  late final SyllableService _syllableService = SyllableService();

  @override
  void initState()
  {
    super.initState();
    _loadInitial();
  }
  Future<void> _loadInitial() async {
    await _syllableService.loadDefaultSyllables();
    await _syllableService.loadSyllableCategories();
    await _syllableService.loadSyllablesDivided();
    await loadSharedPrefs();
  }
  
  Future<void> loadSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool('naglasavanje', prefs.getBool('naglasavanje') ?? true);
    prefs.setBool('izgovor', prefs.getBool('izgovor') ?? true);
    prefs.setString('velicina', prefs.getString('velicina') ?? 'mala');
    prefs.setBool('boja', prefs.getBool('boja') ?? true);

  }

  Future<void> _showExitAlert(String orientation) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ExitAlertDialog(orientation: orientation);
      },
    );
  }

  
  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: OrientationBuilder
      (
        builder:(context, orientation)
        {
          return Center
          (
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Stack
              (
                children:
                [
                  Container
                  (
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
                    alignment: Alignment.topLeft,
                    child: IconButton
                    (
                      padding: EdgeInsets.all(12.0),
                      iconSize: 40,
                      onPressed: () {
                        _showExitAlert(orientation == Orientation.landscape ? 'landscape' : 'portrait');
                      },
                      icon: Icon(Icons.power_settings_new_rounded, color:const Color.fromARGB(255, 31, 31, 31)),
                      alignment: Alignment.center,
                      style: buttonStyleYellow(),
                    ),
                  ),
                  Container
                  (
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
                    alignment: Alignment.topRight,
                    child: IconButton
                    (
                      padding: EdgeInsets.all(12.0),
                      iconSize: 40,
                      onPressed: ()
                      {
                        Navigator.push
                        (
                          context,
                          MaterialPageRoute(builder: (context) => const MainMenuRoute()),
                        );
                      },
                      icon: Icon(Icons.settings_rounded, color:const Color.fromARGB(255, 31, 31, 31)),
                      alignment: Alignment.center,
                      style: buttonStyleYellow(),
                    ),
                  ),
                
                  Padding
                  (
                    padding: EdgeInsets.zero,
                    child: Column
                    (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                      [
                        Container
                        (
                          alignment: orientation == Orientation.portrait ? Alignment.center : Alignment.center,
              
                          constraints: BoxConstraints.loose
                          (
                            Size
                            (
                              orientation == Orientation.portrait ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width / 1.25,
                              orientation == Orientation.portrait ? MediaQuery.of(context).size.height / 1.5 : MediaQuery.of(context).size.height / 2.35,
                            )
                          ),
                          child: Image.asset
                          (
                            orientation == Orientation.portrait ? 'assets/images/ucimo_slogove_rows_cropped.png' : 'assets/images/ucimo_slogove_1920_1080.png' ,
                            fit: BoxFit.cover
                            
                          ),
                        ),
                
                        Align
                        (
                          alignment: Alignment.bottomCenter,
                          child: Padding
                          (
                            padding: orientation == Orientation.portrait ? const EdgeInsets.only(top: 0.0) : const EdgeInsets.only(top: 0.0) ,
                            child: ElevatedButton
                            (
                              onPressed: () {
                                Navigator.push
                                (
                                  context,
                                  MaterialPageRoute(builder: (context) => const MyGamePage()),
                                );
                              },
                        
                              style: buttonStyleYellow(),
                            
                              child: Row
                              (
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>
                                [
                                  Padding
                                  (
                                    padding: const EdgeInsets.only(left: 0.0, right: 8.0),
                                    child: Icon
                                    (
                                      size: 40.0,
                                      Icons.play_arrow,
                                    ),
                                  ),
                                  Padding
                                  (
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text
                                    (
                                      "POKRENI",
                                      style: TextStyle
                                      (
                                        fontSize:30.0,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.75,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ),
                          ),
                        ),
                      ]
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
