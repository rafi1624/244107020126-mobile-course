import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profil Mahasiswa'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              Icon(Icons.school, size: 72, color: Colors.blue),
              SizedBox(height: 16),
              // Nama Mahasiswa
              Text(
                'Rafi Abyantara Pratama', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              // NIM Mahasiswa
              Text(
                'NIM: 23012345678', // Ganti dengan NIM asli Anda
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text('Pemrograman Mobile — Minggu 1'),
              SizedBox(height: 16),
              // Informasi Tambahan: Email menggunakan widget Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'rafi.abyantara@student.univ.edu', // Ganti dengan email Anda
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}