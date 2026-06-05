import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared_widgets/custom_sidebar.dart';
import '../../../../core/constants/app_colors.dart';

class AdminLeaveScreen extends StatelessWidget {
  const AdminLeaveScreen({Key? key}) : super(key: key);

  void _approveLeave(BuildContext context, String id, String employeeId) async {
    try {
      await FirebaseFirestore.instance.collection('leave_requests').doc(id).update({
        'status': 'approved',
      });
      // Deduct leave quota from employee
      await FirebaseFirestore.instance.collection('registered_employees').doc(employeeId).set({
        'leave_quota': FieldValue.increment(-1),
      }, SetOptions(merge: true));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cuti disetujui, sisa kuota terpotong.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  void _rejectLeave(BuildContext context, String id) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Cuti'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Alasan penolakan / Reject reason'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('leave_requests').doc(id).update({
                  'status': 'rejected',
                  'rejectReason': reasonController.text.trim(),
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cuti ditolak.')));
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
              }
            },
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Lampiran Surat / Dokumen', style: TextStyle(fontSize: 16)),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx))
              ],
            ),
            Image.network(imageUrl, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const CustomSidebar(currentIndex: 4), // Menu Leave & Approvals index = 4
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Leave & Approvals - Verifikasi Berkas Cuti",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('leave_requests')
                          .where('status', isEqualTo: 'pending')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("Tidak ada permintaan cuti pending saat ini."));
                        }

                        final requests = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final doc = requests[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final name = data['employeeName'] ?? 'Unknown';
                            final employeeId = data['employeeId'] ?? '';
                            final reason = data['reason'] ?? 'Tidak ada alasan';
                            final imageUrl = data['attachmentUrl'];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  child: Icon(Icons.file_present, color: Colors.white),
                                ),
                                title: Text("$name ($employeeId)", style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("Alasan: $reason"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (imageUrl != null && imageUrl.toString().isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.image, color: Colors.blue),
                                        tooltip: 'Lihat Lampiran',
                                        onPressed: () => _showImage(context, imageUrl),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.check_circle, color: AppColors.success),
                                      tooltip: 'Approve',
                                      onPressed: () => _approveLeave(context, doc.id, employeeId),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: AppColors.danger),
                                      tooltip: 'Reject',
                                      onPressed: () => _rejectLeave(context, doc.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
