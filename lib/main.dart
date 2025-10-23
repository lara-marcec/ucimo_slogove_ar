import 'package:flutter/material.dart';
import 'screens/main_page.dart';


void main() 
{
  runApp(MyApp());
}

class MyApp extends StatelessWidget 
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      debugShowCheckedModeBanner: false,
      title: 'Učimo slogove',

      theme: ThemeData
      (
        scaffoldBackgroundColor: const Color(0xFFEFEFEF),
        dialogBackgroundColor: Colors.white,
      
        fontFamily: 'Tahoma',
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

