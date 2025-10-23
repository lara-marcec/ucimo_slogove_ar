import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ucimo_slogove/styles/text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoRoute extends StatelessWidget {
  
  const InfoRoute({super.key});
  
  @override
  Widget build (BuildContext context){
    return Scaffold
    (
      backgroundColor: Colors.white,
      appBar: AppBar
      (
        backgroundColor: Colors.white,
        toolbarHeight: (MediaQuery.of(context).size.height / 8),
        title: Text("O aplikaciji", style: textStyleNavBar(),),
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView
      (
        child: Padding
        (
          padding: const EdgeInsets.all(20.0),
          child: Container
          (
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            alignment: Alignment.center,
            child: Column
            (
              children: [
                Container
                (
                  alignment: Alignment.center,
                  constraints: BoxConstraints.loose
                  (
                    Size
                    (
                      MediaQuery.of(context).size.width / 2.0,
                      MediaQuery.of(context).size.height / 4.0 ,
                    )
                  ),
                  child: Image.asset
                  (
                    'assets/images/logo_ict_aac.png',
                    fit: BoxFit.cover
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan
                        (
                          text:'Aplikacija je razvijena u okviru završnog rada na Fakultetu elektrotehnike i računarstva Sveučilišta u Zagrebu, ak. god. 2023./2024. po uzoru na aplikaciju Učimo slogove razvijenu u suradnji FER-a s Hrvatskom zajednicom za Down sindrom.\n\nAplikaciju je izradila Lara Marčec pod mentorstvom prof. dr. sc. Željka Car te dr. sc. Matea Žilak.\n\nZvučne zapise za slogove nasnimila je Tanja Kaurić.\n\n',
                        ),

                      TextSpan
                      (
                        text: 'Politika privatnosti aplikacije: ',
                      ),
                      TextSpan
                      (
                        text: 'http://www.ict-aac.hr/index.php/hr/politika-privatnosti\n',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse('http://www.ict-aac.hr/index.php/hr/politika-privatnosti'));
                          },
                        style: TextStyle(color: Colors.blue),
                      ),

                      TextSpan
                      (
                        text: 'Privacy policy: ',
                      ),
                      TextSpan
                      (
                        text: 'http://www.ict-aac.hr/index.php/en/privacy-policy',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse('http://www.ict-aac.hr/index.php/en/privacy-policy'));
                          },
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.justify,
                  style: textStyleInfo(),
                ),

              ],
            )
          ),
        ),
      )
    );
  }
}