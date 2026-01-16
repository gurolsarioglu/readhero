import '../database/database_helper.dart';
import '../models/models.dart';

/// Öğrenci yönetim servisi
class StudentService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Öğrenci ekle
  Future<StudentModel> addStudent({
    required String userId,
    required String name,
    required int gradeLevel,
    String avatar = 'default',
  }) async {
    // Maksimum 6 öğrenci kontrolü
    final existingStudents = await getStudentsByUser(userId);
    if (existingStudents.length >= 6) {
      throw Exception('Maksimum 6 öğrenci ekleyebilirsiniz');
    }

    // Öğrenci oluştur
    final now = DateTime.now().millisecondsSinceEpoch;
    final student = StudentModel(
      id: _generateId(),
      userId: userId,
      name: name,
      gradeLevel: gradeLevel,
      avatar: avatar,
      createdAt: now,
      updatedAt: now,
    );

    await _db.insert('students', student.toMap());
    return student;
  }

  /// Kullanıcının tüm öğrencilerini getir
  Future<List<StudentModel>> getStudentsByUser(String userId) async {
    final results = await _db.query(
      'students',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );

    return results.map((map) => StudentModel.fromMap(map)).toList();
  }

  /// Öğrenciyi ID ile getir
  Future<StudentModel> getStudentById(String studentId) async {
    final studentMap = await _db.getById('students', studentId);
    if (studentMap == null) {
      throw Exception('Öğrenci bulunamadı');
    }
    return StudentModel.fromMap(studentMap);
  }

  /// Öğrenci bilgilerini güncelle
  Future<StudentModel> updateStudent({
    required String studentId,
    String? name,
    int? gradeLevel,
    String? avatar,
    int? dailyGoal,
    int? weeklyGoal,
  }) async {
    final student = await getStudentById(studentId);
    
    final updatedStudent = student.copyWith(
      name: name,
      gradeLevel: gradeLevel,
      avatar: avatar,
      dailyGoal: dailyGoal,
      weeklyGoal: weeklyGoal,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _db.update('students', updatedStudent.toMap(), studentId);
    return updatedStudent;
  }

  /// Öğrenciyi sil
  Future<void> deleteStudent(String studentId) async {
    await _db.delete('students', studentId);
  }

  /// Puan ekle
  Future<StudentModel> addPoints(String studentId, int points) async {
    final student = await getStudentById(studentId);
    final updatedStudent = student.addPoints(points);
    await _db.update('students', updatedStudent.toMap(), studentId);
    return updatedStudent;
  }

  /// Puan harca
  Future<StudentModel> spendPoints(String studentId, int points) async {
    final student = await getStudentById(studentId);
    final updatedStudent = student.spendPoints(points);
    await _db.update('students', updatedStudent.toMap(), studentId);
    return updatedStudent;
  }

  /// Rozet ekle
  Future<StudentModel> addBadge(String studentId, String badgeId) async {
    final student = await getStudentById(studentId);
    final updatedStudent = student.addBadge(badgeId);
    await _db.update('students', updatedStudent.toMap(), studentId);
    return updatedStudent;
  }

  /// Benzersiz ID oluştur
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        '_' +
        (DateTime.now().microsecond % 1000).toString();
  }
}
