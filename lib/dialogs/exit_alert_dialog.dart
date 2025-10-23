import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ucimo_slogove/styles/button_style_blue.dart';
import 'package:ucimo_slogove/styles/button_style_yellow.dart';
import 'package:ucimo_slogove/styles/text_style.dart';

class ExitAlertDialog extends StatelessWidget{
  final String orientation;

  const ExitAlertDialog({required this.orientation});

  @override
  Widget build(BuildContext context) {
    return AlertDialog
    (
      surfaceTintColor: Colors.transparent,
      actionsPadding: EdgeInsets.all(10.0),
      title: Text
      (
        textAlign: TextAlign.center,
        'Želite li izaći iz igre?',
        style: textStyleDialog(),
      ),
      actions: <Widget> [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: orientation == "landscape" ? MediaQuery.of(context).size.width / 2.5 : MediaQuery.of(context).size.width / 1.5,
              child: TextButton
              (
                style:buttonStyleYellow(),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text
                (
                  'ODUSTANI', 
                  style: textStyleButtonBlack()
                )
              ),
            ),
          ),
        ),
        Padding
        (
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container
          (
            padding: EdgeInsets.all(5.0),
            alignment: Alignment.center,
            child: SizedBox
            (
              width: orientation == "landscape" ? MediaQuery.of(context).size.width / 2.5 : MediaQuery.of(context).size.width / 1.5,
              child: TextButton
              (
                onPressed: () {
                  exit(0);
                },
                style: buttonStyleBlue(),
                child: Text(
                  'DA, IZAĐI IZ IGRE',
                  style: textStyleButtonWhite(),
                )
              ),
            ),
          ),
        )
      ],
    );
  }
}