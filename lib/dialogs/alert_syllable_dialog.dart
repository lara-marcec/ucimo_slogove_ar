import 'package:flutter/material.dart';
import 'package:ucimo_slogove/styles/button_style_yellow.dart';
import 'package:ucimo_slogove/styles/text_style.dart';

class AlertSyllableDialog extends StatefulWidget {
  final String newSyllable;
  final bool newAudio;
  final Function getCategory;
  final List<String> syllablesList;
  final bool isValid;
  final bool checkAudio;

  const AlertSyllableDialog({
    required this.getCategory,
    required this.newAudio,
    required this.newSyllable,
    required this.syllablesList,
    required this.isValid,
    required this.checkAudio,
    super.key,
  });

  @override
  AlertSyllableDialogState createState() => AlertSyllableDialogState();
}

class AlertSyllableDialogState extends State<AlertSyllableDialog> 
{

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() 
  {
    super.dispose();
  }

  Widget _displayAlertDialog()  
  {
    String output = "Neispravan unos.";

    final RegExp pattern = RegExp(r'^[a-zA-ZčČćĆđĐšŠžŽ-]+$');
    bool isValid = pattern.hasMatch(widget.newSyllable);

    if(widget.newSyllable.isEmpty)
    {
      output = "$output\n Unesite slog duljine dva ili tri slova koji sadrži jednu oznaku za naglašavanje.";
    }
    else 
    {
      if(!widget.newSyllable.contains("-"))
      {
        output = "$output\n Slog mora sadržavati oznaku za naglašavanje.\nPrimjeri ispravnih unosa: k-ra, bl-e, h-a.";
      }
      else if(widget.newSyllable.startsWith("-") || widget.newSyllable.endsWith("-")){
        output = "$output\n Upisani slog ne smije započeti ili završiti oznakom za naglašavanje.\nPrimjeri ispravnih unosa: k-ra, bl-e, h-a.";
      }
      else if( widget.syllablesList.contains(widget.newSyllable.replaceAll("-", "")) )
      {
        output = "$output\n Ovaj slog već postoji.";
      }
      else
      {
        if(widget.getCategory(widget.newSyllable).isEmpty)
        {
          output = "$output\n Unesite slog duljine dva ili tri slova.";
        }

        if(isValid)
        {
          int hyphenCount = widget.newSyllable.split("-").length -1;
          if(hyphenCount != 1)
          {
            output = "$output\n Slog smije sadržavati samo jednu oznaku za naglašavanje";
          }
        }
        else
        {
          output = "$output\n Upisani slog sadrži nedopuštene znakove. Slog smije sadržavati slova hrvatske abecede.";
        }

        if( widget.checkAudio == true )
        {
          if( widget.newAudio == false ) 
          {
            output = "$output\n Snimite zvučni zapis sloga.";
          }
        }
      }
      
    }

    return AlertDialog
    (
      surfaceTintColor: Colors.transparent,
      actionsPadding: EdgeInsets.all(20.0),
      contentPadding: EdgeInsets.only(left: 25.0, right:25.0, top:10.0, bottom: 10.0),  
      title: Text
      (
        output,
        textAlign: TextAlign.center,
        style: textStyleButtonBlack(),
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
              FocusManager.instance.primaryFocus?.unfocus();
            },
            style: buttonStyleYellow(),
            child:Text
            (
              "OK",
              textAlign: TextAlign.center,
              style: textStyleButtonBlack()
            ),
          ),
        )
      ]
    ); 
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
          return Container
          (
            child: _displayAlertDialog(),
          );
          
        }
      );
      }
    );
  }

}