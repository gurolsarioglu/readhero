import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

/// Otomatik Test ve Hata Raporlama Servisi
/// 
/// Özellikler:
/// - Tüm hataları loglar
/// - Ekran görüntüsü alır
/// - Veritabanı durumunu raporlar
/// - Kullanıcı aksiyonlarını izler
class AutoTestService {
  static final AutoTestService instance = AutoTestService._();
  AutoTestService._();

  final List<TestReport> _reports = [];
  bool _isEnabled = true;

  /// Test raporlarını al
  List<TestReport> get reports => List.unmodifiable(_reports);

  /// Hata kaydet
  void logError(String feature, String error, {StackTrace? stackTrace}) {
    if (!_isEnabled) return;
    
    final report = TestReport(
      timestamp: DateTime.now(),
      type: ReportType.error,
      feature: feature,
      message: error,
      stackTrace: stackTrace?.toString(),
    );
    
    _reports.add(report);
    debugPrint('❌ ERROR: [$feature] $error');
    
    // Dosyaya yaz
    _saveReport(report);
  }

  /// Başarılı aksiyon kaydet
  void logSuccess(String feature, String message) {
    if (!_isEnabled) return;
    
    final report = TestReport(
      timestamp: DateTime.now(),
      type: ReportType.success,
      feature: feature,
      message: message,
    );
    
    _reports.add(report);
    debugPrint('✅ SUCCESS: [$feature] $message');
  }

  /// Uyarı kaydet
  void logWarning(String feature, String message) {
    if (!_isEnabled) return;
    
    final report = TestReport(
      timestamp: DateTime.now(),
      type: ReportType.warning,
      feature: feature,
      message: message,
    );
    
    _reports.add(report);
    debugPrint('⚠️ WARNING: [$feature] $message');
  }

  /// Kullanıcı aksiyonu kaydet
  void logUserAction(String screen, String action, {Map<String, dynamic>? data}) {
    if (!_isEnabled) return;
    
    final report = TestReport(
      timestamp: DateTime.now(),
      type: ReportType.userAction,
      feature: screen,
      message: action,
      data: data,
    );
    
    _reports.add(report);
    debugPrint('👆 USER ACTION: [$screen] $action');
  }

  /// Veritabanı durumu kaydet
  void logDatabaseState(String table, int count, {String? details}) {
    if (!_isEnabled) return;
    
    final report = TestReport(
      timestamp: DateTime.now(),
      type: ReportType.database,
      feature: 'Database',
      message: '$table: $count rows',
      data: {'table': table, 'count': count, 'details': details},
    );
    
    _reports.add(report);
    debugPrint('💾 DATABASE: $table = $count rows');
  }

  /// Ekran görüntüsü al
  Future<String?> takeScreenshot(GlobalKey key, String name) async {
    try {
      final RenderRepaintBoundary boundary = 
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = 
          await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return null;
      
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      
      // Dosyaya kaydet
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/screenshots/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(pngBytes);
      
      debugPrint('📸 Screenshot saved: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('❌ Screenshot failed: $e');
      return null;
    }
  }

  /// Raporu dosyaya kaydet
  Future<void> _saveReport(TestReport report) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/test_reports/latest.log');
      await file.create(recursive: true);
      
      final line = '${report.timestamp.toIso8601String()} | '
                   '${report.type.name.toUpperCase()} | '
                   '${report.feature} | '
                   '${report.message}\n';
      
      await file.writeAsString(line, mode: FileMode.append);
    } catch (e) {
      debugPrint('Failed to save report: $e');
    }
  }

  /// Tüm raporları temizle
  void clearReports() {
    _reports.clear();
    debugPrint('🧹 All reports cleared');
  }

  /// Rapor özeti
  String getSummary() {
    final errors = _reports.where((r) => r.type == ReportType.error).length;
    final warnings = _reports.where((r) => r.type == ReportType.warning).length;
    final success = _reports.where((r) => r.type == ReportType.success).length;
    
    return 'Test Summary: ✅ $success | ⚠️ $warnings | ❌ $errors';
  }

  /// Detaylı rapor oluştur
  Future<String> generateDetailedReport() async {
    final buffer = StringBuffer();
    buffer.writeln('=== READHERO TEST REPORT ===');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total Reports: ${_reports.length}');
    buffer.writeln(getSummary());
    buffer.writeln('\n=== DETAILED LOG ===\n');
    
    for (final report in _reports) {
      buffer.writeln('${report.timestamp} | ${report.type.name}');
      buffer.writeln('Feature: ${report.feature}');
      buffer.writeln('Message: ${report.message}');
      if (report.data != null) {
        buffer.writeln('Data: ${report.data}');
      }
      if (report.stackTrace != null) {
        buffer.writeln('Stack: ${report.stackTrace}');
      }
      buffer.writeln('---');
    }
    
    // Dosyaya kaydet
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/test_reports/detailed_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.create(recursive: true);
      await file.writeAsString(buffer.toString());
      
      debugPrint('📄 Detailed report saved: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('Failed to save detailed report: $e');
      return buffer.toString();
    }
  }
}

/// Test raporu modeli
class TestReport {
  final DateTime timestamp;
  final ReportType type;
  final String feature;
  final String message;
  final String? stackTrace;
  final Map<String, dynamic>? data;

  TestReport({
    required this.timestamp,
    required this.type,
    required this.feature,
    required this.message,
    this.stackTrace,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'type': type.name,
    'feature': feature,
    'message': message,
    if (stackTrace != null) 'stackTrace': stackTrace,
    if (data != null) 'data': data,
  };
}

/// Rapor tipleri
enum ReportType {
  error,
  warning,
  success,
  userAction,
  database,
  performance,
}
