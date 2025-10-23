import 'package:flutter/material.dart';

ButtonStyle buttonStyleYellow() => ButtonStyle
(
  padding: WidgetStateProperty.resolveWith( (states) =>  EdgeInsets.all(18.0)),
  shape: WidgetStateProperty.resolveWith<OutlinedBorder?>(
    
    (Set<WidgetState> states) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      );
    },
  ),
  foregroundColor: WidgetStateColor.resolveWith((states) => const Color.fromARGB(255, 31, 31, 31)),
  backgroundColor: WidgetStateColor.resolveWith((states) => Color.fromARGB(255, 255, 239, 92)),
  surfaceTintColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
);