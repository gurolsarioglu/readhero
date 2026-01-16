import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import 'widgets/summary_card_widget.dart';
import 'widgets/reading_progress_chart.dart';
import 'widgets/quiz_performance_chart.dart';
import 'widgets/daily_activity_chart.dart';
import 'reading_history_view.dart';
import 'quiz_history_view.dart';
import 'rewards_view.dart';
import 'parent_settings_view.dart';

class ParentDashboardView extends StatefulWidget {
  const ParentDashboardView({Key? key}) : super(key: key);

  @override
  State<ParentDashboardView> createState() => _ParentDashboardViewState();
}

class _ParentDashboardViewState extends State<ParentDashboardView> {
  Student? _selectedStudent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final studentController = context.read<StudentController>();
    final authController = context.read<AuthController>();
    final userId = authController.currentUser?.id ?? '';
    
    await studentController.loadStudents(userId);
    
    if (studentController.students.isNotEmpty) {
      setState(() {
        _selectedStudent = studentController.students.first;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Veli Paneli'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _selectedStudent == null
              ? _buildNoStudentView()
              : _buildDashboard(),
    );
  }

  Widget _buildNoStudentView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_outlined,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz öğrenci eklenmemiş',
            style: AppTheme.headlineStyle.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Öğrenci Ekle',
            onPressed: () {
              Navigator.pushNamed(context, '/add-student');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentSelector(),
            const SizedBox(height: 24),
            _buildSummaryCards(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildReadingProgressSection(),
            const SizedBox(height: 24),
            _buildQuizPerformanceSection(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSelector() {
    final studentController = context.watch<StudentController>();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              _selectedStudent!.avatar,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedStudent!.name,
                  style: AppTheme.headlineStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedStudent!.gradeLevel}. Sınıf',
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (studentController.students.length > 1)
            PopupMenuButton<Student>(
              icon: const Icon(Icons.swap_horiz),
              onSelected: (student) {
                setState(() {
                  _selectedStudent = student;
                });
              },
              itemBuilder: (context) {
                return studentController.students.map((student) {
                  return PopupMenuItem<Student>(
                    value: student,
                    child: Row(
                      children: [
                        Text(student.avatar, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text(student.name),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    // TODO: Gerçek verilerle değiştirilecek
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Özet İstatistikler',
          style: AppTheme.headlineStyle,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            SummaryCardWidget(
              title: 'Bugün',
              value: '45 dk',
              subtitle: 'Okuma süresi',
              icon: Icons.timer_outlined,
              color: AppTheme.primaryColor,
            ),
            SummaryCardWidget(
              title: 'Toplam',
              value: '${_selectedStudent!.currentPoints}',
              subtitle: 'Puan',
              icon: Icons.stars_outlined,
              color: AppTheme.accentColor,
            ),
            SummaryCardWidget(
              title: 'Bu Ay',
              value: '12',
              subtitle: 'Kitap',
              icon: Icons.book_outlined,
              color: AppTheme.secondaryColor,
            ),
            SummaryCardWidget(
              title: 'Başarı',
              value: '85%',
              subtitle: 'Ortalama',
              icon: Icons.trending_up_outlined,
              color: AppTheme.successColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Erişim',
          style: AppTheme.headlineStyle,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Okuma Geçmişi',
                Icons.history,
                AppTheme.primaryColor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReadingHistoryView(
                        studentId: _selectedStudent!.id,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Sınav Geçmişi',
                Icons.quiz_outlined,
                AppTheme.secondaryColor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizHistoryView(
                        studentId: _selectedStudent!.id,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Ödüller',
                Icons.card_giftcard_outlined,
                AppTheme.accentColor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RewardsView(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Ayarlar',
                Icons.settings_outlined,
                AppTheme.textSecondary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ParentSettingsView(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Okuma Gelişimi',
              style: AppTheme.headlineStyle,
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadingHistoryView(
                      studentId: _selectedStudent!.id,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Detay'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ReadingProgressChart(
            studentId: _selectedStudent!.id,
            gradeLevel: _selectedStudent!.gradeLevel,
          ),
        ),
      ],
    );
  }

  Widget _buildQuizPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sınav Başarısı',
              style: AppTheme.headlineStyle,
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizHistoryView(
                      studentId: _selectedStudent!.id,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Detay'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: QuizPerformanceChart(
            studentId: _selectedStudent!.id,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Aktiviteler',
          style: AppTheme.headlineStyle,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                'Küçük Kedi Minnos',
                'Hikaye okundu',
                '2 saat önce',
                Icons.book_outlined,
                AppTheme.primaryColor,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                'Okul Gezisi Sınavı',
                '80% başarı',
                '5 saat önce',
                Icons.quiz_outlined,
                AppTheme.secondaryColor,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                'Hızlı Okuyucu Rozeti',
                'Rozet kazanıldı',
                'Dün',
                Icons.emoji_events_outlined,
                AppTheme.accentColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: AppTheme.captionStyle,
      ),
    );
  }
}
