import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer';
import 'package:latlong2/latlong.dart'; // สำหรับ LatLng

class GPSandMapPage extends StatefulWidget {
  const GPSandMapPage({super.key});

  @override
  State<GPSandMapPage> createState() => _GPSandMapPageState();
}

class _GPSandMapPageState extends State<GPSandMapPage> {
  LatLng latLng = const LatLng(16.246825669508297, 103.25199289277295);
  MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS and Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(latLng); // ส่งพิกัดกลับ
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // FilledButton(
          //   onPressed: () async {
          //     Position position = await _determinePosition();
          //     latLng = LatLng(position.latitude, position.longitude);
          //     mapController.move(latLng, mapController.camera.zoom);
          //     setState(() {});
          //   },
          //   // child: const Text('Get Current Location'),
          // ),
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: latLng, // ใช้ center แทน initialCenter
                initialZoom: 15.0,    // ใช้ zoom ตามที่ระบุ
                onTap: (tapPosition, point) {
                  setState(() {
                    latLng = point; // อัพเดตตำแหน่งเมื่อคลิกที่แผนที่
                  });
                },
              ),
             children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                  maxNativeZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latLng, // ตำแหน่งของ Marker
                      width: 40, // ความกว้างของ Marker
                      height: 40, // ความสูงของ Marker
                      child: const Icon (
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ), 
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(latLng); // ส่งพิกัดกลับเมื่อกดปุ่มยืนยัน
              },
              child: const Text('ยืนยันการเลือกพิกัด'),
            ),
          ),
        ],
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
