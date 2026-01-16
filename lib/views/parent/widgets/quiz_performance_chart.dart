import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../database/database_helper.dart';
import '../../../models/models.dart';

class QuizPerformanceChart extends StatefulWidget {
  final String studentId;

  const QuizPerformanceChart({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  @override
  State<QuizPerformanceChart> createState() => _QuizPerformanceChartState();
}

class _QuizPerformanceChartState extends State<QuizPerformanceChart> {
  List<QuizResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final db = DatabaseHelper.instance;
    final allResults = await db.getQuizResultsByStudent(widget.studentId);
    
    setState(() {
      // Son 10 sınavı al
      _results = allResults.take(10).toList().reversed.toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_results.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz sınav verisi yok',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son ${_results.length} Sınav',
          style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: _buildBarChart(),
        ),
        const SizedBox(height: 16),
        _buildStatistics(),
      ],
    );
  }

  Widget _buildBarChart() {
    final bars = _results.asMap().entries.map((entry) {
      final index = entry.key;
      final result = entry.value;
      final percentage = (result.score / result.totalQuestions) * 100;
      
      // Renk belirleme
      Color barColor;
      if (percentage >= 80) {
        barColor = AppTheme.successColor;
      } else if (percentage >= 60) {
        barColor = AppTheme.accentColor;
      } else {
        barColor = AppTheme.errorColor;
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: percentage,
            color: barColor,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: AppTheme.textSecondary.withOpacity(0.1),
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.textSecondary.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value % 20 != 0) return const SizedBox();
                return Text(
                  '${value.toInt()}%',
                  style: AppTheme.captionStyle,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= _results.length) return const SizedBox();
                return Text(
                  '${index + 1}',
                  style: AppTheme.captionStyle,
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: bars,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final result = _results[groupIndex];
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(0)}%\n',
                AppTheme.bodyStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${result.score}/${result.totalQuestions}',
                    style: AppTheme.captionStyle.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final totalQuizzes = _results.length;
    final passedQuizzes = _results.where((r) => r.isPassed).length;
    final perfectQuizzes = _results.where((r) => r.isPerfect).length;
    final avgScore = _results.isEmpty
        ? 0.0
        : _results.map((r) => (r.score / r.totalQuestions) * 100).reduce((a, b) => a + b) / totalQuizzes;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Ortalama',
                '${avgScore.toStringAsFixed(0)}%',
                AppTheme.primaryColor,
              ),
              _buildStatItem(
                'Başarılı',
                '$passedQuizzes/$totalQuizzes',
                AppTheme.successColor,
              ),
              _buildStatItem(
                'Mükemmel',
                perfectQuizzes.toString(),
                AppTheme.accentColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.captionStyle.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendDot(AppTheme.successColor, '≥80%'),
        const SizedBox(width: 16),
        _buildLegendDot(AppTheme.accentColor, '60-79%'),
        const SizedBox(width: 16),
        _buildLegendDot(AppTheme.errorColor, '<60%'),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTheme.captionStyle,
        ),
      ],
    );
  }
}
