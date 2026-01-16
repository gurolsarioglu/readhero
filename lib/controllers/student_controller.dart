import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import '../services/validation_service.dart';

/// Öğrenci yönetimi controller'ı
/// Provider ile state management sağlar
class StudentController extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ==================== STATE ====================

  List<StudentModel> _students = [];
  StudentModel? _selectedStudent;
  bool _isLoading = false;
  String? _errorMessage;

  // ==================== GETTERS ====================

  /// Tüm öğrenciler
  List<StudentModel> get students => _students;

  /// Seçili öğrenci
  StudentModel? get selectedStudent => _selectedStudent;

  /// Yüklenme durumu
  bool get isLoading => _isLoading;

  /// Hata mesajı
  String? get errorMessage => _errorMessage;

  /// Öğrenci sayısı
  int get studentCount => _students.length;

  /// Maksimum öğrenci sayısına ulaşıldı mı? (6 öğrenci)
  bool get isMaxStudentsReached => _students.length >= 6;

  /// Öğrenci var mı?
  bool get hasStudents => _students.isNotEmpty;

  // ==================== ÖĞRENCİ İŞLEMLERİ ====================

  /// Öğrencileri yükle (userId'ye göre)
  Future<void> loadStudents(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final results = await _db.query(
        'students',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt ASC',
      );

      _students = results.map((map) => StudentModel.fromMap(map)).toList();

      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
    }
  }

  /// Öğrenci ekle
  Future<bool> addStudent({
    required String userId,
    required String name,
    required int gradeLevel,
    required String avatar,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Maksimum öğrenci kontrolü
      if (_students.length >= 6) {
        _setError('Maksimum 6 öğrenci ekleyebilirsiniz');
        return false;
      }

      // Validasyon
      final nameError = ValidationService.validateStudentName(name);
      if (nameError != null) {
        _setError(nameError);
        return false;
      }

      final gradeLevelError = ValidationService.validateGradeLevel(gradeLevel);
      if (gradeLevelError != null) {
        _setError(gradeLevelError);
        return false;
      }

      // Öğrenci oluştur
      final now = DateTime.now().millisecondsSinceEpoch;
      final student = StudentModel(
        id: _generateId(),
        userId: userId,
        name: name.trim(),
        gradeLevel: gradeLevel,
        avatar: avatar,
        currentPoints: 0,
        totalPoints: 0,
        badges: [],
        createdAt: now,
        updatedAt: now,
      );

      // Veritabanına kaydet
      await _db.insert('students', student.toMap());

      // Listeye ekle
      _students.add(student);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Öğrenci güncelle
  Future<bool> updateStudent({
    required String studentId,
    String? name,
    int? gradeLevel,
    String? avatar,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Öğrenciyi bul
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index == -1) {
        _setError('Öğrenci bulunamadı');
        return false;
      }

      final student = _students[index];

      // Validasyon
      if (name != null) {
        final nameError = ValidationService.validateStudentName(name);
        if (nameError != null) {
          _setError(nameError);
          return false;
        }
      }

      if (gradeLevel != null) {
        final gradeLevelError = ValidationService.validateGradeLevel(gradeLevel);
        if (gradeLevelError != null) {
          _setError(gradeLevelError);
          return false;
        }
      }

      // Güncelle
      final updatedStudent = student.copyWith(
        name: name?.trim(),
        gradeLevel: gradeLevel,
        avatar: avatar,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Veritabanını güncelle
      await _db.update('students', updatedStudent.toMap(), studentId);

      // Listeyi güncelle
      _students[index] = updatedStudent;

      // Seçili öğrenci güncelleniyorsa
      if (_selectedStudent?.id == studentId) {
        _selectedStudent = updatedStudent;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Öğrenci sil
  Future<bool> deleteStudent(String studentId) async {
    try {
      _setLoading(true);
      _clearError();

      // Öğrenciyi bul
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index == -1) {
        _setError('Öğrenci bulunamadı');
        return false;
      }

      // Veritabanından sil
      await _db.delete('students', studentId);

      // Listeden çıkar
      _students.removeAt(index);

      // Seçili öğrenci siliniyorsa
      if (_selectedStudent?.id == studentId) {
        _selectedStudent = null;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Öğrenci seç
  void selectStudent(String studentId) {
    final student = _students.firstWhere(
      (s) => s.id == studentId,
      orElse: () => throw Exception('Öğrenci bulunamadı'),
    );
    _selectedStudent = student;
    notifyListeners();
  }

  /// Seçili öğrenciyi temizle
  void clearSelectedStudent() {
    _selectedStudent = null;
    notifyListeners();
  }

  // ==================== PUAN İŞLEMLERİ ====================

  /// Puan ekle
  Future<bool> addPoints(String studentId, int points) async {
    try {
      _setLoading(true);
      _clearError();

      // Öğrenciyi bul
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index == -1) {
        _setError('Öğrenci bulunamadı');
        return false;
      }

      final student = _students[index];

      // Puan ekle
      final updatedStudent = student.addPoints(points);

      // Veritabanını güncelle
      await _db.update('students', updatedStudent.toMap(), studentId);

      // Listeyi güncelle
      _students[index] = updatedStudent;

      // Seçili öğrenci güncelleniyorsa
      if (_selectedStudent?.id == studentId) {
        _selectedStudent = updatedStudent;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Puan harca
  Future<bool> spendPoints(String studentId, int points) async {
    try {
      _setLoading(true);
      _clearError();

      // Öğrenciyi bul
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index == -1) {
        _setError('Öğrenci bulunamadı');
        return false;
      }

      final student = _students[index];

      // Yeterli puan var mı?
      if (student.currentPoints < points) {
        _setError('Yetersiz puan');
        return false;
      }

      // Puan harca
      final updatedStudent = student.spendPoints(points);

      // Veritabanını güncelle
      await _db.update('students', updatedStudent.toMap(), studentId);

      // Listeyi güncelle
      _students[index] = updatedStudent;

      // Seçili öğrenci güncelleniyorsa
      if (_selectedStudent?.id == studentId) {
        _selectedStudent = updatedStudent;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // ==================== ROZET İŞLEMLERİ ====================

  /// Rozet ekle
  Future<bool> addBadge(String studentId, String badgeId) async {
    try {
      _setLoading(true);
      _clearError();

      // Öğrenciyi bul
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index == -1) {
        _setError('Öğrenci bulunamadı');
        return false;
      }

      final student = _students[index];

      // Rozet zaten var mı?
      if (student.badges.contains(badgeId)) {
        _setError('Bu rozet zaten kazanılmış');
        return false;
      }

      // Rozet ekle
      final updatedStudent = student.addBadge(badgeId);

      // Veritabanını güncelle
      await _db.update('students', updatedStudent.toMap(), studentId);

      // Listeyi güncelle
      _students[index] = updatedStudent;

      // Seçili öğrenci güncelleniyorsa
      if (_selectedStudent?.id == studentId) {
        _selectedStudent = updatedStudent;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  /// Öğrencinin rozetlerini al
  List<String> getStudentBadges(String studentId) {
    final student = _students.firstWhere(
      (s) => s.id == studentId,
      orElse: () => throw Exception('Öğrenci bulunamadı'),
    );
    return student.badges;
  }

  // ==================== İSTATİSTİK İŞLEMLERİ ====================

  /// Toplam öğrenci puanı
  int getTotalPoints() {
    return _students.fold(0, (sum, student) => sum + student.currentPoints);
  }

  /// En yüksek puanlı öğrenci
  StudentModel? getTopStudent() {
    if (_students.isEmpty) return null;
    
    return _students.reduce((current, next) =>
        current.currentPoints > next.currentPoints ? current : next);
  }

  /// Sınıf seviyesine göre öğrencileri filtrele
  List<StudentModel> getStudentsByGrade(int gradeLevel) {
    return _students.where((s) => s.gradeLevel == gradeLevel).toList();
  }

  // ==================== YARDIMCI METODLAR ====================

  /// Benzersiz ID oluştur
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        (DateTime.now().microsecond % 1000).toString();
  }

  /// Yüklenme durumunu ayarla
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Hata mesajını ayarla
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Hatayı temizle
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Hatayı manuel temizle (UI'dan)
  void clearError() {
    _clearError();
  }

  /// Controller'ı temizle
  @override
  void dispose() {
    _students.clear();
    _selectedStudent = null;
    super.dispose();
  }
}
