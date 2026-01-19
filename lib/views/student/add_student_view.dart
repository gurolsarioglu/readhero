import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/controllers.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';

/// Öğrenci ekleme ekranı
class AddStudentView extends StatefulWidget {
  const AddStudentView({super.key});

  @override
  State<AddStudentView> createState() => _AddStudentViewState();
}

class _AddStudentViewState extends State<AddStudentView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  int _selectedGradeLevel = 1;
  String _selectedAvatar = 'avatar_1';

  // Avatar seçenekleri (6 farklı karakter)
  final List<String> _avatars = [
    'avatar_1', // 🦁 Aslan
    'avatar_2', // 🐼 Panda
    'avatar_3', // 🦊 Tilki
    'avatar_4', // 🐨 Koala
    'avatar_5', // 🦉 Baykuş
    'avatar_6', // 🐸 Kurbağa
  ];

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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addStudent() async {
    // Form validasyonu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authController = context.read<AuthController>();
    final studentController = context.read<StudentController>();

    if (authController.currentUser == null) {
      _showError('Kullanıcı bulunamadı');
      return;
    }

    // Öğrenci ekle
    final success = await studentController.addStudent(
      userId: authController.currentUser!.id,
      name: _nameController.text,
      gradeLevel: _selectedGradeLevel,
      avatar: _selectedAvatar,
    );

    if (!mounted) return;

    if (success) {
      _showSuccess('Öğrenci eklendi!');
      
      // Formu temizle
      _nameController.clear();
      setState(() {
        _selectedGradeLevel = 1;
        _selectedAvatar = 'avatar_1';
      });

      // Öğrenci seçim ekranına git
      Navigator.of(context).pushReplacementNamed(AppRoutes.selectStudent);
    } else {
      _showError(studentController.errorMessage ?? 'Öğrenci eklenemedi');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Ekle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<StudentController>(
          builder: (context, studentController, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Açıklama
                    Text(
                      'Yeni Öğrenci',
                      style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Çocuğunuzun bilgilerini girin (Maksimum 6 öğrenci)',
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // İsim
                    CustomTextField(
                      controller: _nameController,
                      label: 'Öğrenci Adı',
                      hint: 'Ahmet',
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.name],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'İsim gerekli';
                        }
                        if (value.length < 2) {
                          return 'En az 2 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sınıf seviyesi
                    Text(
                      'Sınıf Seviyesi',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(4, (index) {
                        final grade = index + 1;
                        final isSelected = _selectedGradeLevel == grade;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index < 3 ? 8 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedGradeLevel = grade;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : AppTheme.dividerColor,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  '$grade. Sınıf',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Avatar seçimi
                    Text(
                      'Avatar Seç',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _avatars.length,
                      itemBuilder: (context, index) {
                        final avatar = _avatars[index];
                        final isSelected = _selectedAvatar == avatar;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAvatar = avatar;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor.withOpacity(0.1)
                                  : AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.dividerColor,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _avatarEmojis[avatar] ?? '🦁',
                                style: const TextStyle(fontSize: 48),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Ekle butonu
                    CustomButton(
                      text: 'Öğrenci Ekle',
                      onPressed: _addStudent,
                      width: double.infinity,
                      isLoading: studentController.isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Öğrenci sayısı bilgisi
                    if (studentController.studentCount > 0)
                      Center(
                        child: Text(
                          '${studentController.studentCount}/6 öğrenci eklendi',
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
