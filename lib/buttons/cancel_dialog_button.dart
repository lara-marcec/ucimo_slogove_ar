import 'package:flutter/material.dart';
import 'package:ucimo_slogove/styles/button_style_yellow.dart';
import 'package:ucimo_slogove/styles/text_style.dart';

class CancelDialogButton extends StatelessWidget 
{
  final VoidCallback onPressed;
  final Orientation orientation;

  const CancelDialogButton({
    required this.onPressed,
    required this.orientation,
  });

  @override
  Widget build(BuildContext context) 
  {
    return Padding
    (
      padding: orientation == Orientation.landscape
          ? EdgeInsets.symmetric(horizontal: 8.0)
          : EdgeInsets.symmetric(vertical: 8.0),
      child: Container
      (
        padding: EdgeInsets.all(5.0),
        alignment: Alignment.center,
        child: SizedBox
        (
          width: orientation == Orientation.landscape
              ? MediaQuery.of(context).size.width / 2.75
              : MediaQuery.of(context).size.width / 1.5,
          child: TextButton
          (
            onPressed: onPressed,
            style: buttonStyleYellow(),
            child: FittedBox
            (
              fit: BoxFit.scaleDown,
              child: Text
              (
                'ODUSTANI', 
                style: textStyleButtonBlack(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
