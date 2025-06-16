import 'package:flutter/material.dart';

import '../drawer/Drawer_Widget.dart';
import '../drawer/custom_app_bar.dart';
import 'TrackCargoPage.dart';


// NOT: Kargo takip numaraları bu linkten ulaşabilirsiniz:
// https://github.com/MohamedAbdullaElfaituri/midterm-logo/blob/main/turkish_shipments_1000.json


class HomeScreen extends StatefulWidget {
  final String uid;
  const HomeScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _trackingController = TextEditingController();

  final String logoUrl =
      'https://th.bing.com/th/id/OIG4.BufYBCXqMj8_JT6_lzh7?w=1792&h=1024&rs=1&pid=ImgDetMain';

  // Takip sayfasına gitme fonksiyonu
  void _goToTrackPage() {
    final trackingNumber = _trackingController.text.trim();

    if (trackingNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter tracking number')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackCargoPage(trackingNumber: trackingNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Home Page',
        showMenuButton: true,
      ),
      drawer: DrawerWidget(uid: widget.uid),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildLogoBox(),
              const SizedBox(height: 48),
              Text(
                'Enter your tracking number',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  letterSpacing: 1.1,
                  fontSize: 24, // İstersen burada da yazı büyüklüğünü belirtebilirsin
                ),
              ),
              const SizedBox(height: 24),
              _buildTrackingInput(),
              const SizedBox(height: 48),
              _buildTrackButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Logo kutusunu oluşturan widget
  Widget _buildLogoBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.4),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          logoUrl,
          height: 120,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.local_shipping, size: 80, color: Colors.blue),
        ),
      ),
    );
  }

  // Takip numarası giriş alanı widget'ı
  Widget _buildTrackingInput() {
    return TextField(
      controller: _trackingController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Example: TR587626899489',
        prefixIcon: const Icon(Icons.local_shipping_outlined, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
      ),
      style: const TextStyle(fontSize: 18),
      cursorColor: Colors.blue.shade700,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _goToTrackPage(),
    );
  }

  // Takip butonunu oluşturan widget
  Widget _buildTrackButton() {
    return ElevatedButton(
      onPressed: _goToTrackPage,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: Colors.blueAccent,
      ),
      child: const Text(
        'Track',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.white,
        ),
      ),
    );
  }
}
