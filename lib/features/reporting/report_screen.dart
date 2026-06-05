import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared_widgets/custom_sidebar.dart';
import '../dashboard/controllers/dashboard_controller.dart';
import 'package:excel/excel.dart' hide Border;
import '../../../core/utils/export_helper.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime? _selectedDate;

  void _exportReport(BuildContext context, DashboardController controller) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengekspor Laporan...'), backgroundColor: AppColors.primary),
    );

    var excel = Excel.createExcel();
    
    // Header Style
    CellStyle headerStyle = CellStyle(
      bold: true,
      fontFamily: getFontFamily(FontFamily.Calibri),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#1E3A8A'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    // Sheet 1: Data Kehadiran
    var attendanceSheet = excel['Laporan Kehadiran'];
    excel.setDefaultSheet('Laporan Kehadiran');
    
    List<String> attendanceHeaders = ["ID", "Nama Karyawan", "Departemen", "Waktu (WIB)", "Status"];
    attendanceSheet.appendRow(attendanceHeaders.map((e) => TextCellValue(e)).toList());
    for (int i = 0; i < attendanceHeaders.length; i++) {
      attendanceSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerStyle;
      attendanceSheet.setColumnWidth(i, 20.0);
    }

    for (var log in controller.logs) {
      attendanceSheet.appendRow([
        TextCellValue(log.id),
        TextCellValue(log.employeeName),
        TextCellValue(log.department),
        TextCellValue(log.time),
        TextCellValue(log.status),
      ]);
    }

    // Sheet 2: Data Karyawan
    var employeeSheet = excel['Daftar Karyawan'];
    List<String> employeeHeaders = ["ID Karyawan", "Nama Lengkap", "NIK", "Departemen"];
    employeeSheet.appendRow(employeeHeaders.map((e) => TextCellValue(e)).toList());
    for (int i = 0; i < employeeHeaders.length; i++) {
      employeeSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerStyle;
      employeeSheet.setColumnWidth(i, 25.0); // Make it wider since names and NIK are long
    }

    for (var emp in controller.employees) {
      employeeSheet.appendRow([
        TextCellValue(emp["id"] ?? ""),
        TextCellValue(emp["name"] ?? ""),
        TextCellValue(emp["nik"] ?? ""),
        TextCellValue(emp["dept"] ?? ""),
      ]);
    }

    // Save and export
    var fileBytes = excel.save();
    if (fileBytes != null) {
      String dateStr = _selectedDate != null 
          ? "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}"
          : "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
      String fileName = "Laporan_HRIS_$dateStr.xlsx";
      
      ExportHelper.exportExcel(fileBytes, fileName);
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil mengekspor: $fileName"), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardController>(context);
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isMobile ? AppBar(backgroundColor: AppColors.primary, title: const Text("Smart Attendance", style: TextStyle(color: Colors.white))) : null,
      drawer: isMobile ? const CustomSidebar(currentIndex: 3) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) const CustomSidebar(currentIndex: 3),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Laporan Kehadiran", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  const Text("Unduh dan tinjau laporan kehadiran karyawan secara lengkap.", style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Filter Laporan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _selectedDate = date;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedDate == null 
                                            ? "Pilih Tanggal Laporan" 
                                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                                        style: const TextStyle(color: AppColors.textSecondary),
                                      ),
                                      const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () => _exportReport(context, controller),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.download, color: Colors.white),
                              label: const Text("Export ke Excel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Summary Badges just for show on the report
                  Row(
                    children: [
                      _buildStatCard("Total Log", "${controller.logs.length}", Icons.article_outlined, Colors.blue),
                      const SizedBox(width: 16),
                      _buildStatCard("Tepat Waktu", "${controller.logs.where((l) => l.status == 'TEPAT WAKTU').length}", Icons.check_circle_outline, AppColors.success),
                      const SizedBox(width: 16),
                      _buildStatCard("Terlambat", "${controller.logs.where((l) => l.status != 'TEPAT WAKTU').length}", Icons.timer_off_outlined, AppColors.danger),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
