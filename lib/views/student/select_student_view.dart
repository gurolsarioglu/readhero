import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/controllers.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';

/// Öğrenci seçim ekranı - Giriş sonrası hangi öğrenci kullanacak
class SelectStudentView extends StatefulWidget {
  const SelectStudentView({super.key});

  @override
  State<SelectStudentView> createState() => _SelectStudentViewState();
}

class _SelectStudentViewState extends State<SelectStudentView> {
  // Avatar emojileri (geçici - sonra görseller eklenecek)
  final Map<String, String> _avatarEmojis = {
    'avatar_1': '🦁',
    'avatar_2': '🐼',
    'avatar_3': '🦊',
    'avatar_4': '🐨',
    'avatar_5': '🦉',
    'avatar_6': '🐸',
  };

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final authController = context.read<AuthController>();
    final studentController = context.read<StudentController>();

    if (authController.currentUser != null) {
      await studentController.loadStudents(authController.currentUser!.id);
    }
  }

  void _selectStudent(String studentId) {
    final studentController = context.read<StudentController>();
    studentController.selectStudent(studentId);

    // Kütüphane ekranına git
    Navigator.of(context).pushReplacementNamed(AppRoutes.library);
  }

  void _addStudent() {
    Navigator.of(context).pushNamed(AppRoutes.addStudent);
  }

  void _logout() {
    final authController = context.read<AuthController>();
    authController.logout();
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Seç'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Çıkış butonu
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer2<AuthController, StudentController>(
          builder: (context, authController, studentController, child) {
            if (studentController.isLoading) {
              return const Center(child: LoadingIndicator());
            }

            if (!studentController.hasStudents) {
              return _buildEmptyState();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hoş geldin mesajı
                  Text(
                    'Hoş Geldin,',
                    style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authController.currentUser?.name ?? 'Kullanıcı',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hangi öğrenci okuyacak?',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Öğrenci kartları
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.70, // Taşmayı önlemek için yükseklik oranı artırıldı
                    ),
                    itemCount: studentController.students.length,
                    itemBuilder: (context, index) {
                      final student = studentController.students[index];
                      return _buildStudentCard(student);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Yeni öğrenci ekle butonu
                  if (!studentController.isMaxStudentsReached)
                    CustomButton(
                      text: 'Yeni Öğrenci Ekle',
                      onPressed: _addStudent,
                      width: double.infinity,
                      backgroundColor: AppTheme.secondaryColor,
                      icon: Icons.add,
                    ),

                  if (studentController.isMaxStudentsReached)
                    Center(
                      child: Text(
                        'Maksimum 6 öğrenci ekleyebilirsiniz',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // AI Test butonu (geliştirme için)
                  CustomButton(
                    text: 'AI Hikaye Üretici (Test)',
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.aiTest);
                    },
                    width: double.infinity,
                    backgroundColor: AppTheme.accentColor,
                    icon: Icons.auto_awesome,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Kütüphane butonu
                  CustomButton(
                    text: 'Hikaye Kütüphanesi',
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.library);
                    },
                    width: double.infinity,
                    backgroundColor: AppTheme.secondaryColor,
                    icon: Icons.library_books,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStudentCard(student) {
    return GestureDetector(
      onTap: () => _selectStudent(student.id),
      child: CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _avatarEmojis[student.avatar] ?? '🦁',
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // İsim
              Text(
                student.name,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              // Sınıf
              Text(
                '${student.gradeLevel}. Sınıf',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              
              // Puan
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${student.currentPoints}',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 80,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Henüz Öğrenci Yok',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'İlk öğrencinizi ekleyerek başlayın',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Öğrenci Ekle',
              onPressed: _addStudent,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}
