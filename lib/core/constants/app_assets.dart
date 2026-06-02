import 'package:flutter/material.dart';

class SmartAttendanceLogo extends StatelessWidget {
  final double size;

  const SmartAttendanceLogo({Key? key, this.size = 80}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A), // Warna background biru tua di mockup
        borderRadius: BorderRadius.circular(size * 0.22), // Sudut melengkung halus
      ),
      padding: EdgeInsets.all(size * 0.18),
      child: CustomPaint(
        painter: _HexagonShieldPainter(),
      ),
    );
  }
}

class _HexagonShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // 1. Menggambar Jalur Luar Perisai Segienam (Outer Hexagon Shield)
    final outerPath = Path()
      ..moveTo(w * 0.5, 0)          // Titik atas tengah
      ..lineTo(w, h * 0.25)         // Kanan atas
      ..lineTo(w, h * 0.75)         // Kanan bawah
      ..lineTo(w * 0.5, h)          // Titik bawah tengah
      ..lineTo(0, h * 0.75)         // Kiri bawah
      ..lineTo(0, h * 0.25)         // Kiri atas
      ..close();
    canvas.drawPath(outerPath, paint);

    // 2. Menggambar Pola Garis Labirin Internal Atas (Sesuai Mockup)
    final innerTopPath = Path()
      ..moveTo(w * 0.25, h * 0.37)
      ..lineTo(w * 0.5, h * 0.25)
      ..lineTo(w * 0.75, h * 0.37)
      ..lineTo(w * 0.75, h * 0.55);
    canvas.drawPath(innerTopPath, paint);

    // 3. Menggambar Pola Garis Labirin Internal Bawah (Sesuai Mockup)
    final innerBottomPath = Path()
      ..moveTo(w * 0.25, h * 0.45)
      ..lineTo(w * 0.25, h * 0.63)
      ..lineTo(w * 0.5, h * 0.75)
      ..lineTo(w * 0.75, h * 0.63);
    canvas.drawPath(innerBottomPath, paint);
    
    // 4. Garis Inti Pusat (Center Core Line)
    final centerPath = Path()
      ..moveTo(w * 0.5, h * 0.42)
      ..lineTo(w * 0.5, h * 0.58);
    canvas.drawPath(centerPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
