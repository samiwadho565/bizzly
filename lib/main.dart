import 'package:bizly/views/auth/login_screen.dart';
import 'package:bizly/views/auth/signup_screen.dart';
import 'package:bizly/views/home/home_screen.dart';
import 'package:bizly/views/nav_bar/main_screen.dart';
import 'package:bizly/views/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bizly',
      theme: ThemeData(
        textTheme: GoogleFonts.akatabTextTheme()
      ),
      home:MainScreen(),
    );
  }
}


