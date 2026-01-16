import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/reward_controller.dart';
import '../../controllers/student_controller.dart';
import '../../services/points_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';

/// Rewards Showcase View (Student) - Öğrenci için ödül vitrini
/// 
/// Özellikler:
/// - Tüm ödülleri görüntüleme
/// - Kilitli/Açık durumu
/// - İlerleme çubuğu
/// - Ödül talep etme
class RewardsShowcaseView extends StatefulWidget {
  const RewardsShowcaseView({Key? key}) : super(key: key);

  @override
  State<RewardsShowcaseView> createState() => _RewardsShowcaseViewState();
}

class _RewardsShowcaseViewState extends State<RewardsShowcaseView> {
  final PointsService _pointsService = PointsService();

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  void _loadRewards() {
    final studentController = context.read<StudentController>();
    final rewardController = context.read<RewardController>();
    
    if (studentController.selectedStudent != null) {
      rewardController.loadRewards(studentController.selectedStudent!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödüllerim'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer2<StudentController, RewardController>(
        builder: (context, studentController, rewardController, child) {
          if (studentController.selectedStudent == null) {
            return const Center(
              child: Text('Öğrenci bilgisi bulunamadı'),
            );
          }

          if (rewardController.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          final student = studentController.selectedStudent!;

          return Column(
            children: [
              // Points Card
              _buildPointsCard(student),
              
              // Rewards Grid
              Expanded(
                child: rewardController.rewards.isEmpty
                    ? _buildEmptyState()
                    : _buildRewardsGrid(rewardController, student),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPointsCard(student) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accent.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars,
              size: 40,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mevcut Puanın',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${student.currentPoints}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Text(
                'Toplam',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              Text(
                '${student.totalPoints}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz ödül yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ailenle konuş, ödüller eklesinler!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsGrid(RewardController controller, student) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.rewards.length,
      itemBuilder: (context, index) {
        final reward = controller.rewards[index];
        final progress = student.currentPoints / reward.requiredPoints;
        final canUnlock = student.currentPoints >= reward.requiredPoints && !reward.isUnlocked;
        
        return GestureDetector(
          onTap: () => _showRewardDetail(reward, student, canUnlock),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: reward.isClaimed
                    ? AppColors.secondary
                    : reward.isUnlocked
                        ? AppColors.primary
                        : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Icon
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: reward.isClaimed
                          ? AppColors.secondary.withOpacity(0.1)
                          : reward.isUnlocked
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            reward.isClaimed
                                ? Icons.check_circle
                                : reward.isUnlocked
                                    ? Icons.card_giftcard
                                    : Icons.lock,
                            size: 60,
                            color: reward.isClaimed
                                ? AppColors.secondary
                                : reward.isUnlocked
                                    ? AppColors.primary
                                    : Colors.grey[400],
                          ),
                        ),
                        // Badge
                        if (canUnlock)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'YENİ!',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Info
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.stars,
                            size: 14,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${reward.requiredPoints}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress Bar
                      if (!reward.isClaimed)
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  reward.isUnlocked
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                ),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(progress * 100).clamp(0, 100).round()}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Kullanıldı ✓',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRewardDetail(reward, student, bool canUnlock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              reward.isClaimed
                  ? Icons.check_circle
                  : reward.isUnlocked
                      ? Icons.card_giftcard
                      : Icons.lock,
              color: reward.isClaimed
                  ? AppColors.secondary
                  : reward.isUnlocked
                      ? AppColors.primary
                      : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                reward.title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reward.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.stars, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  '${reward.requiredPoints} puan gerekli',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Mevcut puanın: ${student.currentPoints}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (canUnlock) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.celebration, color: AppColors.accent),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Tebrikler! Bu ödülü açabilirsin!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          if (canUnlock)
            ElevatedButton(
              onPressed: () => _unlockReward(context, reward, student),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Kilidi Aç'),
            )
          else if (reward.isUnlocked && !reward.isClaimed)
            ElevatedButton(
              onPressed: () => _claimReward(context, reward, student),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: const Text('Kullan'),
            ),
        ],
      ),
    );
  }

  Future<void> _unlockReward(BuildContext dialogContext, reward, student) async {
    final rewardController = context.read<RewardController>();
    
    final success = await rewardController.unlockReward(reward.id, student.id);
    
    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
    }
    
    if (success && mounted) {
      _showCelebrationDialog(reward);
    }
  }

  Future<void> _claimReward(BuildContext dialogContext, reward, student) async {
    final confirmed = await showDialog<bool>(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: const Text('Ödülü Kullan'),
        content: Text(
          '${reward.requiredPoints} puan harcayarak bu ödülü kullanmak istiyor musun?\n\nAilenle konuş ve onay al!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('Kullan'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    final rewardController = context.read<RewardController>();
    final success = await rewardController.claimReward(reward.id, student.id);
    
    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
    }
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 ${reward.title} kullanıldı!'),
          backgroundColor: AppColors.secondary,
        ),
      );
      
      // Reload student to update points
      context.read<StudentController>().loadStudents(student.userId);
    }
  }

  void _showCelebrationDialog(reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tebrikler!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${reward.title} ödülünü açtın!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              reward.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text('Harika!'),
          ),
        ],
      ),
    );
  }
}
