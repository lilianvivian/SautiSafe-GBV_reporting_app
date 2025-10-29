import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'screens/auth_page.dart';
import 'firebase_options.dart';

// Import all your pages
import 'screens/home_page.dart';
import 'screens/admin_page.dart';
import 'screens/welcome_page.dart';
import 'screens/about_page.dart';
import 'screens/forgot_password_page.dart';
import 'screens/realtime_sos_page.dart';
import 'screens/report_page.dart';
import 'screens/resources_page.dart';
import 'screens/sos_map_crossplatform.dart';
import 'screens/sos_page.dart';
import 'screens/panic_exit_page.dart'; 
import 'screens/camouflage_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    // Use platform-specific Firebase options (auto-detects web, windows, etc.)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GBVReportingApp());
}

class GBVReportingApp extends StatelessWidget {
  const GBVReportingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SautiSafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/home': (context) => const HomePage(),
        '/about': (context) => const AboutPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/admin': (context) => const AdminPage(),
        '/auth': (context) => const AuthPage(),
        '/realtimeSOS': (context) => const RealTimeSOSPage(),
        '/report': (context) => const ReportCasePage(),
        '/resources': (context) => const ResourcesPage(),
        '/sosMap': (context) => const SOSMapCrossPlatformPage(),
        '/sos': (context) => const SOSPage(),
      },
    );
  }
}
