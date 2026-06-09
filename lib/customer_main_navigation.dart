import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart'; // Çıkış yapınca dönülecek ekran

class CustomerMainNavigation extends StatefulWidget {
  const CustomerMainNavigation({super.key});

  @override
  State<CustomerMainNavigation> createState() => _CustomerMainNavigationState();
}

class _CustomerMainNavigationState extends State<CustomerMainNavigation> {
  int _selectedIndex = 0; // Aktif olan sekmenin indeksi

  // Alt menüden seçilen indekse göre ekrana gelecek geçici taslak sayfalar
  final List<Widget> _pages = [
    const Scaffold(body: Center(child: Text("Müşteri Ana Sayfası (Berber Listesi)", style: TextStyle(fontSize: 20)))),
    const Scaffold(body: Center(child: Text("Randevularım Ekranı", style: TextStyle(fontSize: 20)))),
    const CustomerProfilePlaceholder(), // Çıkış butonunu test etmek için profil taslağı
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Seçili sayfayı ekranda gösterir
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Sekme değiştikçe ekranı günceller
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Randevularım'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// Profil sekmesinde çıkış yapmayı test edebilmeniz için küçük bir yardımcı widget
class CustomerProfilePlaceholder extends StatelessWidget {
  const CustomerProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profilim")),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            await FirebaseAuth.instance.signOut(); // Oturumu kapat
            if (!context.mounted) return;
            // Kullanıcıyı giriş ekranına geri fırlat
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
          child: const Text("Çıkış Yap", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}