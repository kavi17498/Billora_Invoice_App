import 'package:flutter/material.dart';

class Buttoncomponent extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final TextStyle textStyle;
  const Buttoncomponent({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: color,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }
}
