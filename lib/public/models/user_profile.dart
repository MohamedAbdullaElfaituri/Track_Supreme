class UserProfile {
  final String uid;               // Kullanıcının benzersiz kimliği
  final String email;             // Kullanıcının e-posta adresi
  final String name;              // Kullanıcının adı
  final String surname;           // Kullanıcının soyadı
  final String phoneNumber;       // Telefon numarası
  final String address;           // Adres bilgisi
  final String country;           // Ülke
  final String city;              // Şehir
  final String dogumTarihi;       // Doğum tarihi
  final String dogumYeri;         // Doğum yeri
  final String yasadigiIl;        // Yaşadığı il
  final String profilePictureUrl; // Profil resmi URL'si

  // Constructor: zorunlu tüm alanlar
  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.surname,
    required this.phoneNumber,
    required this.address,
    required this.country,
    required this.city,
    required this.dogumTarihi,
    required this.dogumYeri,
    required this.yasadigiIl,
    required this.profilePictureUrl,
  });

  // Nesneyi Map'e dönüştürür, veritabanı veya API için uygun format
  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'name': name,
    'surname': surname,
    'phonenumber': phoneNumber,
    'address': address,
    'country': country,
    'city': city,
    'dogumtarihi': dogumTarihi,
    'dogumyeri': dogumYeri,
    'yasadigiil': yasadigiIl,
    'profilepictureurl': profilePictureUrl,
  };

  // Map'ten UserProfile nesnesi oluşturur, eksik alanlarda boş string kullanılır
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      dogumTarihi: map['dogumTarihi'] ?? '',
      dogumYeri: map['dogumYeri'] ?? '',
      yasadigiIl: map['yasadigiIl'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
    );
  }

  // Mevcut nesneyi baz alarak bazı alanları değiştirip yeni nesne oluşturur
  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? surname,
    String? phoneNumber,
    String? address,
    String? country,
    String? city,
    String? dogumTarihi,
    String? dogumYeri,
    String? yasadigiIl,
    String? profilePictureUrl,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      country: country ?? this.country,
      city: city ?? this.city,
      dogumTarihi: dogumTarihi ?? this.dogumTarihi,
      dogumYeri: dogumYeri ?? this.dogumYeri,
      yasadigiIl: yasadigiIl ?? this.yasadigiIl,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}
