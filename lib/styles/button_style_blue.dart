import 'package:flutter/material.dart';

ButtonStyle buttonStyleBlue() => ButtonStyle
(
  padding: WidgetStateProperty.resolveWith( (states) =>  EdgeInsets.all(20.0)),
  backgroundColor: WidgetStateColor.resolveWith((states) => Color.fromARGB(255, 0, 86, 199)),
  shape: WidgetStateProperty.resolveWith<OutlinedBorder?> 
  (
    (Set<WidgetState> states) 
    {
      return RoundedRectangleBorder
      (
        borderRadius: BorderRadius.circular(15.0),
      );
    }
  )    
);