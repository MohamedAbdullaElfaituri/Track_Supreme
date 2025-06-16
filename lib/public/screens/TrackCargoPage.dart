import 'package:flutter/material.dart';
import '../drawer/custom_app_bar.dart';
import '../services/cargo_service.dart';

class TrackCargoPage extends StatefulWidget {
  final String trackingNumber;

  const TrackCargoPage({Key? key, required this.trackingNumber}) : super(key: key);

  @override
  State<TrackCargoPage> createState() => _TrackCargoPageState();
}

class _TrackCargoPageState extends State<TrackCargoPage> {
  CargoOrder? _order;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAndSaveOrder();
  }

  // Kargo sipariş bilgilerini API'den al ve kaydet
  Future<void> _fetchAndSaveOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _order = null;
    });

    try {
      final order = await CargoService.fetchAndSaveOrder(widget.trackingNumber);
      setState(() {
        _order = order;
        if (order == null) {
          _error = "Tracking number not found: ${widget.trackingNumber}";
        }
      });
    } catch (e) {
      setState(() {
        _error = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Bilgi satırı oluştur (label ve value)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kart bölümü oluştur (başlık ve öğeler listesi)
  Widget _buildCardSection(String title, List<String> items) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text("• $item",
                style: const TextStyle(fontSize: 15),
              ),
            )),
          ],
        ),
      ),
    );
  }

  // Sipariş detaylarını listele
  Widget _buildOrderDetails(CargoOrder order) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        Text(
          "Tracking Number: ${order.trackingNumber}",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow("Courier", order.courier),
        _buildInfoRow("Status", order.status),
        _buildInfoRow("Customer", order.customerName),
        _buildInfoRow("Address", "${order.address}, ${order.city}, ${order.country}"),
        _buildInfoRow("Phone", order.phone),
        _buildInfoRow("Order Date", order.orderDate),
        _buildInfoRow("Delivery Date", order.deliveryDate),
        _buildCardSection("Items", order.items),
        _buildCardSection("Options", order.options),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Tracking: ${widget.trackingNumber}', showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Text(
          _error!,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      )
          : _order != null
          ? _buildOrderDetails(_order!)
          : const Center(
        child: Text(
          "No data found.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
