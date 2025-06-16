import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_supreme/public/screens/AboutUs_Page.dart';
import 'package:track_supreme/public/screens/Contact_Page.dart';
import 'package:track_supreme/public/screens/Home_Page.dart';
import 'package:track_supreme/public/screens/Login_Page.dart';
import 'package:track_supreme/public/screens/Settings_Page.dart';
import 'package:track_supreme/public/screens/SignUp.dart';
import 'firebase_options.dart';

/*
NOT:
Flutter web projesini sabit portta çalıştırmak için terminalde şu komutu kullanınız:

flutter run -d chrome --web-port=5000

Bu sayede uygulama her zaman 5000 portunda açılır.
Google OAuth ve diğer servislerin ayarları bu port üzerinden yapılandırılmıştır.
Android Studio'dan Run butonuna basıldığında port değişebilir, bu nedenle terminal kullanmanız önerilir.
*/



// Ana fonksiyon - Uygulama giriş noktası
void main() async {
  // Flutter bağlamını başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i yalnızca web, Android ve iOS platformlarında başlat
  if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    debugPrint('Firebase Windows üzerinde başlatılmadı.');
  }

  // Supabase bağlantısını başlat
  await Supabase.initialize(
    url: 'https://qwfemipnyloxjkdewlvn.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3ZmVtaXBueWxveGprZGV3bHZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2NjUzMDYsImV4cCI6MjA2NTI0MTMwNn0.e_eRQRn2JxTl10j8fgq8F6MsjRzjIdUtKrPCmCauDCw',
  );

  // Uygulamayı çalıştır
  runApp(const MyApp());
}

// Ana uygulama widget'ı
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Track Supreme',
      debugShowCheckedModeBanner: false, // Hata ayıklama banner'ını gizle
      initialRoute: '/login', // Başlangıç sayfası olarak giriş ekranını ayarla

      // Rotaları yöneten fonksiyon
      onGenerateRoute: (settings) {
        // Mevcut kullanıcıyı Supabase'den al
        final user = Supabase.instance.client.auth.currentUser;

        // Rota adına göre sayfaları yönlendir
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginScreen());

          case '/signup':
            return MaterialPageRoute(builder: (_) => SignupScreen());

          case '/home':
          // Kullanıcı giriş yapmışsa ana sayfaya, yoksa giriş sayfasına yönlendir
            if (user != null) {
              return MaterialPageRoute(builder: (_) => HomeScreen(uid: user.id));
            } else {
              return MaterialPageRoute(builder: (_) => LoginScreen());
            }

          case '/about':
            return MaterialPageRoute(builder: (_) => AboutUsPage());

          case '/contact':
            return MaterialPageRoute(builder: (_) => ContactPage());

          case '/settings':
          // Kullanıcı giriş yapmışsa ayarlar sayfasına, yoksa giriş sayfasına yönlendir
            if (user != null) {
              return MaterialPageRoute(builder: (_) => SettingsPage(uid: user.id));
            } else {
              return MaterialPageRoute(builder: (_) => LoginScreen());
            }

          default:
          // Tanımsız rotalar için giriş sayfasına yönlendir
            return MaterialPageRoute(builder: (_) => LoginScreen());
        }
      },
    );
  }
}