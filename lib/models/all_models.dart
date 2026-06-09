import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//ENUM DEĞERLERİ
enum UserType { customer, barber }
enum ImageType { profile, gallery }



// --- MÜŞTERİ  MODELİ ---
class CustomerModel {
  final String uid;
  final String name;
  final String email;
  final String phone;

  CustomerModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory CustomerModel.fromMap(String uid, Map<String, dynamic> map) {
    return CustomerModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}

// --- BERBER PROFİLİ MODELİ ---
class BarberModel {
  final String uid;
  final String name;       // 🔥 Berberin şahsi adı (Örn: "Ahmet Yılmaz")
  final String shopName;   // Dükkan adı (Örn: "Makas Klas")
  final String email;      // 🔥 Berberin e-posta adresi
  final String phone;      // Telefon numarası
  final double rating;     // Ortalama puan
  final int reviewCount;   // Yorum sayısı

  BarberModel({
    required this.uid,
    required this.name,
    required this.shopName,
    required this.email,
    required this.phone,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory BarberModel.fromMap(String uid, Map<String, dynamic> map) {
    return BarberModel(
      uid: uid,
      name: map['name'] ?? '',       // 🔥 Firestore'dan güvenli okuma
      shopName: map['shopName'] ?? '',
      email: map['email'] ?? '',     // 🔥 Firestore'dan güvenli okuma
      phone: map['phone'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,           // 🔥 Firestore'a kaydetmek için haritaya eklendi
      'shopName': shopName,
      'email': email,         // 🔥 Firestore'a kaydetmek için haritaya eklendi
      'phone': phone,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}
// --- RANDEVU MODELİ ---
class Appointment {
  final String id;
  final String barberId;   // Randevu alınan berber
  final String customerId; // Randevuyu alan müşteri
  final String serviceId;  // Alınacak hizmet
  final String serviceName;// İlişki kopsa bile faturada görünmesi için hizmet adı kaydı
  final double price;      // O an anlaşılan fiyat (İleride zam gelse de bu sabit kalır)
  final DateTime dateTime; // Randevu tarihi ve saati
  final String status;     // "pending" (bekliyor), "approved" (onaylandı), "canceled" (iptal)

  Appointment({
    required this.id,
    required this.barberId,
    required this.customerId,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.dateTime,
    this.status = 'pending',
  });

  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    return Appointment(
      id: id,
      barberId: map['barberId'] ?? '',
      customerId: map['customerId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      dateTime: map['dateTime'] != null 
          ? DateTime.parse(map['dateTime']) 
          : DateTime.now(),
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barberId': barberId,
      'customerId': customerId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'price': price,
      'dateTime': dateTime.toIso8601String(), // Tarihi güvenli String formatına çeviriyoruz
      'status': status,
    };
  }
}

//BERBER HİZMET MODELİ
class BarberService {
  final String id;
  final String barberId; // Bu hizmet hangi berbere ait?
  final String name;
  final String description;
  final double price;
  final int durationMinutes;

  BarberService({
    required this.id,
    required this.barberId,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
  });

  factory BarberService.fromMap(String id, Map<String, dynamic> map) {
    return BarberService(
      id: id,
      barberId: map['barberId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      durationMinutes: map['durationMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barberId': barberId,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
    };
  }
}

// ÇALIŞMA SAATLERİ MODELİ
class WorkingHours {
  final String id;                // 🔥 Firestore'daki çalışma saatleri dökümanının kendi ID'si
  final String barberId;          // 🔥 Bu çalışma saatlerinin hangi berbere ait olduğu (Bağlantı Kimliği)
  final String openTime;          // Örn: "09:00"
  final String closeTime;         // Örn: "22:00"
  final int slotDurationMinutes;  // Randevu aralığı dakika cinsinden (Örn: 30, 45)
  final Map<String, bool> dayStatus; // Her günün açık/kapalı durumu (Örn: {"1": true, "7": false})

  WorkingHours({
    required this.id,
    required this.barberId,
    required this.openTime,
    required this.closeTime,
    required this.slotDurationMinutes,
    required this.dayStatus,
  });

  factory WorkingHours.fromMap(String id, Map<String, dynamic> map) {
    return WorkingHours(
      id: id,
      barberId: map['barberId'] ?? '',
      openTime: map['openTime'] ?? '09:00',
      closeTime: map['closeTime'] ?? '20:00',
      slotDurationMinutes: map['slotDurationMinutes'] ?? 30,
      dayStatus: Map<String, bool>.from(map['dayStatus'] ?? {
        '1': true,  // Pazartesi
        '2': true,  // Salı
        '3': true,  // Çarşamba
        '4': true,  // Perşembe
        '5': true,  // Cuma
        '6': true,  // Cumartesi
        '7': false, // Pazar
      }),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barberId': barberId, // Veritabanında berber ile eşleşme sağlamak için kayda ekliyoruz
      'openTime': openTime,
      'closeTime': closeTime,
      'slotDurationMinutes': slotDurationMinutes,
      'dayStatus': dayStatus,
    };
  }
}

// YORUM MODELİ
class ReviewModel {
  final String id;
  final String barberId;     // Kime yorum yapıldı?
  final String customerId;   // Yorumu kim yaptı?
  final String customerName; // Hızlı listeleme için müşterinin adı
  final double rating;       // Verdiği puan (1-5 arası)
  final String comment;      // Yorum metni
  final DateTime createdAt;  // Yorum tarihi

  ReviewModel({
    required this.id,
    required this.barberId,
    required this.customerId,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      barberId: map['barberId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? 'Anonim Müşteri',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barberId': barberId,
      'customerId': customerId,
      'customerName': customerName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
//MESAJ MODELİ
class MessageModel {
  final String id;
  final String senderId;   // Mesajı gönderenin UID'si
  final String receiverId; // Mesajı alanın UID'si
  final String content;    // Mesaj içeriği
  final DateTime timestamp;// Gönderilme zamanı (Sıralama için kritik)

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

//ADRES
// Tip güvenliği sağlamak için kullanıcı tiplerini tanımlıyoruz


class AddressModel {
  final String id;          // Firestore'daki adres dökümanının benzersiz ID'si
  final UserType userType;  // 🔥 Kullanıcı tipi: Müşteri mi, Berber mi?
  final String userId;      // 🔥 Adresin ait olduğu kullanıcının benzersiz ID'si (UID)
  final String fullAddress; // Sözel açık adres (Örn: "Gül Sokak No:12 Daire:4")
  final String district;    // İlçe (Örn: "Urla")
  final String city;        // İl (Örn: "İzmir")
  final double latitude;    // Google Maps için koordinat: Enlem (Örn: 38.3189)
  final double longitude;   // Google Maps için koordinat: Boylam (Örn: 26.6384)

  AddressModel({
    required this.id,
    required this.userType,
    required this.userId,
    required this.fullAddress,
    required this.district,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  // Firestore'dan gelen veriyi Dart nesnesine dönüştüren fabrika yapıcı metot
  factory AddressModel.fromMap(String id, Map<String, dynamic> map) {
    return AddressModel(
      id: id,
      userId: map['userId'] ?? '',
      fullAddress: map['fullAddress'] ?? '',
      district: map['district'] ?? '',
      city: map['city'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      
      // Veritabanındaki String veriyi güvenli bir şekilde Enum tipine geri döndürüyoruz
      userType: UserType.values.firstWhere(
        (e) => e.name == map['userType'],
        orElse: () => UserType.customer, // Eşleşme bulunamazsa varsayılan olarak müşteri kabul et
      ),
    );
  }

  // Dart nesnesini Firestore'a kaydetmek için haritaya (Map) dönüştüren metot
  Map<String, dynamic> toMap() {
    return {
      'userType': userType.name, // Enum değerini veritabanına String olarak ("barber" veya "customer") yazar
      'userId': userId,
      'fullAddress': fullAddress,
      'district': district,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

//RESİMLER SINIFI
// Tip güvenliği (Type Safety) için enum yapılarını tanımlıyoruz

class ImageModel {
  final String id;              // Firestore'daki dökümanın kendi benzersiz ID'si
  final UserType userType;      // 🔥 Kullanıcı tipi: Müşteri mi, Berber mi?
  final String userId;          // Resmin ait olduğu kullanıcının (Auth) UID'si
  final ImageType imageType;    // 🔥 Görüntü tipi: Profil resmi mi, Galeri resmi mi?
  final String? description;    // Açıklama (Default olarak null)
  final String imageUrl;        // Firebase Storage'dan gelen resim internet adresi (URL)

  ImageModel({
    required this.id,
    required this.userType,
    required this.userId,
    required this.imageType,
    this.description,           // Constructor seviyesinde de zorunlu değil (null olabilir)
    required this.imageUrl,
  });

  // Firestore'dan veriyi Dart nesnesine dönüştüren fabrika metot
  factory ImageModel.fromMap(String id, Map<String, dynamic> map) {
    return ImageModel(
      id: id,
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'], // Eğer veritabanında yoksa otomatik null gelir
      
      // String olarak kaydedilen veriyi Enum tipine geri dönüştürüyoruz
      userType: UserType.values.firstWhere(
        (e) => e.name == map['userType'],
        orElse: () => UserType.customer, // Hata durumunda varsayılan
      ),
      imageType: ImageType.values.firstWhere(
        (e) => e.name == map['imageType'],
        orElse: () => ImageType.gallery, // Hata durumunda varsayılan
      ),
    );
  }

  // Dart nesnesini Firestore'a kaydetmek için Map yapısına dönüştüren metot
  Map<String, dynamic> toMap() {
    return {
      'userType': userType.name,   // Enum değerini String olarak ("customer" veya "barber") kaydeder
      'userId': userId,
      'imageType': imageType.name, // Enum değerini String olarak ("profile" oder "gallery") kaydeder
      'description': description,  // null ise veritabanına null olarak yazılır
      'imageUrl': imageUrl,
    };
  }
}
