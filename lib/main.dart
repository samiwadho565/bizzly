import 'package:bizly/routes/app_pages.dart';
import 'package:bizly/routes/routes.dart';
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
      // initialBinding: InitialBindings(),
      // getPages: AppPages.routes,
      getPages: AppPages.routes,
      initialRoute: Routes.onBoardingScreen
    );
  }
}

