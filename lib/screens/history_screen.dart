import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatelessWidget {
  final String employeeId;

  const HistoryScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Riwayat Absensi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B2F64))),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('smart_attendance_logs').where('nik', isEqualTo: employeeId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final logs = snapshot.data!.docs;
                if (logs.isEmpty) return const Center(child: Text('Belum ada riwayat absensi.', style: TextStyle(color: Colors.grey)));

                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final data = logs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: Colors.white,
                      child: ListTile(
                        leading: const Icon(Icons.check_circle, color: Color(0xFF006B5E)),
                        title: const Text('Presensi Lapangan Berhasil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: const Text('Status Log: Terunggah otomatis ke cloud hrd'),
                        trailing: const Text('HADIR', style: TextStyle(fontSize: 12, color: Color(0xFF006B5E), fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}