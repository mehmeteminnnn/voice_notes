import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/audio_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AudioProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Voice Notes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue.shade50,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
