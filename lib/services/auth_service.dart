import 'package:bapp1/imports.dart';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerUser({
    required String email,
    required String password,
    required String nameSurname,
    required String phone,
    required bool isBarber,
    String? storeName,
  }) async {
    try {
      // 1. Firebase Auth ile kullanıcı oluşturuluyor
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. Kullanıcı başarılı oluştuysa Firestore'a rolü ve bilgileri kaydediliyor
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'nameSurname': nameSurname,
          'email': email,
          'phone': phone,
          'role': isBarber ? 'barber' : 'customer',
          'storeName': storeName, // Berber değilse null gidecek
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;

    } on FirebaseAuthException catch (e) {
      // --- BURASI KRİTİK: Firebase'den gelen özel hataları yakalıyoruz ---
      if (e.code == 'email-already-in-use') {
        // Bu hatayı fırlatıyoruz ki RegisterScreen ekranında yakalayıp SnackBar gösterebilelim
        throw 'Bu e-posta adresi zaten kullanımda. Lütfen başka bir e-posta deneyin.';
      } else if (e.code == 'weak-password') {
        throw 'Girdiğiniz şifre çok zayıf.';
      } else if (e.code == 'invalid-email') {
        throw 'Geçersiz bir e-posta adresi girdiniz.';
      }
      throw 'Kayıt esnasında bir hata oluştu: ${e.message}';
      
    } catch (e) {
      throw 'Beklenmedik bir hata oluştu.';
    }
  }
}


