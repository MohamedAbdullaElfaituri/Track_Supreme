// services/sqlite_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';

class SQLiteHelper {
  // Singleton deseni uygulanıyor (tek örnek)
  static final SQLiteHelper _instance = SQLiteHelper._internal();
  factory SQLiteHelper() => _instance;
  SQLiteHelper._internal(); // Özel kurucu metod

  Database? _db; // Veritabanı referansı

  // Veritabanı erişimci metodu
  Future<Database> get database async {
    if (_db != null) return _db!; // Zaten açıksa mevcut veritabanını döndür
    _db = await initDB(); // Yoksa yeni başlat
    return _db!;
  }

  // Veritabanı başlatma metodu
  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'userprofile.db'); // DB yolu
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async { // İlk oluşturmada tablo yapısı kuruluyor
        await db.execute('''
          CREATE TABLE profiles(
            uid TEXT PRIMARY KEY,            // Kullanıcı ID (birincil anahtar)
            email TEXT,                     // E-posta
            name TEXT,                      // Ad
            surname TEXT,                   // Soyad
            phone_number TEXT,              // Telefon
            address TEXT,                   // Adres
            country TEXT,                  // Ülke
            city TEXT,                      // Şehir
            profile_picture_url TEXT,       // Profil resmi URL
            dogum_tarihi TEXT,              // Doğum tarihi
            dogum_yeri TEXT,                // Doğum yeri
            yasadigi_il TEXT                // Yaşadığı il
          )
        ''');
      },
    );
  }

  // Profil ekleme/güncelleme metodu
  Future<int> insertOrUpdateProfile(UserProfile profile) async {
    final db = await database;
    return await db.insert(
      'profiles',
      profile.toMap(), // UserProfile -> Map dönüşümü
      conflictAlgorithm: ConflictAlgorithm.replace, // Çakışmada üzerine yaz
    );
  }

  // Profil getirme metodu
  Future<UserProfile?> getProfile(String uid) async {
    final db = await database;
    final maps = await db.query(
      'profiles',
      where: 'uid = ?',  // Sorgu koşulu
      whereArgs: [uid],  // Parametre
    );

    return maps.isNotEmpty
        ? UserProfile.fromMap(maps.first) // Map -> UserProfile dönüşümü
        : null; // Kayıt yoksa null
  }
}