import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class ShowProSend extends StatefulWidget {
  final String userId;

  const ShowProSend({super.key, required this.userId});

  @override
  State<ShowProSend> createState() => _ShowProSendState();
}

class _ShowProSendState extends State<ShowProSend> {
  List<dynamic> _receivers = [];
  MapController mapController = MapController();
  LatLng defaultLocation = LatLng(16.246825669508297, 103.25199289277295); // ค่าเริ่มต้นสำหรับตำแหน่งแผนที่

  @override
  void initState() {
    super.initState();
    _fetchReceivers();
  }

  Future<void> _fetchReceivers() async {
    try {
      final response = await http.get(Uri.parse('https://appdeli.onrender.com/api/products/${widget.userId}/receivers'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _receivers = data['data'];
        });
      } else {
        throw Exception('Failed to load receivers');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS and Map'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _receivers.isNotEmpty
                ? FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: defaultLocation, // ใช้ตำแหน่งเริ่มต้น
                      initialZoom: 15.0,
                    ),
                     children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                        maxNativeZoom: 19,
                      ),
                      MarkerLayer(
                        markers: _receivers.map((receiver) {
                          final gps = receiver['gps']?.split(','); // แบ่งค่าพิกัด GPS
                          if (gps != null && gps.length == 2) {
                            final lat = double.parse(gps[0]);
                            final lng = double.parse(gps[1]);
                            return Marker(
                              point: LatLng(lat, lng),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            );
                          }
                          return null; // คืนค่า null ถ้าพิกัด GPS ไม่ถูกต้อง
                        }).where((marker) => marker != null).cast<Marker>().toList(),
                      ),
                    ],
                  )
                : Center(
                    child: Text('ไม่พบข้อมูลพิกัด GPS สำหรับผู้รับสินค้า'),
                  ),
          ),
        ],
      ),
    );
  }
}
