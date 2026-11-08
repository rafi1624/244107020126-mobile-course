import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _apiUrlController;
  bool _obscurePassword = true;
  bool _showUrlConfig = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'test@example.com');
    _passwordController = TextEditingController(text: 'password');
    final initialUrl = ref.read(authRepositoryProvider).baseUrl;
    _apiUrlController = TextEditingController(text: initialUrl);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _apiUrlController.dispose();
    super.dispose();
  }

  void _fillCredentials(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Simpan kustomisasi API URL jika diubah
    ref.read(authRepositoryProvider).baseUrl = _apiUrlController.text;

    FocusScope.of(context).unfocus();
    try {
      await ref.read(authStateProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil! Selamat datang.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _showUrlConfig = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Login API & Keamanan Token'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            tooltip: 'Konfigurasi Endpoint API',
            icon: Icon(
              _showUrlConfig ? Icons.settings : Icons.settings_outlined,
              color: Colors.indigo.shade800,
            ),
            onPressed: () {
              setState(() {
                _showUrlConfig = !_showUrlConfig;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Icon & Title
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_person_rounded,
                            size: 48,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Autentikasi API Kampus',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade900,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Clean Architecture: Presentation Layer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Panel Konfigurasi URL API jika diaktifkan
                      if (_showUrlConfig) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.link, size: 18, color: Colors.amber),
                                  SizedBox(width: 8),
                                  Text(
                                    'Endpoint API Server',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _apiUrlController,
                                style: const TextStyle(fontSize: 13),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                  hintText: 'http://10.0.2.2:8000/api',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• Emulator Android: http://10.0.2.2:8000/api\n'
                                '• HP Fisik (USB): http://127.0.0.1:8000/api\n'
                                '• HP Fisik (Wi-Fi): http://192.168.100.206:8000/api',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  ActionChip(
                                    avatar: const Icon(Icons.usb, size: 14),
                                    label: const Text('HP Fisik (USB)', style: TextStyle(fontSize: 11)),
                                    onPressed: () {
                                      _apiUrlController.text = 'http://127.0.0.1:8000/api';
                                    },
                                  ),
                                  ActionChip(
                                    avatar: const Icon(Icons.wifi, size: 14),
                                    label: const Text('Wi-Fi', style: TextStyle(fontSize: 11)),
                                    onPressed: () {
                                      _apiUrlController.text = 'http://192.168.100.206:8000/api';
                                    },
                                  ),
                                  ActionChip(
                                    avatar: const Icon(Icons.phone_android, size: 14),
                                    label: const Text('Emulator', style: TextStyle(fontSize: 11)),
                                    onPressed: () {
                                      _apiUrlController.text = 'http://10.0.2.2:8000/api';
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Input Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Akun',
                          hintText: 'nama@example.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!value.contains('@')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          hintText: 'Minimal 6 karakter',
                          prefixIcon: const Icon(Icons.vpn_key_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Kata sandi minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Quick Fill Demo Accounts
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Demo:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          ActionChip(
                            label: const Text('test@example.com', style: TextStyle(fontSize: 11)),
                            onPressed: () => _fillCredentials('test@example.com', 'password'),
                          ),
                          ActionChip(
                            label: const Text('admin@kampus.id', style: TextStyle(fontSize: 11)),
                            onPressed: () => _fillCredentials('admin@kampus.id', 'password123'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tombol Login
                      ElevatedButton(
                        onPressed: isLoading ? null : _submitLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login_rounded),
                                  SizedBox(width: 8),
                                  Text(
                                    'Masuk ke Sistem API',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

