import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';

class BusinessMainNavigation extends StatefulWidget {
  const BusinessMainNavigation({super.key});

  @override
  State<BusinessMainNavigation> createState() => _BusinessMainNavigationState();
}

class _BusinessMainNavigationState extends State<BusinessMainNavigation> {
  int _selectedIndex = 0;

  // Berber paneli için geçici taslak sayfalar
  final List<Widget> _pages = [
    const Scaffold(body: Center(child: Text("Berber Paneli (Gelen Randevular)", style: TextStyle(fontSize: 20)))),
    const Scaffold(body: Center(child: Text("Hizmetler ve Fiyat Listesi", style: TextStyle(fontSize: 20)))),
    const BusinessProfilePlaceholder(), // Berber çıkış taslağı
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.amber.shade700, // Berbere özel kurumsal renk
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Randevular'),
          BottomNavigationBarItem(icon: Icon(Icons.content_cut), label: 'Hizmetlerimiz'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Dükkan Profili'),
        ],
      ),
    );
  }
}

class BusinessProfilePlaceholder extends StatelessWidget {
  const BusinessProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dükkan Yönetimi")),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
          child: const Text("Oturumu Kapat", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}