import 'export_helper_stub.dart' if (dart.library.html) 'export_helper_web.dart';

class ExportHelper {
  static void exportExcel(List<int> bytes, String fileName) {
    downloadExcelService(bytes, fileName);
  }
}
