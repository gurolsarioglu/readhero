import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../controllers/controllers.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import 'story_card_widget.dart';

/// Hikaye kütüphanesi ekranı
class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStories() async {
    final storyController = context.read<StoryController>();
    final studentController = context.read<StudentController>();
    
    // Hikayeleri yükle
    await storyController.loadStories();
    
    // Seçili öğrencinin sınıf seviyesine göre otomatik filtrele
    final selectedStudent = studentController.selectedStudent;
    if (selectedStudent != null) {
      storyController.setGradeFilter(selectedStudent.gradeLevel);
      debugPrint('✅ Hikayeler ${selectedStudent.gradeLevel}. sınıf için filtrelendi');
    }
  }

  void _onStoryTap(String storyId) {
    final storyController = context.read<StoryController>();
    storyController.selectStory(storyId);
    Navigator.of(context).pushNamed(AppRoutes.storyDetail);
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hikaye Kütüphanesi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Grid/List toggle
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          // Filter
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<StoryController>(
          builder: (context, storyController, child) {
            return Column(
              children: [
                // Arama çubuğu
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomTextField(
                    controller: _searchController,
                    label: 'Hikaye Ara',
                    hint: 'Başlık veya anahtar kelime...',
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      storyController.searchStories(value);
                    },
                    suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
                    onSuffixIconPressed: () {
                      _searchController.clear();
                      storyController.clearSearch();
                    },
                  ),
                ),

                // Aktif filtreler
                if (storyController.selectedGradeLevel != null ||
                    storyController.selectedCategory != null ||
                    storyController.selectedDifficulty != null ||
                    storyController.showOnlyOffline)
                  _buildActiveFilters(storyController),

                // Hikaye listesi
                Expanded(
                  child: storyController.isLoading
                      ? const Center(child: LoadingIndicator())
                      : storyController.hasFilteredStories
                          ? _buildStoryList(storyController)
                          : _buildEmptyState(storyController),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.generateStory);
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('AI ile Üret'),
      ),
    );
  }

  Widget _buildActiveFilters(StoryController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (controller.selectedGradeLevel != null)
            _buildFilterChip(
              '${controller.selectedGradeLevel}. Sınıf',
              () => controller.setGradeFilter(null),
            ),
          if (controller.selectedCategory != null)
            _buildFilterChip(
              controller.selectedCategory!,
              () => controller.setCategoryFilter(null),
            ),
          if (controller.selectedDifficulty != null)
            _buildFilterChip(
              controller.selectedDifficulty!.toUpperCase(),
              () => controller.setDifficultyFilter(null),
            ),
          if (controller.showOnlyOffline)
            _buildFilterChip(
              'Offline',
              () => controller.setOfflineFilter(false),
            ),
          // Tümünü temizle
          TextButton.icon(
            onPressed: () => controller.clearFilters(),
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Tümünü Temizle'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDelete,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStoryList(StoryController controller) {
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: controller.filteredStories.length,
        itemBuilder: (context, index) {
          final story = controller.filteredStories[index];
          return StoryCardWidget(
            story: story,
            onTap: () => _onStoryTap(story.id),
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredStories.length,
        itemBuilder: (context, index) {
          final story = controller.filteredStories[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              height: 200,
              child: StoryCardWidget(
                story: story,
                onTap: () => _onStoryTap(story.id),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildEmptyState(StoryController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              controller.searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.library_books_outlined,
              size: 80,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'Hikaye Bulunamadı'
                  : 'Henüz Hikaye Yok',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'Farklı bir arama deneyin'
                  : 'AI ile hikaye oluşturarak başlayın',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'AI ile Hikaye Üret',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.generateStory);
              },
              icon: Icons.auto_awesome,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSheet() {
    return Consumer<StoryController>(
      builder: (context, controller, child) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtreler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sınıf seviyesi
              const Text(
                'Sınıf Seviyesi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: List.generate(4, (index) {
                  final grade = index + 1;
                  final isSelected = controller.selectedGradeLevel == grade;
                  return ChoiceChip(
                    label: Text('$grade. Sınıf'),
                    selected: isSelected,
                    onSelected: (selected) {
                      controller.setGradeFilter(selected ? grade : null);
                    },
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Kategori
              const Text(
                'Kategori',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.categories.map((category) {
                  final isSelected = controller.selectedCategory == category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      controller.setCategoryFilter(selected ? category : null);
                    },
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Zorluk
              const Text(
                'Zorluk Seviyesi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: controller.difficulties.map((difficulty) {
                  final isSelected = controller.selectedDifficulty == difficulty;
                  return ChoiceChip(
                    label: Text(difficulty.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      controller.setDifficultyFilter(selected ? difficulty : null);
                    },
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Offline
              SwitchListTile(
                title: const Text('Sadece Offline Hikayeler'),
                value: controller.showOnlyOffline,
                onChanged: (value) {
                  controller.setOfflineFilter(value);
                },
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),

              // Uygula butonu
              CustomButton(
                text: 'Uygula',
                onPressed: () => Navigator.pop(context),
                width: double.infinity,
              ),
            ],
          ),
        );
      },
    );
  }
}
