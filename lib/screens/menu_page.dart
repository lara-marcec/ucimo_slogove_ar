import 'package:flutter/material.dart';
import 'package:ucimo_slogove/styles/text_style.dart';
import 'settings_page.dart';
import 'management_page.dart';
import 'category_page.dart';
import 'info_page.dart';

class MainMenuRoute extends StatelessWidget
{
  const MainMenuRoute({super.key});
  @override
  Widget build(BuildContext context) 
  {
    final ButtonStyle style = ElevatedButton.styleFrom
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
    );

    return Scaffold
    (
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar 
      (
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: (MediaQuery.of(context).size.height / 8),
        title: Text ("Izbornik", style: textStyleNavBar(),),
        
        actions: 
        [
          Container
            (
              alignment: Alignment.centerRight,
              child: IconButton
              (
                padding: EdgeInsets.only(left: 15.0, top: 5.0, bottom: 15.0, right: 20.0),
                iconSize: 35,
                onPressed: () 
                {
                  Navigator.push
                  (
                    context,
                    MaterialPageRoute(builder: (context) => const InfoRoute()),
                  );
                }, 
                icon: Icon(Icons.info_outline, color:const Color.fromARGB(255, 31, 31, 31)),
                alignment: Alignment.center,
              ), 
            ),
        ]
      ),
      body: Center
      (
        child: SingleChildScrollView
        (
          child: Container
          (
            margin: EdgeInsets.all(10),
            child: Column
            (
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> 
              [
                Padding
                (
                  padding: const EdgeInsets.all(25.0),
                  child: SizedBox
                  (
                    width: MediaQuery.of(context).size.width / 1.25,
                    child: ElevatedButton.icon
                    (
                      style: style,
                      icon:Padding
                      (
                        padding: const EdgeInsets.all(15.0),
                        child: Icon
                        (
                          Icons.category, 
                          size: 30.0, 
                          color:const Color.fromARGB(255, 0, 86, 199)
                        ),
                      ),
                      label: Text 
                      (
                        "Kategorije",
                        style: textStyleMenu(),
                      ),
                      onPressed: () 
                      {
                        Navigator.push(context, 
                        MaterialPageRoute(builder: (context) => const CategoryRoute()));
                      },
                    ),
                  ),
                ),
                 Padding
                 (
                   padding: const EdgeInsets.all(25.0),
                   child: SizedBox
                   (
                    width: MediaQuery.of(context).size.width / 1.25,
                     child: ElevatedButton.icon
                     (
                      style: style,
                      icon: Padding
                      (
                        padding: const EdgeInsets.all(15.0),
                        child: Icon
                        (
                          Icons.tune,
                          size: 30.0, 
                          color:Color.fromARGB(255, 0, 86, 199)
                        ),
                      ),
                      label: Text 
                      (
                        "Postavke prikaza",
                        style: textStyleMenu(),
                      ),
                      onPressed: () 
                      {
                        Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const SettingsRoute()),);
                      },
                    ),
                   ),
                 ),
                Padding
                (
                  padding: const EdgeInsets.all(25.0),
                  child: SizedBox
                  (
                    width: MediaQuery.of(context).size.width / 1.25,
                    child: ElevatedButton.icon
                    (
                      style: style,
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
                        Navigator.push(context, 
                        MaterialPageRoute(builder: (context) => const ManagementRoute()));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}