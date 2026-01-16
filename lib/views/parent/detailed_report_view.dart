import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../database/database_helper.dart';
import '../../models/models.dart';

/// Detaylı rapor görüntüleme sayfası
/// Günlük, haftalık, aylık raporlar ve tarih aralığı seçimi
class DetailedReportView extends StatefulWidget {
  final String studentId;

  const DetailedReportView({
    super.key,
    required this.studentId,
  });

  @override
  State<DetailedReportView> createState() => _DetailedReportViewState();
}

class _DetailedReportViewState extends State<DetailedReportView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  
  List<ReadingSession> _sessions = [];
  List<QuizResult> _quizResults = [];
  bool _isLoading = true;

  // İstatistikler
  int _totalReadingMinutes = 0;
  int _totalBooksCompleted = 0;
  double _averageWPM = 0;
  double _averageQuizScore = 0;
  int _totalQuizzes = 0;
  int _perfectScores = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _updateDateRange();
      }
    });
    _loadReportData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Tab değiştiğinde tarih aralığını güncelle
  void _updateDateRange() {
    final now = DateTime.now();
    setState(() {
      switch (_tabController.index) {
        case 0: // Günlük
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = now;
          break;
        case 1: // Haftalık
          _startDate = now.subtract(const Duration(days: 7));
          _endDate = now;
          break;
        case 2: // Aylık
          _startDate = DateTime(now.year, now.month - 1, now.day);
          _endDate = now;
          break;
        case 3: // Özel aralık - değiştirme
          break;
      }
    });
    _loadReportData();
  }

  /// Rapor verilerini yükle
  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper.instance.database;

      // Okuma oturumlarını getir
      final sessionMaps = await db.query(
        'reading_sessions',
        where: 'student_id = ? AND start_time >= ? AND start_time <= ?',
        whereArgs: [
          widget.studentId,
          _startDate.millisecondsSinceEpoch,
          _endDate.millisecondsSinceEpoch,
        ],
        orderBy: 'start_time DESC',
      );

      _sessions = sessionMaps.map((map) => ReadingSession.fromMap(map)).toList();

      // Sınav sonuçlarını getir
      final quizMaps = await db.query(
        'quiz_results',
        where: 'student_id = ? AND completed_at >= ? AND completed_at <= ?',
        whereArgs: [
          widget.studentId,
          _startDate.millisecondsSinceEpoch,
          _endDate.millisecondsSinceEpoch,
        ],
        orderBy: 'completed_at DESC',
      );

      _quizResults = quizMaps.map((map) => QuizResult.fromMap(map)).toList();

      // İstatistikleri hesapla
      _calculateStatistics();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Rapor verileri yüklenirken hata: $e');
      setState(() => _isLoading = false);
    }
  }

  /// İstatistikleri hesapla
  void _calculateStatistics() {
    // Toplam okuma süresi
    _totalReadingMinutes = _sessions.fold<int>(
      0,
      (sum, session) => sum + (session.duration ~/ 60),
    );

    // Tamamlanan kitap sayısı (completion rate >= 90%)
    _totalBooksCompleted = _sessions.where((s) => s.completionRate >= 90).length;

    // Ortalama WPM
    if (_sessions.isNotEmpty) {
      final totalWPM = _sessions.fold<double>(
        0,
        (sum, session) => sum + session.wpm,
      );
      _averageWPM = totalWPM / _sessions.length;
    }

    // Sınav istatistikleri
    _totalQuizzes = _quizResults.length;
    if (_quizResults.isNotEmpty) {
      final totalScore = _quizResults.fold<int>(
        0,
        (sum, quiz) => sum + quiz.score,
      );
      _averageQuizScore = totalScore / _quizResults.length;
      _perfectScores = _quizResults.where((q) => q.isPerfect).length;
    }
  }

  /// Tarih seçici göster
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReportData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detaylı Rapor'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Günlük'),
            Tab(text: 'Haftalık'),
            Tab(text: 'Aylık'),
            Tab(text: 'Özel'),
          ],
        ),
        actions: [
          if (_tabController.index == 3)
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: _selectDateRange,
              tooltip: 'Tarih Aralığı Seç',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReportContent(),
                _buildReportContent(),
                _buildReportContent(),
                _buildReportContent(),
              ],
            ),
    );
  }

  /// Rapor içeriği
  Widget _buildReportContent() {
    return RefreshIndicator(
      onRefresh: _loadReportData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarih aralığı
            _buildDateRangeCard(),
            const SizedBox(height: 16),

            // Özet istatistikler
            _buildSummaryCards(),
            const SizedBox(height: 24),

            // Okuma detayları
            _buildReadingDetails(),
            const SizedBox(height: 24),

            // Sınav detayları
            _buildQuizDetails(),
            const SizedBox(height: 24),

            // Export butonları
            _buildExportButtons(),
          ],
        ),
      ),
    );
  }

  /// Tarih aralığı kartı
  Widget _buildDateRangeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rapor Dönemi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('d MMMM yyyy', 'tr_TR').format(_startDate)} - '
                    '${DateFormat('d MMMM yyyy', 'tr_TR').format(_endDate)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Özet kartlar
  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Özet İstatistikler',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Okuma Süresi',
                '$_totalReadingMinutes dk',
                Icons.timer,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Kitap',
                '$_totalBooksCompleted',
                Icons.book,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Ort. WPM',
                _averageWPM.toStringAsFixed(0),
                Icons.speed,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Sınav Ort.',
                '${_averageQuizScore.toStringAsFixed(0)}%',
                Icons.school,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// İstatistik kartı
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Okuma detayları
  Widget _buildReadingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Okuma Detayları',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_sessions.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Bu dönemde okuma kaydı yok'),
              ),
            ),
          )
        else
          ..._sessions.map((session) => _buildSessionCard(session)),
      ],
    );
  }

  /// Okuma oturumu kartı
  Widget _buildSessionCard(ReadingSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(Icons.book, color: AppTheme.primaryColor),
        ),
        title: Text(
          'Okuma Oturumu',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat('d MMMM yyyy, HH:mm', 'tr_TR')
              .format(session.startTime),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${session.duration ~/ 60} dk',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${session.wpm.toStringAsFixed(0)} WPM',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sınav detayları
  Widget _buildQuizDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sınav Detayları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_perfectScores > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '$_perfectScores Mükemmel',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_quizResults.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('Bu dönemde sınav kaydı yok'),
              ),
            ),
          )
        else
          ..._quizResults.map((quiz) => _buildQuizCard(quiz)),
      ],
    );
  }

  /// Sınav kartı
  Widget _buildQuizCard(QuizResult quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: quiz.isPassed
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          child: Icon(
            quiz.isPassed ? Icons.check_circle : Icons.cancel,
            color: quiz.isPassed ? Colors.green : Colors.red,
          ),
        ),
        title: Row(
          children: [
            const Text(
              'Sınav',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (quiz.isPerfect) ...[
              const SizedBox(width: 8),
              const Icon(Icons.star, size: 16, color: Colors.amber),
            ],
          ],
        ),
        subtitle: Text(
          DateFormat('d MMMM yyyy, HH:mm', 'tr_TR')
              .format(quiz.completedAt),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${quiz.score}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: quiz.isPassed ? Colors.green : Colors.red,
              ),
            ),
            Text(
              quiz.grade,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Export butonları
  Widget _buildExportButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Raporu Dışa Aktar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _exportToPDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exportToExcel,
                icon: const Icon(Icons.table_chart),
                label: const Text('Excel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// PDF'e aktar
  Future<void> _exportToPDF() async {
    // TODO: PDF export implementasyonu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF export özelliği yakında eklenecek'),
      ),
    );
  }

  /// Excel'e aktar
  Future<void> _exportToExcel() async {
    // TODO: Excel export implementasyonu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel export özelliği yakında eklenecek'),
      ),
    );
  }
}
