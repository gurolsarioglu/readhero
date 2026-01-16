import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../models/goal.dart';
import '../../services/goal_service.dart';

class GoalsView extends StatefulWidget {
  final String studentId;

  const GoalsView({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  @override
  State<GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> with SingleTickerProviderStateMixin {
  final _goalService = GoalService.instance;
  late TabController _tabController;
  
  List<GoalModel> _dailyGoals = [];
  List<GoalModel> _weeklyGoals = [];
  List<GoalModel> _monthlyGoals = [];
  List<GoalModel> _completedGoals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadGoals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);

    try {
      final daily = await _goalService.getActiveGoalsByType(widget.studentId, GoalType.daily);
      final weekly = await _goalService.getActiveGoalsByType(widget.studentId, GoalType.weekly);
      final monthly = await _goalService.getActiveGoalsByType(widget.studentId, GoalType.monthly);
      final completed = await _goalService.getCompletedGoals(widget.studentId);

      setState(() {
        _dailyGoals = daily;
        _weeklyGoals = weekly;
        _monthlyGoals = monthly;
        _completedGoals = completed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Hedeflerim'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Günlük'),
            Tab(text: 'Haftalık'),
            Tab(text: 'Aylık'),
            Tab(text: 'Tamamlanan'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGoalsList(_dailyGoals, GoalType.daily),
                _buildGoalsList(_weeklyGoals, GoalType.weekly),
                _buildGoalsList(_monthlyGoals, GoalType.monthly),
                _buildCompletedGoalsList(),
              ],
            ),
    );
  }

  Widget _buildGoalsList(List<GoalModel> goals, GoalType type) {
    if (goals.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: _loadGoals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          return _buildGoalCard(goals[index]);
        },
      ),
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: goal.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    goal.icon,
                    color: goal.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.categoryName,
                        style: AppTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.description,
                        style: AppTheme.captionStyle,
                      ),
                    ],
                  ),
                ),
                if (goal.isAchieved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tamamlandı!',
                          style: AppTheme.captionStyle.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AnimatedProgressBar(
                    progress: goal.progress,
                    color: goal.color,
                    height: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${goal.progressPercentage}%',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: goal.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.currentValue} / ${goal.targetValue}',
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.stars_outlined,
                      size: 16,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${goal.rewardPoints} puan',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedGoalsList() {
    if (_completedGoals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: AppTheme.accentColor.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Henüz tamamlanan hedef yok',
              style: AppTheme.headlineStyle.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'İlk hedefini tamamla!',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedGoals.length,
      itemBuilder: (context, index) {
        final goal = _completedGoals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: goal.color.withOpacity(0.1),
              child: Icon(goal.icon, color: goal.color, size: 20),
            ),
            title: Text(
              goal.categoryName,
              style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(goal.description),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  '+${goal.rewardPoints}',
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(GoalType type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz ${type.name} hedef yok',
            style: AppTheme.headlineStyle.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Varsayılan Hedefleri Oluştur',
            onPressed: () => _createDefaultGoals(type),
          ),
        ],
      ),
    );
  }

  Future<void> _createDefaultGoals(GoalType type) async {
    try {
      switch (type) {
        case GoalType.daily:
          await _goalService.createDefaultDailyGoals(widget.studentId);
          break;
        case GoalType.weekly:
          await _goalService.createDefaultWeeklyGoals(widget.studentId);
          break;
        case GoalType.monthly:
          await _goalService.createDefaultMonthlyGoals(widget.studentId);
          break;
      }

      await _loadGoals();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hedefler oluşturuldu!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}
