import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  // Anahtar tanımlamaları
  static const String _keyUid = 'uid';          // Kullanıcı ID anahtarı
  static const String _keyEmail = 'email';      // Email anahtarı
  static const String _keyName = 'name';        // Ad anahtarı
  static const String _keySurname = 'surname';  // Soyad anahtarı
  static const String _keyPhoneNumber = 'phone_number'; // Telefon anahtarı

  // Kullanıcı profil bilgilerini kaydetme
  Future<void> saveUserProfileBasic({
    required String uid,
    required String email,
    required String name,
    required String surname,
    required String phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_keyUid, uid),
      prefs.setString(_keyEmail, email),
      prefs.setString(_keyName, name),
      prefs.setString(_keySurname, surname),
      prefs.setString(_keyPhoneNumber, phoneNumber),
    ]);
  }

  // Kayıtlı kullanıcı bilgilerini getirme
  Future<Map<String, String?>> getUserProfileBasic() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'uid': prefs.getString(_keyUid),
      'email': prefs.getString(_keyEmail),
      'name': prefs.getString(_keyName),
      'surname': prefs.getString(_keySurname),
      'phoneNumber': prefs.getString(_keyPhoneNumber),
    };
  }

  // Kullanıcı bilgilerini temizleme (çıkış yaparken)
  Future<void> clearUserProfileBasic() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keyUid),
      prefs.remove(_keyEmail),
      prefs.remove(_keyName),
      prefs.remove(_keySurname),
      prefs.remove(_keyPhoneNumber),
    ]);
  }
}