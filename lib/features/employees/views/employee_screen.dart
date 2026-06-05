import 'package:provider/provider.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared_widgets/custom_sidebar.dart';


class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  String _searchQuery = "";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  String? _selectedDept;

  Future<void> _simpan(
      DashboardController controller,
      ) async {
    if (_nameController.text.isNotEmpty &&
        _nikController.text.isNotEmpty &&
        _selectedDept != null) {

      await controller.addEmployee(
        _nameController.text,
        _nikController.text,
        _selectedDept!,
      );

      _nameController.clear();
      _nikController.clear();

      setState(() {
        _selectedDept = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Karyawan Berhasil Ditambahkan",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Semua kolom harus diisi!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;
    final controller = Provider.of<DashboardController>(context);
    
    final filteredEmployees = controller.employees.where((e) {
      final text = _searchQuery.toLowerCase();
      return e['name']!.toLowerCase().contains(text) || e['nik']!.toLowerCase().contains(text);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile ? AppBar(backgroundColor: AppColors.primary, title: const Text("Smart Attendance", style: TextStyle(color: Colors.white))) : null,
      drawer: isMobile ? const CustomSidebar(currentIndex: 2) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) const CustomSidebar(currentIndex: 2),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Manajemen Karyawan", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  const Text("Kelola data personil dan unit kerja organisasi.", style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 32),
                  
                  // Form Tambah Karyawan Baru
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.person_add_alt_1, color: AppColors.secondary),
                            SizedBox(width: 12),
                            Text("Tambah Karyawan Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildInputField("Nama Lengkap", "Masukkan nama lengkap", _nameController),
                        const SizedBox(height: 16),
                        _buildInputField("NIK (Nomor Induk Karyawan)", "16 digit angka", _nikController),
                        const SizedBox(height: 16),
                        const Text("Departemen", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDept,
                              isExpanded: true,
                              hint: const Text("Pilih Unit", style: TextStyle(color: AppColors.textSecondary)),
                              items: ["Engineering", "HRD", "Marketing", "Operations", "IT"].map((String value) {
                                return DropdownMenuItem<String>(value: value, child: Text(value));
                              }).toList(),
                              onChanged: (val) {
                                setState(() { _selectedDept = val; });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D7A64), // Darker green from mockup
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                            ),
                            icon: const Icon(Icons.save, color: Colors.white, size: 20),
                            label: const Text("Simpan Karyawan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                            onPressed: () async {
                              await _simpan(controller);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Search & Filter
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFE5F1FC), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            onChanged: (val) {
                              setState(() { _searchQuery = val; });
                            },
                            decoration: const InputDecoration(
                              hintText: "Cari nama atau NIK...",
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          icon: const Icon(Icons.filter_list, color: AppColors.textSecondary, size: 18),
                          label: const Text("Filter", style: TextStyle(color: AppColors.textPrimary)),
                          onPressed: () {},
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Karyawan Terdaftar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Karyawan Terdaftar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.blue.shade900, borderRadius: BorderRadius.circular(20)),
                        child: Text("Total: ${controller.employees.length}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // List Employee
                  filteredEmployees.isEmpty 
                    ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text("Karyawan tidak ditemukan.")))
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredEmployees.length,
                      itemBuilder: (context, index) {
                        final emp = filteredEmployees[index];
                        return _buildEmployeeCard(emp["id"]!, emp["name"]!, emp["nik"]!, emp["dept"]!, emp["initials"]!, controller);
                      },
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController fieldController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 8),
        TextField(
          controller: fieldController,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.border),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(String id, String name, String nik, String dept, String initials, DashboardController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Text(initials, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text("NIK: $nik • $dept", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 20), onPressed: () {}),
              IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20), onPressed: () {
                controller.deleteEmployee(id);
              }),
            ],
          )
        ],
      ),
    );
  }
}
