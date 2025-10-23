import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucimo_slogove/screens/main_page.dart';
import '../services/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'unity_ar_page.dart';

class MyGamePage extends StatefulWidget
{
  const MyGamePage({super.key});

  @override
  MyGamePageState createState() => MyGamePageState();
}


class MyGamePageState extends State<MyGamePage> {
  late final AudioService _audioService = AudioService();
  
  String currentSyllable = "";
  int syllableCounter = 0;
  int nextARThreshold = 4;
  
  Future<String> getDivided(String syllable) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    List<String>? syllDivided = prefs.getStringList('syllablesDivided');

    if(syllDivided != null){
      for (int i = 0; i < syllDivided.length; i++) {
        String temp = syllDivided[i].replaceAll("-", "");
        if (temp == syllable) {
          return syllDivided[i];
        }
      }
    }
    return "";
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar
        (
          const SnackBar(content: Text('Camera permission is required to use AR.'))
        );
      }
    }
  }

  Future<Container> syllableText() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? velicina = prefs.getString('velicina');
    final bool? naglasavanje = prefs.getBool('naglasavanje');
    final bool? boja = prefs.getBool('boja');
    

    final String dividedSyll =  await getDivided(currentSyllable);
    
    if (dividedSyll.isEmpty)
    {
      await Future.delayed(Duration(milliseconds: 500));
      if (currentSyllable.isNotEmpty)
      {
        return Container();
      } else
      {
        await Future.delayed(Duration(milliseconds: 100));
        return Container
        (
          padding: EdgeInsets.all(25.0),
          alignment: Alignment.center,
          child: Text
          (
            "Nema odabranih slogova. Molimo odaberite slogove.",
            textAlign: TextAlign.center,
            style: TextStyle
            (
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 211, 0, 0),
              fontSize: 30.0,
              fontFamily: 'Tahoma'
            ),
          )
        );
      }
    }
    else
    {
      if(naglasavanje == true)
      {
        String blackPart = dividedSyll.split("-")[0];
        String redPart = dividedSyll.split("-")[1];
        print(blackPart);
        return Container
        (
          child: FittedBox
          (
            fit: BoxFit.scaleDown,
            child: RichText
            (
              text: TextSpan
              (
                children:
                [
                  TextSpan
                  (
                    text: velicina == "velika" ? blackPart.toUpperCase() : velicina == "mala" ?
                      blackPart.toLowerCase() : velicina == "kombinacija" ? blackPart.substring(0, 1).toUpperCase() +
                      blackPart.substring(1).toLowerCase() : "e",
                    style: TextStyle
                    (
                      letterSpacing: 5.5,
                      color: Colors.black,
                      fontSize: 200,
                      fontFamily: 'Tahoma'
                    ),
                  ),
                  TextSpan
                  (
                    text: velicina == "velika" ? redPart.toUpperCase() : velicina == "mala" ? 
                      redPart.toLowerCase() : velicina == "kombinacija" ? redPart.toLowerCase() : "e",
                    style: TextStyle
                    (
                      letterSpacing: 5.5,
                      color: Colors.red,
                      fontSize: 200,
                      fontFamily: 'Tahoma'
                    ),
                  ),
                ],
              ),
                    ),
          )
      );
      }
      else if(naglasavanje == false) {
        return Container
        (
          child: FittedBox
          (
            fit: BoxFit.scaleDown,
            child: Text
            (
              velicina == "velika" ? currentSyllable.toUpperCase() : velicina == "mala" ?
                currentSyllable.toLowerCase() : velicina == "kombinacija" ? currentSyllable.substring(0, 1).toUpperCase() +
                currentSyllable.substring(1).toLowerCase() : "error",
                
              style: TextStyle
              (
                letterSpacing: 5.5,
                color: boja == true ? Colors.black : Colors.red,
                fontSize: 200,
                fontFamily: 'Tahoma'
              ),
            ),
          )
        );
      }
      else {return ( Container(child: Text("error"))); }
    }
    
  }

  @override
  void initState() {
    super.initState();
    _playRandomSyllable();
  }
  Future<void> _playRandomSyllable() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool arEnabled = prefs.getBool('ar_scene') ?? false;
    try
    {
      if (arEnabled)
      {
        syllableCounter++;
        if (syllableCounter >= nextARThreshold)
        {
          await _requestCameraPermission();
          if (await Permission.camera.isGranted)
          {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UnityARPage()),
            );
          }
          syllableCounter=0;
        nextARThreshold = nextARThreshold + 2;
      } else {
      }

      }
      final String filename = await _audioService.playRandomSyllable();
      setState(() {
        currentSyllable = filename
        .replaceAll('.mp3', '')
        .replaceAll('sounds/', '')
        .replaceAll('dd', 'đ')
        .replaceAll('zh', 'ž')
        .replaceAll('ch', 'č')
        .replaceAll('cc', 'ć')
        .replaceAll('sh', 'š');

      });
      print('Random syllable: $filename');
    }
    catch (e) {
      print('Error playing random syllable: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      backgroundColor: Colors.white,
      body:GestureDetector
      (
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _playRandomSyllable();
        },
        child: Stack(
          children:
          [
            Container
            (
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 35.0),
              alignment: Alignment.topLeft,
              child: IconButton
              (
                iconSize: 40,
                onPressed: () {
                  Navigator.push
                  (
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                },
                icon: Icon(Icons.arrow_back, color:const Color.fromARGB(255, 31, 31, 31)),
                alignment: Alignment.center,
              ),
            ),
            Center
            (
              child: FutureBuilder<Container>
              (
                future: syllableText(),
                builder: (BuildContext context, AsyncSnapshot<Container> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                  {
                    return Center
                    (
                      child: CircularProgressIndicator(),
                    );
                  }
                  else if (snapshot.hasError)
                  {
                    {
                      return Container();
                    }
                  }
                  else
                  {
                    return snapshot.data!;
                  }
                }
              ),
            ),
          ]
        )
      )
    );
  }
  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}