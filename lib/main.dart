import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:invoiceapp/screens/welcome.dart";

void main() {
  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Invoice App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: Welcome(),
    );
  }
}
