import 'package:flutter/material.dart';
import 'package:ucimo_slogove/styles/button_style_yellow.dart';

class SaveButton extends StatelessWidget 
{
  final VoidCallback onPressed; 

  SaveButton({required this.onPressed}); 

  @override
  Widget build(BuildContext context) 
  {
    return Container
    (
      padding: EdgeInsets.all(5.0),
      alignment: Alignment.centerRight,
      child: TextButton
      (
        onPressed: onPressed, 
        style: buttonStyleYellow(),
        child: Text
        (
          'SPREMI',
          style: TextStyle
          (
            fontWeight: FontWeight.w700,
            fontSize: 20.0,
            letterSpacing: 1.75,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
