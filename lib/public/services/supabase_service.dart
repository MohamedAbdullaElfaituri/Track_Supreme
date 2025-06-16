import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

final supabase = Supabase.instance.client;

// Kullanıcı profilini Supabase'den getirir
Future<UserProfile?> getSupabaseProfile(String uid) async {
  final data = await supabase
      .from('user_profiles')
      .select()
      .eq('uid', uid)
      .single();

  return data == null ? null : UserProfile(
    uid: uid,
    name: data['name'] ?? '',
    surname: data['surname'] ?? '',
    phoneNumber: data['phone_number'] ?? '',
    address: data['address'] ?? '',
    country: data['country'] ?? '',
    city: data['city'] ?? '',
    profilePictureUrl: data['profile_picture_url'] ?? '',
    email: '', // Firebase'den alınacak
    dogumTarihi: '',
    dogumYeri: '',
    yasadigiIl: '',
  );
}

// Profili Supabase'e kaydeder veya günceller
Future<void> upsertSupabaseProfile(UserProfile profile) async {
  final response = await supabase.from('user_profiles').upsert({
    'uid': profile.uid,
    'name': profile.name,
    'surname': profile.surname,
    'phone_number': profile.phoneNumber,
    'address': profile.address,
    'country': profile.country,
    'city': profile.city,
    'profile_picture_url': profile.profilePictureUrl,
  });

  if (response.error != null) throw Exception('Supabase hatası: ${response.error!.message}');
}

// Firebase kullanıcısı için Supabase profilini oluşturur/günceller
Future<void> createOrUpdateSupabaseProfileFromFirebase(UserProfile profile) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("Kullanıcı oturum açmamış");

  await upsertSupabaseProfile(profile.copyWith(uid: user.uid));
}