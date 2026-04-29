import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProviderVerificationScreen extends StatefulWidget {
  const ProviderVerificationScreen({super.key});

  @override
  State<ProviderVerificationScreen> createState() => _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState extends State<ProviderVerificationScreen> {
  final List<Map<String, dynamic>> _pendingProviders = [
    {
      'id': 'PRV-001',
      'name': 'Saman Kumara',
      'service': 'Plumber',
      'email': 'saman.kumara@email.com',
      'phone': '0771234567',
      'experience': '5',
      'role': 'Register as Provider',
    },
    {
      'id': 'PRV-002',
      'name': 'Nuwan Silva',
      'service': 'AC Technician',
      'email': 'nuwan.cool@email.com',
      'phone': '0719876543',
      'experience': '8',
      'role': 'Register as Customer & Provider',
    },
  ];

  void _processDecision(String id, String action) {
    setState(() => _pendingProviders.removeWhere((p) => p['id'] == id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Provider $action successfully.'),
        backgroundColor: action == 'Approved' ? Colors.green : Colors.redAccent,
      ),
    );
  }

  void _showApproveDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E355B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Approve Provider',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to approve $name?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF8EBBFF)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context);
              _processDecision(id, 'Approved');
            },
            child: const Text('Confirm',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDenyDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E355B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Deny Provider',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Deny $name?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF8EBBFF)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              _processDecision(id, 'Denied');
            },
            child: const Text('Confirm',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1E3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Provider Verification',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: const Color(0xFFB18E44))),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _pendingProviders.isEmpty
            ? const Center(
                child: Text('No providers waiting for verification.',
                    style: TextStyle(color: Colors.white70, fontSize: 18)))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _pendingProviders.length,
                itemBuilder: (context, index) {
                  final provider = _pendingProviders[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E355B),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFC0C0C2).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(provider['name'],
                                  style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              const SizedBox(height: 5),
                              Text('Service: ${provider['service']}',
                                  style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 5),
                              Text('Email: ${provider['email']}',
                                  style: const TextStyle(color: Color(0xFF8EBBFF), fontSize: 12)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                              child: IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                                onPressed: () => _showApproveDialog(provider['id'], provider['name']),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
                              child: IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 28),
                                onPressed: () => _showDenyDialog(provider['id'], provider['name']),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
