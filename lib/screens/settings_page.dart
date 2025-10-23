import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucimo_slogove/styles/text_style.dart';

enum Naglasavanje {on, off}
enum Izgovor {on, off}
enum Slova {velika, mala, kombinacija}
enum Boja {crna, crvena}
enum ARScene { on, off }


class SettingsRoute extends StatefulWidget
{
  const SettingsRoute({super.key});

  @override
  SettingsRouteState createState() => SettingsRouteState();
}
class SettingsRouteState extends State<SettingsRoute>
{
  late ScrollController _scrollController;

  Future<void> _saveNaglasavanje() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_naglasavanje == Naglasavanje.on)
    {
      await prefs.setBool('naglasavanje', true);
    }
    else
    {
      await prefs.setBool('naglasavanje', false);
    }
  }
  
  Future<void> _saveIzgovor() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('izgovor', _izgovor == Izgovor.on);
  }
  
  Future<void> _saveVelicina () async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String velicinaValue;

    switch (_slova)
    {
      case Slova.mala:
        velicinaValue = 'mala';
      case Slova.velika:
        velicinaValue = 'velika';
      case Slova.kombinacija:
        velicinaValue = 'kombinacija';
      default:
        velicinaValue = 'mala';
        break;
    }

    await prefs.setString('velicina', velicinaValue);
  }

  ARScene? _arScene;

  Future<void> _saveARScene() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ar_scene', _arScene == ARScene.on);
  }


  Future<void> _saveBoja () async 
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(_boja == Boja.crna )
    {
      await prefs.setBool('boja', true );
    }
    else
    {
      await prefs.setBool('boja', false );
    }
  }
  
  TextStyle optionTitleStyle() 
  {
    return TextStyle
    (
      fontSize: 26.0,
      fontFamily: 'Tahoma',
      letterSpacing: 0.75,
      fontWeight: FontWeight.w600,
    );
  }
  
  TextStyle buttonTextStyleOff() 
  {
    return TextStyle
    (
      fontFamily: 'Tahoma',
      letterSpacing: 1.2,
      fontSize: 23.0,
      color: Colors.black,
      fontWeight: FontWeight.normal
    );
  }
  
  TextStyle buttonTextStyleOn() 
  {
    return TextStyle
    (
      fontFamily: 'Tahoma',
      letterSpacing: 1.2,
      fontSize: 23.0,
      color:const Color.fromARGB(255, 0, 86, 199),
      fontWeight: FontWeight.w700,
    );
  }

  Izgovor? _izgovor;
  Naglasavanje? _naglasavanje;
  Slova? _slova;
  Boja? _boja;

Future<void> loadSharedPrefs() async 
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? naglasavanje = prefs.getBool('naglasavanje');
    final bool? izgovor = prefs.getBool('izgovor');
    final String? velicina = prefs.getString('velicina'); 
    final bool? boja = prefs.getBool('boja');

    if(naglasavanje == null)
    {
      prefs.setBool('naglasavanje', true);
    }
    if(izgovor == null)
    {
      prefs.setBool('izgovor', true);
    }
    if(velicina == null)
    {
      prefs.setString('velicina', 'kombinacija');
    }
    if(boja == null)
    {
      prefs.setBool('boja', true);
    }
 
    if(naglasavanje == true)
    {
      setState(() 
      {
        _naglasavanje = Naglasavanje.on;
      });
    }
    else 
    {
      setState(() 
      {
        _naglasavanje = Naglasavanje.off;
      });
    }

    if(izgovor == true)
    {
      setState(() {
        _izgovor = Izgovor.on;
      });
    }
    else
    {
      setState(() {
        _izgovor = Izgovor.off;
      });
    }

    if(velicina == 'velika')
    {
      setState(() {
        _slova = Slova.velika;
      });
    }
    else if (velicina == 'mala')
    {
      setState(() {
        _slova = Slova.mala;
      });
    }
    else
    {
      setState(() {
        _slova = Slova.kombinacija;
      });
    }

    if(boja == true)
    {
      setState(() {
        _boja = Boja.crna;
      });
    }
    else {
      setState(() {
        _boja = Boja.crvena;
      });
    }
    final bool? arScene = prefs.getBool('ar_scene');

    if (arScene == null) {
      prefs.setBool('ar_scene', false); 
    }

    setState(() {
      _arScene = arScene == true ? ARScene.on : ARScene.off;
    });


    _saveBoja();
    _saveIzgovor();
    _saveNaglasavanje();
    _saveVelicina();
  }

  @override
  void initState() 
  {
    super.initState();
    loadSharedPrefs();
    _scrollController = ScrollController();
  }

  @override
  void dispose() 
  {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build (BuildContext context) 
  {
    return Scaffold
    (
      backgroundColor: Colors.white,
      appBar: AppBar
      (        
        toolbarHeight: (MediaQuery.of(context).size.height / 10),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text("Postavke prikaza"),
      ),
      body: Padding
      (
        padding: const EdgeInsets.all(5.0),
        child: Stack
        (
          children: 
          [
            Padding(
              padding: const EdgeInsets.only(right:5.0),
              child: Scrollbar
              (
                radius: Radius.circular(15.0),
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 20.0,
                interactive: true,
                controller: _scrollController,
                child: SingleChildScrollView
                (
                  controller: _scrollController,
                  child: Center
                  (
                    child: Container
                    (
                      alignment: AlignmentDirectional.topStart,
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: SizedBox
                      (
                        width: MediaQuery.of(context).size.width - 55.0,
                        child: Column
                        (
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:
                          [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 217, 237, 255),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: _arSceneToggle(),
                              ),
                            ),
                            Padding
                            (
                              padding: const EdgeInsets.symmetric(vertical: 18.0),
                              child: Container
                              (
                                decoration: BoxDecoration
                                (
                                  color: Color.fromARGB(255, 217, 237, 255),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: _naglasavanjeSlogova()
                              ),
                            ),
                            Padding
                            (
                              padding: const EdgeInsets.symmetric(vertical: 18.0),
                              child: Container
                              (
                                decoration: BoxDecoration
                                (
                                  color: Color.fromARGB(255, 217, 237, 255),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: _izgovorSlogova()
                              ),
                            ),
                            Padding
                            (
                              padding: const EdgeInsets.symmetric(vertical: 18.0),
                              child: Container
                              (
                                decoration: BoxDecoration
                                (
                                  color: Color.fromARGB(255, 217, 237, 255),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: _velicinaSlova()
                              ),
                            ),
                            IgnorePointer
                            (
                              ignoring: _naglasavanje == Naglasavanje.on,
                              child: Padding
                              (
                                padding: const EdgeInsets.symmetric(vertical: 18.0),
                                child: Container
                                (
                                  decoration: BoxDecoration
                                  (
                                    color: _naglasavanje == Naglasavanje.on ? Color.fromARGB(255, 231, 231, 231) : Color.fromARGB(255, 217, 237, 255),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: _bojaSlogova()
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _naglasavanjeSlogova()
  {
    return Column
    (
      children:
      [
        SizedBox(
          width: (MediaQuery.of(context).size.width - 26.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text
            (
              "Naglašavanje slogova ",
              style: optionTitleStyle(),
            ),
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 26.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
            child: Text
            (
              "Uključi/isključi opciju za naglašavanje slova u slogu.",
              style: textStyleInfo(),
            ),
          ),
        ),

        Row
        (
          children: 
          [
          SizedBox
          (
            width: (MediaQuery.of(context).size.width - 55.0) / 2.0,
            child: GestureDetector
            (
              onTap: () {
                setState(() {
                  _naglasavanje = Naglasavanje.on;
                });
                _saveNaglasavanje();
              },
              child: Container
              (
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                alignment: Alignment.center,
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _naglasavanje == Naglasavanje.on ? Color.fromARGB(255, 255, 255, 255) : null,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: FittedBox
                (
                  fit: BoxFit.scaleDown,
                  child: Text
                  (
                    'UKLJUČENO',
                    textAlign: TextAlign.center,
                    style: _naglasavanje == Naglasavanje.on ? buttonTextStyleOn() : buttonTextStyleOff(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox
          (
            width: (MediaQuery.of(context).size.width - 55.0) / 2.0,
            child: GestureDetector
            (
              onTap: () {
                setState(() {
                  _naglasavanje = Naglasavanje.off;
                });
                _saveNaglasavanje();
              },
              child: Container
              (
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                alignment: Alignment.center,
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _naglasavanje == Naglasavanje.off ? Color.fromARGB(255, 255, 255, 255) : null,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: FittedBox
                (
                  fit: BoxFit.scaleDown,
                  child: Text
                  (
                    'ISKLJUČENO',
                    textAlign: TextAlign.center,
                    style: _naglasavanje == Naglasavanje.off ? buttonTextStyleOn() : buttonTextStyleOff(),
                  ),
                ),
              ),
            ),
          ),
          ],
        )
      ],
    );
  }

  Widget _izgovorSlogova()
  {
    return Column
    (
      children: 
      [ 
        SizedBox(
          width: (MediaQuery.of(context).size.width - 26.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text
            (
              "Izgovor slogova",
              style: optionTitleStyle(),
            ),
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 26.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
            child: Text
            (
              "Uključi/isključi audio izgovor slogova.",
              style: textStyleInfo(),
            ),
          ),
        ),

        Row
        (
          children: 
          [
          SizedBox
          (
            width: (MediaQuery.of(context).size.width - 55.0) / 2.0,
            child: GestureDetector
            (
              onTap: () {
                setState(() {
                  _izgovor = Izgovor.on;
                });
                _saveIzgovor();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                alignment: Alignment.center,
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _izgovor == Izgovor.on ? Color.fromARGB(255, 255, 255, 255) : null,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: FittedBox
                (
                  fit: BoxFit.scaleDown,
                  child: Text
                  (
                    'UKLJUČENO',
                    textAlign: TextAlign.center,
                    style:_izgovor == Izgovor.on ? buttonTextStyleOn() : buttonTextStyleOff(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox
          (
            width: (MediaQuery.of(context).size.width - 55.0) / 2.0,
            child: GestureDetector
            (
              onTap: () {
                setState(() {
                  _izgovor = Izgovor.off;
                });
                _saveIzgovor();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                alignment: Alignment.center,
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _izgovor == Izgovor.off ? Color.fromARGB(255, 255, 255, 255) : null,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: FittedBox
                (
                  fit: BoxFit.scaleDown,
                  child: Text
                  (
                    'ISKLJUČENO',
                    textAlign: TextAlign.center,
                    style: _izgovor == Izgovor.off ? buttonTextStyleOn() : buttonTextStyleOff(),
                  ),
                ),
              ),
            ),
          ),
          ],
        )
      ],
    );
  }

  Widget _velicinaSlova() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Velika/mala slova",
            style: optionTitleStyle(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
          child: Text(
            "Odaberite želite li da su sva slova mala, prvo veliko ili sva velika.",
            style: textStyleInfo(),
          ),
        ),
        Column 
        (
          children: 
          [
            Row
            (
              children: 
              [
                SizedBox
                (
                  width: (MediaQuery.of(context).size.width - 55.0 ) / 2.0,
                  child: buildOption('mala', Slova.mala)
                ),
                SizedBox
                ( 
                  width: (MediaQuery.of(context).size.width - 55.0 ) / 2.0,
                  child: buildOption('VELIKA', Slova.velika)
                ),
              ],
            ),
            SizedBox
            ( 
              width: (MediaQuery.of(context).size.width - 55.0 ) / 1.5,
              child: buildOption('Prvo slovo veliko', Slova.kombinacija),
            ),
          ],
        ),
      ],
    );
  }

  GestureDetector buildOption(String text, Slova option) 
  {
    return GestureDetector(
      onTap: () {
        setState(() {
          _slova = option;
        });
        _saveVelicina();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
        alignment: Alignment.center,
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: _slova == option ? Color.fromARGB(255, 255, 255, 255) : null,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: FittedBox
        (
          fit: BoxFit.scaleDown,

          child: Text
          (
            text,
            textAlign: TextAlign.center,
            style:_slova == option ? buttonTextStyleOn() : buttonTextStyleOff(),
          ),
        ),
      ),
    );
  }

  Widget _bojaSlogova()
  {
    return Column
    (
      children:
      [
        SizedBox
        (
          width: (MediaQuery.of(context).size.width - 26.0),
          child: Padding
          (
            padding: const EdgeInsets.all(8.0),
            child: Text
            (
              "Boja slogova",
              style: optionTitleStyle(),
            ),
          ),
        ),
        SizedBox
        (
          width: (MediaQuery.of(context).size.width - 26.0),
          child: Padding
          (
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
            child: _naglasavanje == Naglasavanje.off ?
            Text (
              "Odaberi boju kojom će se prikazivati slogovi.",
              style: textStyleInfo(),
            ) :
            Text (
              "Odabir boje nije moguć kada je uključena opcija naglašavanja slogova.",
              style: textStyleInfo(),
            ),
          ),
        ),

        Row
        (
          children:
          [
          SizedBox
          (
            width: (MediaQuery.of(context).size.width - 55.0) / 2.0,
            child: GestureDetector
            (
              onTap: () {
                setState(() {
                  _boja = Boja.crna;
                });
                _saveBoja();
              },
              child: Container
              (
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                alignment: Alignment.center,
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration
                (
                  color: _naglasavanje == Naglasavanje.on ? Color.fromARGB(255, 231, 231, 231) :
                  _boja == Boja.crna ? Color.fromARGB(255, 255, 255, 255) : null,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: FittedBox
                (
                  fit: BoxFit.scaleDown,

                  child: Text
                  (
                    'CRNA',
                    textAlign: TextAlign.center,
                    style: _naglasavanje == Naglasavanje.on ? buttonTextStyleOff() :
                    _boja == Boja.crna ? buttonTextStyleOn() : buttonTextStyleOff(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox
          (
            width: (MediaQuery.of(context).size.width - 55.0) / 2.0,
            child: GestureDetector
            (
              onTap: () {
                setState(() {
                  _boja = Boja.crvena;
                });
                _saveBoja();
              },
              child: Container
              (
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                alignment: Alignment.center,
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration
                (
                  color: _naglasavanje == Naglasavanje.on ? Color.fromARGB(255, 231, 231, 231) :
                  _boja == Boja.crvena ? Color.fromARGB(255, 255, 255, 255) : null,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: FittedBox
                (
                  fit: BoxFit.scaleDown,
                  child: Text
                  (
                    'CRVENA',
                    textAlign: TextAlign.center,
                    style:_naglasavanje == Naglasavanje.on ? buttonTextStyleOff() : 
                    _boja == Boja.crvena ? buttonTextStyleOn() : buttonTextStyleOff(),
                  ),
                ),
              ),
            ),
          ),
          ],
        )
      ],
    );
  }

  Widget _arSceneToggle() {
  return Column(
    children: [
      SizedBox(
        width: (MediaQuery.of(context).size.width - 26.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "AR scena",
            style: optionTitleStyle(),
          ),
        ),
      ),
      SizedBox(
        width: (MediaQuery.of(context).size.width - 26.0),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
          child: Text(
            "Uključi/isključi prikaz AR scene.",
            style: textStyleInfo(),
          ),
        ),
      ),
      Row(
        children: [
          SizedBox(
            width: (MediaQuery.of(context).size.width - 55.0) / 2.0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _arScene = ARScene.on;
                });
                _saveARScene();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                alignment: Alignment.center,
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _arScene == ARScene.on ? Colors.white : null,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'UKLJUČENO',
                    textAlign: TextAlign.center,
                    style: _arScene == ARScene.on ? buttonTextStyleOn() : buttonTextStyleOff(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 55.0) / 2.0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _arScene = ARScene.off;
                });
                _saveARScene();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
                alignment: Alignment.center,
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _arScene == ARScene.off ? Colors.white : null,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'ISKLJUČENO',
                    textAlign: TextAlign.center,
                    style: _arScene == ARScene.off ? buttonTextStyleOn() : buttonTextStyleOff(),
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    ],
  );
  }
}