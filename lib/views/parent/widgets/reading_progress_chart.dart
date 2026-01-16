import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../database/database_helper.dart';
import '../../../models/models.dart';

class ReadingProgressChart extends StatefulWidget {
  final String studentId;
  final int gradeLevel;

  const ReadingProgressChart({
    Key? key,
    required this.studentId,
    required this.gradeLevel,
  }) : super(key: key);

  @override
  State<ReadingProgressChart> createState() => _ReadingProgressChartState();
}

class _ReadingProgressChartState extends State<ReadingProgressChart> {
  List<ReadingSession> _sessions = [];
  bool _isLoading = true;
  String _selectedPeriod = '7'; // 7, 14, 30 gün

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final db = DatabaseHelper.instance;
    final allSessions = await db.getReadingSessionsByStudent(widget.studentId);
    
    // Son X gün filtrele
    final days = int.parse(_selectedPeriod);
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    setState(() {
      _sessions = allSessions
          .where((s) => s.startTime.isAfter(cutoffDate))
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
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

    if (_sessions.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                size: 48,
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz okuma verisi yok',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.gradeLevel == 1 ? 'Okunan Kitap Sayısı' : 'Okuma Hızı (WPM)',
              style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
            ),
            _buildPeriodSelector(),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: widget.gradeLevel == 1
              ? _buildBookCountChart()
              : _buildWPMChart(),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedPeriod,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: '7', child: Text('7 Gün')),
          DropdownMenuItem(value: '14', child: Text('14 Gün')),
          DropdownMenuItem(value: '30', child: Text('30 Gün')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedPeriod = value);
            _loadData();
          }
        },
      ),
    );
  }

  Widget _buildWPMChart() {
    // Günlük ortalama WPM hesapla
    final Map<DateTime, List<double>> dailyWPM = {};
    
    for (var session in _sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      
      if (!dailyWPM.containsKey(date)) {
        dailyWPM[date] = [];
      }
      dailyWPM[date]!.add(session.wpm);
    }

    // Ortalama hesapla ve sırala
    final spots = dailyWPM.entries.map((entry) {
      final avgWPM = entry.value.reduce((a, b) => a + b) / entry.value.length;
      final daysDiff = entry.key.difference(DateTime.now()).inDays.abs();
      return FlSpot(daysDiff.toDouble(), avgWPM);
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    if (spots.isEmpty) {
      return const Center(child: Text('Veri yok'));
    }

    return LineChart(
      LineChartData(
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
                return Text(
                  value.toInt().toString(),
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
                final daysAgo = value.toInt();
                if (daysAgo % 2 != 0) return const SizedBox();
                return Text(
                  '-$daysAgo',
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
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2,
      ),
    );
  }

  Widget _buildBookCountChart() {
    // Günlük kitap sayısı hesapla
    final Map<DateTime, int> dailyBooks = {};
    
    for (var session in _sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      
      dailyBooks[date] = (dailyBooks[date] ?? 0) + 1;
    }

    // Bar chart için veri hazırla
    final bars = dailyBooks.entries.map((entry) {
      final daysDiff = entry.key.difference(DateTime.now()).inDays.abs();
      return BarChartGroupData(
        x: daysDiff,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: AppTheme.secondaryColor,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    if (bars.isEmpty) {
      return const Center(child: Text('Veri yok'));
    }

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
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
                if (value % 1 != 0) return const SizedBox();
                return Text(
                  value.toInt().toString(),
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
                final daysAgo = value.toInt();
                if (daysAgo % 2 != 0) return const SizedBox();
                return Text(
                  '-$daysAgo',
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
        minY: 0,
        maxY: bars.map((b) => b.barRods.first.toY).reduce((a, b) => a > b ? a : b) * 1.2,
      ),
    );
  }

  Widget _buildLegend() {
    final totalSessions = _sessions.length;
    final avgWPM = _sessions.isEmpty
        ? 0.0
        : _sessions.map((s) => s.wpm).reduce((a, b) => a + b) / totalSessions;
    final totalMinutes = _sessions.isEmpty
        ? 0
        : _sessions
            .map((s) => s.duration)
            .reduce((a, b) => a + b)
            .inMinutes;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(
            'Toplam Oturum',
            totalSessions.toString(),
            AppTheme.primaryColor,
          ),
          if (widget.gradeLevel > 1)
            _buildLegendItem(
              'Ort. Hız',
              '${avgWPM.toStringAsFixed(0)} WPM',
              AppTheme.secondaryColor,
            ),
          _buildLegendItem(
            'Toplam Süre',
            '$totalMinutes dk',
            AppTheme.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
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
}
