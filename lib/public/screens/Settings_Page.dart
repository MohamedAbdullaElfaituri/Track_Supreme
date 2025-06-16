import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';

import '../drawer/Drawer_Widget.dart';
import '../drawer/custom_app_bar.dart';
import '../models/user_profile.dart';

class SettingsPage extends StatefulWidget {
  final String uid;
  const SettingsPage({Key? key, required this.uid}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController emailController;
  late final TextEditingController nameController;
  late final TextEditingController surnameController;
  late final TextEditingController phoneNumberController;
  late final TextEditingController addressController;
  late final TextEditingController cityController;
  late final TextEditingController countryController;
  late final TextEditingController dogumTarihiController;
  late final TextEditingController dogumYeriController;
  late final TextEditingController yasadigiIlController;

  bool isLoading = false;
  UserProfile? currentProfile;
  Database? _database;
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadProfileData();
  }

  void _initializeControllers() {
    emailController = TextEditingController();
    nameController = TextEditingController();
    surnameController = TextEditingController();
    phoneNumberController = TextEditingController();
    addressController = TextEditingController();
    cityController = TextEditingController();
    countryController = TextEditingController();
    dogumTarihiController = TextEditingController();
    dogumYeriController = TextEditingController();
    yasadigiIlController = TextEditingController();
  }

  Future<void> _loadProfileData() async {
    setState(() => isLoading = true);

    try {
      await _initializeDatabase();

      // Try getting profile from SQLite first
      currentProfile = await _getProfileFromSQLite();

      // If not found in SQLite, try other sources
      if (currentProfile == null) {
        final profiles = await Future.wait([
          _getProfileFromSharedPrefs(),
          _getProfileFromSupabase(),
          _getProfileFromFirestore(),
        ]);

        currentProfile = profiles.firstWhere(
              (profile) => profile != null,
          orElse: () => null,
        );

        // If found from other sources, save to SQLite
        if (currentProfile != null) {
          await _saveProfileToSQLite(currentProfile!);
        }
      }

      // Update controllers if profile exists
      if (currentProfile != null) {
        _updateControllers(currentProfile!);
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading profile: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {

        /*ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil yüklenirken hata oluştu: ${e.toString()}')),);*/
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _initializeDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(documentsDir.path, 'app_data.db');

    _database = await openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE profiles(
            uid TEXT PRIMARY KEY,
            email TEXT,
            name TEXT,
            surname TEXT,
            phoneNumber TEXT,
            address TEXT,
            city TEXT,
            country TEXT,
            dogumTarihi TEXT,
            dogumYeri TEXT,
            yasadigiIl TEXT,
            profilePictureUrl TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE profiles ADD COLUMN country TEXT');
        }
      },
    );
  }

  Future<UserProfile?> _getProfileFromSQLite() async {
    try {
      if (_database == null) return null;

      final result = await _database!.query(
        'profiles',
        where: 'uid = ?',
        whereArgs: [widget.uid],
        limit: 1,
      );

      return result.isEmpty ? null : UserProfile.fromMap(result.first);
    } catch (e) {
      debugPrint('SQLite read error: $e');
      return null;
    }
  }

  Future<void> _saveProfileToSQLite(UserProfile profile) async {
    try {
      if (_database == null) return;

      await _database!.insert(
        'profiles',
        profile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('SQLite save error: $e');
      rethrow;
    }
  }

  Future<UserProfile?> _getProfileFromSharedPrefs() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final email = sp.getString('email');
      if (email == null) return null;

      return UserProfile(
        uid: widget.uid,
        email: email,
        name: sp.getString('name') ?? '',
        surname: sp.getString('surname') ?? '',
        phoneNumber: sp.getString('phoneNumber') ?? '',
        address: sp.getString('address') ?? '',
        city: sp.getString('city') ?? '',
        country: sp.getString('country') ?? '',
        dogumTarihi: sp.getString('dogumTarihi') ?? '',
        dogumYeri: sp.getString('dogumYeri') ?? '',
        yasadigiIl: sp.getString('yasadigiIl') ?? '',
        profilePictureUrl: sp.getString('profilePictureUrl') ?? '',
      );
    } catch (e) {
      debugPrint('SharedPrefs read error: $e');
      return null;
    }
  }

  Future<void> _saveProfileToSharedPrefs(UserProfile profile) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('email', profile.email);
      await sp.setString('name', profile.name);
      await sp.setString('surname', profile.surname);
      await sp.setString('phoneNumber', profile.phoneNumber);
      await sp.setString('address', profile.address);
      await sp.setString('city', profile.city);
      await sp.setString('country', profile.country);
      await sp.setString('dogumTarihi', profile.dogumTarihi);
      await sp.setString('dogumYeri', profile.dogumYeri);
      await sp.setString('yasadigiIl', profile.yasadigiIl);
      await sp.setString('profilePictureUrl', profile.profilePictureUrl);
    } catch (e) {
      debugPrint('SharedPrefs save error: $e');
      rethrow;
    }
  }

  Future<UserProfile?> _getProfileFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.uid)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return UserProfile.fromMap(data);
    } catch (e) {
      debugPrint('Firestore read error: $e');
      return null;
    }
  }

  Future<void> _saveProfileToFirestore(UserProfile profile) async {
    try {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profile.uid)
          .set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore save error: $e');
      rethrow;
    }
  }

  Future<UserProfile?> _getProfileFromSupabase() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('uid', widget.uid)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      debugPrint('Supabase read error: $e');
      return null;
    }
  }

  Future<void> _saveProfileToSupabase(UserProfile profile) async {
    try {
      final response = await _supabase
          .from('profiles')
          .upsert(profile.toMap());

      if (response.error != null) {
        throw Exception('Supabase error: ${response.error!.message}');
      }
    } catch (e) {
      debugPrint('Supabase save error: $e');
      rethrow;
    }
  }

  void _updateControllers(UserProfile profile) {
    emailController.text = profile.email;
    nameController.text = profile.name;
    surnameController.text = profile.surname;
    phoneNumberController.text = profile.phoneNumber;
    addressController.text = profile.address;
    cityController.text = profile.city;
    countryController.text = profile.country;
    dogumTarihiController.text = profile.dogumTarihi;
    dogumYeriController.text = profile.dogumYeri;
    yasadigiIlController.text = profile.yasadigiIl;
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery);

    // Kullanıcı isterse resim seçebilir ama biz onu kullanmayacağız
    if (pickedFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resim seçildi .')),
      );
    }

    setState(() => isLoading = true);

    try {
      // Varsayılan resmi kullan
      const String defaultImageUrl = 'assets/images/default_profile.png';

      // Profil nesnesini güncelle
      final updatedProfile = (currentProfile ?? UserProfile(
        uid: widget.uid,
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        surname: surnameController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        country: countryController.text.trim(),
        dogumTarihi: dogumTarihiController.text.trim(),
        dogumYeri: dogumYeriController.text.trim(),
        yasadigiIl: yasadigiIlController.text.trim(),
        profilePictureUrl: '',
      )).copyWith(profilePictureUrl: defaultImageUrl);

      // Profili kaydet
      await _saveProfile(updatedProfile);

      setState(() => currentProfile = updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Varsayılan profil resmi atandı')),
        );
      }
    } catch (e) {
      debugPrint('Profil resmi hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _saveProfile([UserProfile? profile]) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final profileToSave = profile ?? UserProfile(
        uid: widget.uid,
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        surname: surnameController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        country: countryController.text.trim(),
        dogumTarihi: dogumTarihiController.text.trim(),
        dogumYeri: dogumYeriController.text.trim(),
        yasadigiIl: yasadigiIlController.text.trim(),
        profilePictureUrl: currentProfile?.profilePictureUrl ?? '',
      );

      // Save to all data sources
      await Future.wait([
        _saveProfileToSharedPrefs(profileToSave),
        _saveProfileToSQLite(profileToSave),
        _saveProfileToFirestore(profileToSave),
        _saveProfileToSupabase(profileToSave),
      ]);

      setState(() => currentProfile = profileToSave);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla kaydedildi')),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Save profile error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla kaydedildi')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Doğum Tarihinizi Seçiniz',
    );

    if (pickedDate != null) {
      dogumTarihiController.text =
      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return '$label boş bırakılamaz';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    surnameController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    cityController.dispose();
    countryController.dispose();
    dogumTarihiController.dispose();
    dogumYeriController.dispose();
    yasadigiIlController.dispose();
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(uid: widget.uid),
      appBar: CustomAppBar(title: 'Settings', showMenuButton: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: currentProfile?.profilePictureUrl
                          .isNotEmpty ==
                          true
                          ? NetworkImage(currentProfile!.profilePictureUrl)
                          : const AssetImage(
                          'assets/images/default_profile.png')
                      as ImageProvider,
                    ),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme
                              .of(context)
                              .primaryColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(Icons.camera_alt, size: 30),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildFormField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email cannot be empty';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              _buildFormField(
                controller: nameController,
                label: 'First Name',
                icon: Icons.person,
              ),

              _buildFormField(
                controller: surnameController,
                label: 'Last Name',
                icon: Icons.person_outline,
              ),

              _buildFormField(
                controller: phoneNumberController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                icon: Icons.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number cannot be empty';
                  }
                  if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),

              _buildFormField(
                controller: addressController,
                label: 'Address',
                icon: Icons.home,
              ),

              _buildFormField(
                controller: cityController,
                label: 'City',
                icon: Icons.location_city,
              ),

              _buildFormField(
                controller: countryController,
                label: 'Country',
                icon: Icons.public,
              ),

              _buildFormField(
                controller: dogumTarihiController,
                label: 'Date of Birth',
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: _selectDate,
              ),

              _buildFormField(
                controller: dogumYeriController,
                label: 'Place of Birth',
                icon: Icons.place,
              ),

              _buildFormField(
                controller: yasadigiIlController,
                label: 'City of Residence',
                icon: Icons.location_pin,
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                      color: Colors.white)
                      : const Text('Save', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}