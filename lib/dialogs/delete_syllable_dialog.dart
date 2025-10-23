import 'package:flutter/material.dart';
import 'package:ucimo_slogove/styles/button_style_blue.dart';
import 'package:ucimo_slogove/styles/button_style_yellow.dart';
import 'package:ucimo_slogove/styles/text_style.dart';

class DeleteSyllableDialog extends StatefulWidget {
  final String syllable;
  final Function onDeleteConfirmed;

  const DeleteSyllableDialog
  (
    {
      required this.syllable,
      required this.onDeleteConfirmed,
      super.key,
    }
  );

  @override
  DeleteSyllableDialogState createState() => DeleteSyllableDialogState();
}

class DeleteSyllableDialogState extends State<DeleteSyllableDialog> 
{

  Widget buildCancelButton(Orientation orientation)
  {
    return Padding
    (
      padding: orientation == Orientation.landscape ? EdgeInsets.symmetric(horizontal: 8.0) : EdgeInsets.symmetric(vertical: 8.0) ,
      child: Container
      (
        alignment: Alignment.center,
        child: SizedBox
        (
          width: orientation == Orientation.landscape ? MediaQuery.of(context).size.width / 2.95 : MediaQuery.of(context).size.width / 1.5,
          child: TextButton
          (
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: buttonStyleYellow(),
            child: Text
            (
              'ODUSTANI', 
              style: textStyleButtonBlack()
            )
          ),
        ),
      ),
    );
  }

  Widget buildSaveButton(Orientation orientation) 
  {
    return Padding
    (
      padding: orientation == Orientation.landscape ? EdgeInsets.symmetric(horizontal: 8.0) : EdgeInsets.symmetric(vertical: 8.0) ,
      child: Container
      (
        alignment: Alignment.center,
        child: SizedBox
        (
          width: orientation == Orientation.landscape ? MediaQuery.of(context).size.width / 2.95 : MediaQuery.of(context).size.width / 1.5,
          child: TextButton
          (
            onPressed: () {
              widget.onDeleteConfirmed();
              Navigator.of(context).pop();
            },
            style: buttonStyleBlue(),
            child: Text
            (
              'DA, OBRIŠI SLOG',
              style: textStyleButtonWhite()
            )
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return OrientationBuilder(
      builder: (context, orientation) {
        return AlertDialog
        (
          surfaceTintColor: Colors.transparent,
          actionsPadding: EdgeInsets.all(15.0),
          title: Text
          (
            "Jeste li sigurni da želite obrisati slog: ${widget.syllable}?",
            textAlign: TextAlign.center,
            style: textStyleDialog(),
          ),
          
          actions: <Widget>
          [
            Container
            (
              child: orientation == Orientation.landscape ? 
              Row
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children: 
                [
                  buildCancelButton(orientation),
                  buildSaveButton(orientation),
                ]
              ) : 
              Column
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children: 
                [
                  buildCancelButton(orientation),
                  buildSaveButton(orientation),
                ],
              )
            ),
          ],
        );
      }
    );
  }
}
