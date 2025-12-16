import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../login_page.dart';

class AdminDashboard extends StatefulWidget {
  final String nom;
  final String prenom;
  final String token;

  const AdminDashboard({
    super.key,
    required this.nom,
    required this.prenom,
    required this.token,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    // Note: In a real app, you would pass the JWT token here
    // For this demo, we assume the backend handles it or we'll add it to AuthService headers
    // Using a direct call to test (replace with AuthService method in production)
    final service = AuthService();
    try {
      final response = await http.get(
        Uri.parse('${service.baseUrl.replaceAll("/auth", "/admin")}/stats'),
        headers: {
            'Authorization': 'Bearer ${widget.token}',
        }
      );

      if (response.statusCode == 200) {
        setState(() {
          _stats = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur chargement stats';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }

  }

  Future<void> _showMyQrCode() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
        // Create auth service instance since it's not a member variable in this file
      final service = AuthService();
      final profile = await service.getUserProfile(widget.token);
      final qrToken = profile['qrToken'];

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Mon QR Code', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                   width: 200,
                   height: 200,
                   child: QrImageView(
                    data: qrToken ?? 'Erreur: Pas de token',
                    version: QrVersions.auto,
                   ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Scannez ce code pour vous connecter',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer', style: TextStyle(color: Color(0xFF23B8C0))),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur QR: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark theme
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Panneau Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Bonjour, ${widget.prenom} ${widget.nom}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code, color: Colors.white),
                    tooltip: 'Mon QR Code',
                    onPressed: () => _showMyQrCode(),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Stats Cards
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red))
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Étudiants',
                        _stats?['studentCount']?.toString() ?? '0',
                        Icons.school,
                        const Color(0xFF23B8C0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Professeurs',
                        _stats?['professorCount']?.toString() ?? '0',
                        Icons.person_outline,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
