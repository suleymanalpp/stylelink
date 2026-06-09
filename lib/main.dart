import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// Sayfalarının yollarını prorendeki klasör yapısına göre kontrol et:
import 'package:bapp1/screens/login_screen.dart'; 
import 'package:bapp1/screens/register_screen.dart'; 

void main() async {
  // Flutter elementlerinin Firebase başlamadan önce hazır olmasını garanti eder
  WidgetsFlutterBinding.ensureInitialized();
  
  // Uygulamanızı mevcut test veritabanınıza bağlar
  await Firebase.initializeApp(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StyleLink',
      debugShowCheckedModeBanner: false, // Sağ üstteki kırmızı test bandını kaldırır
      theme: ThemeData(
        // Giriş ekranının koyu temasıyla uyumlu olması için karanlık şema alt yapısı
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37), // Altın sarısı rengini ana tema rengi yaptık
          brightness: Brightness.dark,       // Sistemi koyu temaya adapte eder
        ),
        useMaterial3: true,
      ),
      
      // --- TEST EDİLECEK SAYFA SEÇİMİ ---
      // Giriş ekranını test etmek için burayı 'LoginScreen()' yapıyoruz.
      // Eğer doğrudan kayıt ekranını açmak istersen 'RegisterScreen()' yazabilirsin.
      home: const RegisterScreen(), 
    );
  }
}