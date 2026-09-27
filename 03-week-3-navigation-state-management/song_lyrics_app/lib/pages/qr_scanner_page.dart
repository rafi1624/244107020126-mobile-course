import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:geolocator/geolocator.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
        );
        await _controller!.initialize();
        if (!mounted) return;
        setState(() {
          _isReady = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Service lokasi (GPS) sedang mati.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin akses lokasi ditolak.';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Izin akses lokasi ditolak permanen.';
      } 

      Position position = await Geolocator.getCurrentPosition();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lokasi Anda: ${position.latitude}, ${position.longitude}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: Center(
        child: _isReady && _controller != null
            ? Stack(
                children: [
                  CameraPreview(_controller!),
                  QRScannerOverlay(overlayColor: Colors.black.withOpacity(0.5)),
                  const Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Text(
                      'Arahkan kamera ke QR Code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getLocation,
        child: const Icon(Icons.location_on),
      ),
    );
  }
}
