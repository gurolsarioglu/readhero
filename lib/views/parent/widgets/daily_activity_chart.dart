import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../database/database_helper.dart';

/// Günlük aktivite heatmap widget'ı (takvim görünümü)
class DailyActivityChart extends StatefulWidget {
  final String studentId;

  const DailyActivityChart({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  @override
  State<DailyActivityChart> createState() => _DailyActivityChartState();
}

class _DailyActivityChartState extends State<DailyActivityChart> {
  final _db = DatabaseHelper.instance;
  Map<DateTime, int> _activityData = {};
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  Future<void> _loadActivityData() async {
    setState(() => _isLoading = true);

    try {
      // Son 90 günün okuma oturumlarını al
      final sessions = await _db.getReadingSessionsByStudent(widget.studentId);
      
      // Günlere göre grupla
      final Map<DateTime, int> activityMap = {};
      
      for (var session in sessions) {
        // startTime bir timestamp (int) - DateTime'a dönüştür
        final startDate = DateTime.fromMillisecondsSinceEpoch(session.startTime);
        final date = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        
        // O gündeki toplam okuma süresini hesapla (dakika)
        // duration saniye cinsinden int
        final minutes = (session.duration ?? 0) ~/ 60;
        activityMap[date] = (activityMap[date] ?? 0) + minutes;
      }

      setState(() {
        _activityData = activityMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildCalendar(),
        const SizedBox(height: 16),
        _buildLegend(),
        const SizedBox(height: 16),
        _buildStats(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy', 'tr_TR').format(_selectedMonth),
          style: AppTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month - 1,
                  );
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month + 1,
                  );
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    
    // İlk günün haftanın hangi günü olduğunu bul (1 = Pazartesi, 7 = Pazar)
    int firstWeekday = firstDayOfMonth.weekday;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Gün başlıkları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
                .map((day) => SizedBox(
                      width: 32,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: AppTheme.captionStyle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Takvim günleri
          ...List.generate(6, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 2;
                  
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox(width: 32, height: 32);
                  }

                  final date = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);
                  final activity = _activityData[date] ?? 0;

                  return _buildDayCell(dayNumber, activity, date);
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayCell(int day, int activityMinutes, DateTime date) {
    final isToday = DateTime.now().year == date.year &&
        DateTime.now().month == date.month &&
        DateTime.now().day == date.day;

    final isFuture = date.isAfter(DateTime.now());

    Color cellColor;
    if (isFuture) {
      cellColor = Colors.grey.shade100;
    } else if (activityMinutes == 0) {
      cellColor = Colors.grey.shade200;
    } else if (activityMinutes < 10) {
      cellColor = AppTheme.primaryColor.withOpacity(0.2);
    } else if (activityMinutes < 20) {
      cellColor = AppTheme.primaryColor.withOpacity(0.4);
    } else if (activityMinutes < 30) {
      cellColor = AppTheme.primaryColor.withOpacity(0.6);
    } else {
      cellColor = AppTheme.primaryColor.withOpacity(0.8);
    }

    return GestureDetector(
      onTap: () => _showDayDetails(date, activityMinutes),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: AppTheme.accentColor, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: activityMinutes > 15 ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Az', style: AppTheme.captionStyle),
        const SizedBox(width: 8),
        _buildLegendBox(Colors.grey.shade200),
        const SizedBox(width: 4),
        _buildLegendBox(AppTheme.primaryColor.withOpacity(0.2)),
        const SizedBox(width: 4),
        _buildLegendBox(AppTheme.primaryColor.withOpacity(0.4)),
        const SizedBox(width: 4),
        _buildLegendBox(AppTheme.primaryColor.withOpacity(0.6)),
        const SizedBox(width: 4),
        _buildLegendBox(AppTheme.primaryColor.withOpacity(0.8)),
        const SizedBox(width: 8),
        Text('Çok', style: AppTheme.captionStyle),
      ],
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildStats() {
    final totalDays = _activityData.length;
    final totalMinutes = _activityData.values.fold(0, (sum, minutes) => sum + minutes);
    final avgMinutes = totalDays > 0 ? totalMinutes / totalDays : 0;
    
    // Bu aydaki aktivite
    final thisMonthActivity = _activityData.entries.where((entry) {
      return entry.key.year == _selectedMonth.year &&
          entry.key.month == _selectedMonth.month;
    }).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Bu Ay', '$thisMonthActivity gün', Icons.calendar_today),
          _buildStatItem('Toplam', '$totalDays gün', Icons.event_available),
          _buildStatItem('Ortalama', '${avgMinutes.toStringAsFixed(0)} dk', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: AppTheme.captionStyle,
        ),
      ],
    );
  }

  void _showDayDetails(DateTime date, int activityMinutes) {
    if (activityMinutes == 0) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DateFormat('dd MMMM yyyy', 'tr_TR').format(date)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer_outlined, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  '$activityMinutes dakika okuma',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              activityMinutes >= 20
                  ? '🎉 Harika! Günlük hedefe ulaştın!'
                  : '💪 Devam et! Hedefe ${20 - activityMinutes} dakika kaldı.',
              style: AppTheme.bodyStyle,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
