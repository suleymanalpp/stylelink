import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Firebase Auth eklendi
import 'package:cloud_firestore/cloud_firestore.dart'; // 2. Firestore eklendi
import 'register_screen.dart'; // Kayıt sayfasına geçiş için
import '../customer_main_navigation.dart'; // Navigasyon yollarını kendi klasör yapına göre kontrol et
import '../business_main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  // --- GERÇEK FİREBASE LOGİN FONKSİYONU ---
  void login() async {
    // Boş alan kontrolü (Basit validasyon)
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Firebase Auth ile giriş yapılıyor
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. Giriş başarılı, Firestore'dan kullanıcının rolü okunuyor
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!mounted) return;
        setState(() => isLoading = false);

        if (userDoc.exists) {
          String role = userDoc.get('role') ?? 'customer';

          // 3. Kullanıcı rolüne göre ilgili ekrana yönlendiriliyor (Geri dönüşü kapatarak)
          if (role == 'barber') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BusinessMainNavigation()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CustomerMainNavigation()),
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Welcome to StyleLink 💈")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User role details not found!"), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      // Hata durumunda kullanıcıya gösterilecek mesaj (Türkçeleştirebilirsin)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // koyu berber teması
      body: SafeArea(
        child: Center( // İçeriği dikeyde ortalamak için Center eklendi
          child: SingleChildScrollView( // Klavye açıldığında taşma (overflow) hatası olmasın diye eklendi
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 💈 LOGO / BAŞLIK
                const Icon(
                  Icons.content_cut,
                  size: 70,
                  color: Colors.white,
                ),

                const SizedBox(height: 15),

                const Text(
                  "StyleLink",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Barber Booking App",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 40),

                // EMAIL
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress, // Klavye tipi e-posta yapıldı
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1C1C1C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1C1C1C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37), // altın berber rengi
                      disabledBackgroundColor: const Color(0xFFD4AF37).withOpacity(0.5), // Yüklenirken buton rengi solsun diye
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "SIGN IN",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                // SIGN UP YÖNLENDİRMESİ AKTİFLEŞTİRİLDİ
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}