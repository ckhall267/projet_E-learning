import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/auth_service.dart';
import 'student/student_dashboard.dart';
import 'professor/professor_dashboard.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _authService = AuthService();
  bool _isProcessing = false;

  void _handleQrCode(String? code) async {
    if (code == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await _authService.loginWithQr(code);
      if (!mounted) return;

      final role = response['role'];
      final nom = response['nom'];
      final prenom = response['prenom'];
      final token = response['jwt'];

      if (role == 'Etudiant') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  StudentDashboard(nom: nom, prenom: prenom, token: token)),
        );
      } else if (role == 'Professeur') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  ProfessorDashboard(nom: nom, prenom: prenom, token: token)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rôle inconnu')),
        );
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner le Badge')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            _handleQrCode(barcode.rawValue);
          }
        },
      ),
    );
  }
}
