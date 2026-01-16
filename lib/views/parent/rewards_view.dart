import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/reward_controller.dart';
import '../../controllers/student_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';

/// Rewards View (Parent) - Veli için ödül yönetim ekranı
/// 
/// Özellikler:
/// - Ödül ekleme/düzenleme/silme
/// - Ödül listesi
/// - Öğrenci seçimi
class RewardsView extends StatefulWidget {
  const RewardsView({Key? key}) : super(key: key);

  @override
  State<RewardsView> createState() => _RewardsViewState();
}

class _RewardsViewState extends State<RewardsView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
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
        title: const Text('Ödül Yönetimi'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer2<StudentController, RewardController>(
        builder: (context, studentController, rewardController, child) {
          if (studentController.selectedStudent == null) {
            return const Center(
              child: Text('Lütfen bir öğrenci seçin'),
            );
          }

          if (rewardController.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          return Column(
            children: [
              // Student Info Card
              _buildStudentInfoCard(studentController),
              
              // Rewards List
              Expanded(
                child: rewardController.rewards.isEmpty
                    ? _buildEmptyState()
                    : _buildRewardsList(rewardController),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRewardDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Ödül Ekle'),
      ),
    );
  }

  Widget _buildStudentInfoCard(StudentController studentController) {
    final student = studentController.selectedStudent!;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                student.avatar,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${student.gradeLevel}. Sınıf',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Points
          Column(
            children: [
              const Text(
                'Mevcut Puan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              Text(
                '${student.currentPoints}',
                style: const TextStyle(
                  fontSize: 24,
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
            Icons.card_giftcard,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz ödül eklenmemiş',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Çocuğunuzu motive etmek için ödül ekleyin',
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

  Widget _buildRewardsList(RewardController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.rewards.length,
      itemBuilder: (context, index) {
        final reward = controller.rewards[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: reward.isUnlocked
                    ? AppColors.secondary.withOpacity(0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
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
                size: 28,
              ),
            ),
            title: Text(
              reward.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(reward.description ?? ''),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reward.requiredPoints} puan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (reward.isClaimed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Kullanıldı',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else if (reward.isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Açıldı',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Düzenle'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Sil', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditRewardDialog(reward);
                } else if (value == 'delete') {
                  _deleteReward(reward.id);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddRewardDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _pointsController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Ödül Ekle'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Ödül Başlığı',
                    hintText: 'Örn: Oyun Oynama Hakkı',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir başlık girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    hintText: '30 dakika oyun oynayabilir',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir açıklama girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pointsController,
                  decoration: const InputDecoration(
                    labelText: 'Gerekli Puan',
                    hintText: '100',
                    prefixIcon: Icon(Icons.stars),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen puan girin';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => _addReward(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showEditRewardDialog(reward) {
    _titleController.text = reward.title;
    _descriptionController.text = reward.description;
    _pointsController.text = reward.requiredPoints.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödülü Düzenle'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Ödül Başlığı',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir başlık girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir açıklama girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pointsController,
                  decoration: const InputDecoration(
                    labelText: 'Gerekli Puan',
                    prefixIcon: Icon(Icons.stars),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen puan girin';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => _updateReward(context, reward.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  Future<void> _addReward(BuildContext dialogContext) async {
    if (!_formKey.currentState!.validate()) return;

    final studentController = context.read<StudentController>();
    final rewardController = context.read<RewardController>();
    final student = studentController.selectedStudent!;

    final success = await rewardController.addReward(
      studentId: student.id,
      title: _titleController.text,
      description: _descriptionController.text,
      requiredPoints: int.parse(_pointsController.text),
      createdBy: student.userId,
    );

    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ödül başarıyla eklendi'),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  Future<void> _updateReward(BuildContext dialogContext, String rewardId) async {
    if (!_formKey.currentState!.validate()) return;

    final studentController = context.read<StudentController>();
    final rewardController = context.read<RewardController>();
    final student = studentController.selectedStudent!;

    final success = await rewardController.updateReward(
      rewardId: rewardId,
      studentId: student.id,
      title: _titleController.text,
      description: _descriptionController.text,
      requiredPoints: int.parse(_pointsController.text),
    );

    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ödül başarıyla güncellendi'),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  Future<void> _deleteReward(String rewardId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödülü Sil'),
        content: const Text('Bu ödülü silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final studentController = context.read<StudentController>();
    final rewardController = context.read<RewardController>();
    final student = studentController.selectedStudent!;

    final success = await rewardController.deleteReward(rewardId, student.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ödül silindi'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
