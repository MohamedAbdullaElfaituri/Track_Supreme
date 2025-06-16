import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class CargoOrder {
  final String trackingNumber;
  final String courier;
  final String status;
  final String customerName;
  final String address;
  final String city;
  final String country;
  final String phone;
  final String orderDate;
  final String deliveryDate;
  final List<String> items;
  final List<String> options;

  CargoOrder({
    required this.trackingNumber,
    required this.courier,
    required this.status,
    required this.customerName,
    required this.address,
    required this.city,
    required this.country,
    required this.phone,
    required this.orderDate,
    required this.deliveryDate,
    required this.items,
    required this.options,
  });

  factory CargoOrder.fromJson(Map<String, dynamic> json) {
    return CargoOrder(
      trackingNumber: json['tracking_number'] ?? '',
      courier: json['courier'] ?? '',
      status: json['status'] ?? '',
      customerName: json['customer_name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      phone: json['phone'] ?? '',
      orderDate: json['order_date'] ?? '',
      deliveryDate: json['delivery_date'] ?? '',
      items: List<String>.from(json['items'] ?? []),
      options: List<String>.from(json['options'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tracking_number': trackingNumber,
      'courier': courier,
      'status': status,
      'customer_name': customerName,
      'address': address,
      'city': city,
      'country': country,
      'phone': phone,
      'order_date': orderDate,
      'delivery_date': deliveryDate,
      'items': items,
      'options': options,
    };
  }
}

class CargoService {
  static const String _url =
      'https://raw.githubusercontent.com/MohamedAbdullaElfaituri/midterm-logo/refs/heads/main/turkish_shipments_1000.json';

  static final SupabaseClient _supabase = Supabase.instance.client;

  // Tüm siparişleri çek
  static Future<List<CargoOrder>> fetchAllOrders() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => CargoOrder.fromJson(json)).toList();
    } else {
      throw Exception(
          'Siparişler yüklenemedi, status code: ${response.statusCode}');
    }
  }

  // Takip numarasına göre sipariş getir
  static Future<CargoOrder?> fetchOrderByTrackingNumber(
      String trackingNumber) async {
    List<CargoOrder> orders = await fetchAllOrders();
    try {
      return orders.firstWhere(
            (order) =>
        order.trackingNumber.toLowerCase() ==
            trackingNumber.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Supabase'e sipariş ekle
  static Future<void> insertOrderToSupabase(CargoOrder order) async {
    try {
      await _supabase.from('kargo_takip_loglari').insert([order.toMap()]);
    } catch (e) {
      throw Exception('Supabase insert error: $e');
    }
  }

  // Takip numarasına göre API'den çek, sonra Supabase'e ekle
  static Future<CargoOrder?> fetchAndSaveOrder(String trackingNumber) async {
    final order = await fetchOrderByTrackingNumber(trackingNumber);
    if (order == null) return null;

    await insertOrderToSupabase(order);
    return order;
  }
}
