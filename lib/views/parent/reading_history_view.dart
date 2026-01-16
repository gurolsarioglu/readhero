import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../database/database_helper.dart';
import '../../models/models.dart';

class ReadingHistoryView extends StatefulWidget {
  final String studentId;

  const ReadingHistoryView({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  @override
  State<ReadingHistoryView> createState() => _ReadingHistoryViewState();
}

class _ReadingHistoryViewState extends State<ReadingHistoryView> {
  List<ReadingSession> _sessions = [];
  List<Story> _stories = [];
  bool _isLoading = true;
  String _sortBy = 'date'; // date, duration, wpm
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final db = DatabaseHelper.instance;
    final sessions = await db.getReadingSessionsByStudent(widget.studentId);
    
    // Her oturum için hikaye bilgisini yükle
    final stories = <Story>[];
    for (var session in sessions) {
      final story = await db.getStoryById(session.storyId);
      if (story != null) {
        stories.add(story);
      }
    }
    
    setState(() {
      _sessions = sessions;
      _stories = stories;
      _isLoading = false;
    });
    
    _sortSessions();
  }

  void _sortSessions() {
    setState(() {
      switch (_sortBy) {
        case 'date':
          _sessions.sort((a, b) => _ascending
              ? a.startTime.compareTo(b.startTime)
              : b.startTime.compareTo(a.startTime));
          break;
        case 'duration':
          _sessions.sort((a, b) => _ascending
              ? a.duration.compareTo(b.duration)
              : b.duration.compareTo(a.duration));
          break;
        case 'wpm':
          _sessions.sort((a, b) => _ascending
              ? a.wpm.compareTo(b.wpm)
              : b.wpm.compareTo(a.wpm));
          break;
      }
    });
  }

  Story? _getStoryForSession(ReadingSession session) {
    try {
      return _stories.firstWhere((s) => s.id == session.storyId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Okuma Geçmişi'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              if (value == _sortBy) {
                setState(() => _ascending = !_ascending);
              } else {
                setState(() {
                  _sortBy = value;
                  _ascending = false;
                });
              }
              _sortSessions();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: _sortBy == 'date' ? AppTheme.primaryColor : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tarihe Göre',
                      style: TextStyle(
                        color: _sortBy == 'date' ? AppTheme.primaryColor : null,
                        fontWeight: _sortBy == 'date' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'duration',
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: _sortBy == 'duration' ? AppTheme.primaryColor : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Süreye Göre',
                      style: TextStyle(
                        color: _sortBy == 'duration' ? AppTheme.primaryColor : null,
                        fontWeight: _sortBy == 'duration' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'wpm',
                child: Row(
                  children: [
                    Icon(
                      Icons.speed,
                      color: _sortBy == 'wpm' ? AppTheme.primaryColor : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Hıza Göre',
                      style: TextStyle(
                        color: _sortBy == 'wpm' ? AppTheme.primaryColor : null,
                        fontWeight: _sortBy == 'wpm' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _sessions.isEmpty
              ? _buildEmptyState()
              : _buildSessionList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz okuma geçmişi yok',
            style: AppTheme.headlineStyle.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk hikayeyi okumaya başlayın!',
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList() {
    return Column(
      children: [
        _buildSummaryHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _sessions.length,
            itemBuilder: (context, index) {
              final session = _sessions[index];
              final story = _getStoryForSession(session);
              return _buildSessionCard(session, story);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader() {
    final totalSessions = _sessions.length;
    final totalMinutes = _sessions
        .map((s) => s.duration.inMinutes)
        .fold(0, (a, b) => a + b);
    final avgWPM = _sessions.isEmpty
        ? 0.0
        : _sessions.map((s) => s.wpm).reduce((a, b) => a + b) / totalSessions;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            Icons.book_outlined,
            totalSessions.toString(),
            'Oturum',
          ),
          _buildSummaryItem(
            Icons.timer_outlined,
            totalMinutes.toString(),
            'Dakika',
          ),
          if (avgWPM > 0)
            _buildSummaryItem(
              Icons.speed,
              avgWPM.toStringAsFixed(0),
              'Ort. WPM',
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.headlineStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.captionStyle.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(ReadingSession session, Story? story) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'tr_TR');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _showSessionDetails(session, story),
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
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: story?.difficultyColor.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      story?.category ?? '',
                      style: AppTheme.captionStyle.copyWith(
                        color: story?.difficultyColor ?? Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
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
                    dateFormat.format(session.startTime),
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.timer_outlined,
                    session.formattedDuration,
                    AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  if (session.wpm > 0)
                    _buildInfoChip(
                      Icons.speed,
                      session.formattedWPM,
                      AppTheme.secondaryColor,
                    ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.check_circle_outline,
                    '${(session.completionRate * 100).toStringAsFixed(0)}%',
                    AppTheme.accentColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTheme.captionStyle.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showSessionDetails(ReadingSession session, Story? story) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                story?.title ?? 'Bilinmeyen Hikaye',
                style: AppTheme.headlineStyle,
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Başlangıç', DateFormat('HH:mm').format(session.startTime)),
              _buildDetailRow('Bitiş', session.endTime != null ? DateFormat('HH:mm').format(session.endTime!) : '-'),
              _buildDetailRow('Süre', session.formattedDuration),
              _buildDetailRow('Kelime Sayısı', session.wordCount.toString()),
              if (session.wpm > 0)
                _buildDetailRow('Okuma Hızı', session.formattedWPM),
              _buildDetailRow('Tamamlanma', '${(session.completionRate * 100).toStringAsFixed(0)}%'),
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
