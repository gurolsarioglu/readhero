import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../database/database_helper.dart';
import '../../models/models.dart';

class QuizHistoryView extends StatefulWidget {
  final String studentId;

  const QuizHistoryView({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  @override
  State<QuizHistoryView> createState() => _QuizHistoryViewState();
}

class _QuizHistoryViewState extends State<QuizHistoryView> {
  List<QuizResult> _results = [];
  List<Story> _stories = [];
  bool _isLoading = true;
  String _filterBy = 'all'; // all, passed, failed

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final db = DatabaseHelper.instance;
    final results = await db.getQuizResultsByStudent(widget.studentId);
    
    // Her sonuç için hikaye bilgisini yükle
    final stories = <Story>[];
    for (var result in results) {
      // Quiz'den story ID'yi al
      final quiz = await db.getQuizById(result.quizId);
      if (quiz != null) {
        final story = await db.getStoryById(quiz.storyId);
        if (story != null) {
          stories.add(story);
        }
      }
    }
    
    setState(() {
      _results = results;
      _stories = stories;
      _isLoading = false;
    });
  }

  List<QuizResult> get _filteredResults {
    switch (_filterBy) {
      case 'passed':
        return _results.where((r) => r.isPassed).toList();
      case 'failed':
        return _results.where((r) => !r.isPassed).toList();
      default:
        return _results;
    }
  }

  Story? _getStoryForResult(QuizResult result) {
    try {
      // Bu basitleştirilmiş bir yaklaşım, gerçekte quiz-story ilişkisini kullanmalıyız
      return _stories.isNotEmpty ? _stories.first : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Sınav Geçmişi'),
        backgroundColor: AppTheme.secondaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _results.isEmpty
              ? _buildEmptyState()
              : _buildResultList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 80,
            color: AppTheme.secondaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz sınav geçmişi yok',
            style: AppTheme.headlineStyle.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk sınavı çözmeye başlayın!',
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultList() {
    final filteredResults = _filteredResults;
    
    return Column(
      children: [
        _buildSummaryHeader(),
        _buildFilterChips(),
        Expanded(
          child: filteredResults.isEmpty
              ? Center(
                  child: Text(
                    'Bu filtrede sonuç yok',
                    style: AppTheme.bodyStyle.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredResults.length,
                  itemBuilder: (context, index) {
                    final result = filteredResults[index];
                    final story = _getStoryForResult(result);
                    return _buildResultCard(result, story);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader() {
    final totalQuizzes = _results.length;
    final passedQuizzes = _results.where((r) => r.isPassed).length;
    final perfectQuizzes = _results.where((r) => r.isPerfect).length;
    final avgScore = _results.isEmpty
        ? 0.0
        : _results.map((r) => (r.score / r.totalQuestions) * 100).reduce((a, b) => a + b) / totalQuizzes;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.secondaryColor, AppTheme.secondaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            Icons.quiz_outlined,
            totalQuizzes.toString(),
            'Toplam',
          ),
          _buildSummaryItem(
            Icons.check_circle_outline,
            passedQuizzes.toString(),
            'Başarılı',
          ),
          _buildSummaryItem(
            Icons.stars_outlined,
            perfectQuizzes.toString(),
            'Mükemmel',
          ),
          _buildSummaryItem(
            Icons.percent,
            avgScore.toStringAsFixed(0),
            'Ortalama',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.headlineStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: AppTheme.captionStyle.copyWith(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('Tümü', 'all', _results.length),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Başarılı',
            'passed',
            _results.where((r) => r.isPassed).length,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Başarısız',
            'failed',
            _results.where((r) => !r.isPassed).length,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filterBy == value;
    
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterBy = value);
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.secondaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.secondaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.secondaryColor : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildResultCard(QuizResult result, Story? story) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR');
    final percentage = (result.score / result.totalQuestions) * 100;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    if (result.isPerfect) {
      statusColor = AppTheme.accentColor;
      statusIcon = Icons.stars;
      statusText = 'Mükemmel!';
    } else if (result.isPassed) {
      statusColor = AppTheme.successColor;
      statusIcon = Icons.check_circle;
      statusText = 'Başarılı';
    } else {
      statusColor = AppTheme.errorColor;
      statusIcon = Icons.cancel;
      statusText = 'Başarısız';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _showResultDetails(result, story),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      story?.title ?? 'Bilinmeyen Hikaye',
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: AppTheme.captionStyle.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(DateTime.fromMillisecondsSinceEpoch(result.completedAt)),
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppTheme.textSecondary.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    result.formattedScore,
                    style: AppTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${result.score}/${result.totalQuestions} Doğru',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    result.grade,
                    style: AppTheme.captionStyle.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultDetails(QuizResult result, Story? story) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final percentage = (result.score / result.totalQuestions) * 100;
        
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    story?.title ?? 'Bilinmeyen Hikaye',
                    style: AppTheme.headlineStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: percentage / 100,
                            strokeWidth: 12,
                            backgroundColor: AppTheme.textSecondary.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              result.isPassed ? AppTheme.successColor : AppTheme.errorColor,
                            ),
                          ),
                          Center(
                            child: Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: AppTheme.headlineStyle.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: result.isPassed ? AppTheme.successColor : AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildDetailRow('Toplam Soru', result.totalQuestions.toString()),
                  _buildDetailRow('Doğru Cevap', result.score.toString()),
                  _buildDetailRow('Yanlış Cevap', (result.totalQuestions - result.score).toString()),
                  _buildDetailRow('Başarı Oranı', result.formattedScore),
                  _buildDetailRow('Not', result.grade),
                  _buildDetailRow('Durum', result.isPassed ? 'Başarılı ✓' : 'Başarısız ✗'),
                  _buildDetailRow('Tarih', DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(DateTime.fromMillisecondsSinceEpoch(result.completedAt))),
                  const SizedBox(height: 24),
                  if (result.isPerfect)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars, color: AppTheme.accentColor, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tebrikler! Mükemmel bir sonuç! 🎉',
                              style: AppTheme.bodyStyle.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Kapat',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
