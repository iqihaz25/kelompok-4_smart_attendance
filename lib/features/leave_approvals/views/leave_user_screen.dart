import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class LeaveUserScreen extends StatefulWidget {
  final String employeeId;
  final String employeeNama;

  const LeaveUserScreen({
    Key? key,
    required this.employeeId,
    required this.employeeNama,
  }) : super(key: key);

  @override
  State<LeaveUserScreen> createState() => _LeaveUserScreenState();
}

class _LeaveUserScreenState extends State<LeaveUserScreen> {
  final _reasonController = TextEditingController();
  File? _imageFile;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitLeave() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alasan cuti wajib diisi!')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? imageUrl;
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('leave_attachments')
            .child('${widget.employeeId}_${DateTime.now().millisecondsSinceEpoch}.jpg');
        
        final uploadTask = await storageRef.putFile(_imageFile!);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('leave_requests').add({
        'employeeId': widget.employeeId,
        'employeeName': widget.employeeNama,
        'reason': _reasonController.text.trim(),
        'attachmentUrl': imageUrl ?? '',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _reasonController.clear();
        _imageFile = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permintaan cuti berhasil diajukan!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengajukan cuti: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan & Riwayat Cuti / Izin', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF0B2F64),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Cuti Quota (Static 12 days for this demo - realistically from DB)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('registered_employees').doc(widget.employeeId).snapshots(),
              builder: (context, snapshot) {
                int quota = 12; // default
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  if (data.containsKey('leave_quota')) {
                    quota = data['leave_quota'];
                  }
                }
                return Card(
                  color: const Color(0xFFE2F1E8),
                  child: ListTile(
                    leading: const Icon(Icons.beach_access, color: Color(0xFF006B5E)),
                    title: const Text("Sisa Kuota Cuti Tahunan", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text("$quota Hari", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006B5E))),
                  ),
                );
              }
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Color(0xFF0B2F64),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Color(0xFF0B2F64),
                      tabs: [
                        Tab(text: "Ajukan Cuti/Sakit"),
                        Tab(text: "Riwayat"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tab 1: Form Pengajuan
                          SingleChildScrollView(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('Alasan Cuti / Sakit', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _reasonController,
                                  decoration: const InputDecoration(
                                    hintText: 'Tuliskan alasan lengkap (contoh: Sakit Demam, Cuti Tahunan, dll)',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 16),
                                const Text('Lampiran Bukti (Surat Sakit dari Dokter)', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pickImage,
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[100],
                                    ),
                                    child: _imageFile != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                                          )
                                        : const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.camera_alt, color: Colors.grey, size: 32),
                                              SizedBox(height: 8),
                                              Text('Upload Surat Dokter (Opsional)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                            ],
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _isSubmitting
                                    ? const Center(child: CircularProgressIndicator())
                                    : ElevatedButton(
                                        onPressed: _submitLeave,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF006B5E),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                        child: const Text('Kirim Pengajuan Berkasi Cuti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                              ],
                            ),
                          ),
                          // Tab 2: Riwayat Cuti
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('leave_requests')
                                .where('employeeId', isEqualTo: widget.employeeId)
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Center(child: Text('Belum ada riwayat cuti.'));
                              }
                              final docs = snapshot.data!.docs;
                              return ListView.builder(
                                padding: const EdgeInsets.only(top: 16),
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final data = docs[index].data() as Map<String, dynamic>;
                                  final status = data['status'] ?? 'pending';
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      title: Text(data['reason'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Status: ${status.toUpperCase()}'),
                                          if (status == 'rejected' && data['rejectReason'] != null)
                                            Text('Alasan: ${data['rejectReason']}', style: const TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                      trailing: Icon(
                                        status == 'pending' ? Icons.hourglass_empty : (status == 'approved' ? Icons.check_circle : Icons.cancel),
                                        color: status == 'pending' ? Colors.orange : (status == 'approved' ? Colors.green : Colors.red),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
