import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readhero/controllers/controllers.dart';
import 'package:readhero/core/theme/app_theme.dart';
import 'package:readhero/core/widgets/widgets.dart';
import 'package:readhero/services/ai_all_in_one.dart';

class GenerateStoryView extends StatefulWidget {
  const GenerateStoryView({super.key});

  @override
  State<GenerateStoryView> createState() => _GenerateStoryViewState();
}

class _GenerateStoryViewState extends State<GenerateStoryView> {
  int _selectedGrade = 1;
  String _selectedCategory = StoryGenerator.categories[0];
  String _selectedDifficulty = 'orta'; // Türkçe UI için
  final TextEditingController _themeController = TextEditingController();

  // Zorluk seviyesi mapping (Türkçe -> İngilizce)
  final Map<String, String> _difficultyMap = {
    'kolay': 'easy',
    'orta': 'medium',
    'zor': 'hard',
  };

  // UI'da gösterilecek Türkçe zorluk seviyeleri
  final List<String> _difficultyLabels = ['kolay', 'orta', 'zor'];

  @override
  void initState() {
    super.initState();
    // Seçili öğrencinin sınıfını varsayılan yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final student = context.read<StudentController>().selectedStudent;
      if (student != null) {
        setState(() {
          _selectedGrade = student.gradeLevel;
        });
      }
    });
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final aiController = context.read<AIController>();
    final storyController = context.read<StoryController>();

    try {
      // Türkçe zorluk seviyesini İngilizce'ye çevir
      final englishDifficulty = _difficultyMap[_selectedDifficulty] ?? 'medium';
      
      await aiController.generateFullContent(
        gradeLevel: _selectedGrade,
        category: _selectedCategory,
        difficulty: englishDifficulty, // İngilizce zorluk kullan
        theme: _themeController.text.isNotEmpty ? _themeController.text : null,
        storyController: storyController,
      );

      if (mounted && aiController.generatedStory != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Hikaye ve Sınav Başarıyla Oluşturuldu!')),
        );
        Navigator.pop(context); // Kütüphaneye dön
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Hikaye Laboratuvarı'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Consumer<AIController>(
        builder: (context, aiController, child) {
          if (aiController.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingIndicator(),
                  const SizedBox(height: 20),
                  const Text(
                    '🤖 Gemini Hikayeyi Yazıyor...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text('Bu işlem yaklaşık 15-20 saniye sürebilir.'),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: LinearProgressIndicator(
                      color: AppTheme.secondaryColor,
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nasıl bir hikaye istersin?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yapay zeka senin için harika bir hikaye ve sınav hazırlayacak.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Sınıf Seçimi
                const Text('Sınıf Seviyesi', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) {
                    final grade = index + 1;
                    final isSelected = _selectedGrade == grade;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedGrade = grade),
                      child: Container(
                        width: 70,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$grade',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Kategori Seçimi
                const Text('Hangi Konuda Olsun?', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: StoryGenerator.categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
                const SizedBox(height: 24),

                // Tema / Özel İstek
                const Text('Özel Bir Tema İster Misin? (Opsiyonel)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _themeController,
                  hint: 'Örn: Uzayda geçen bir futbol maçı, Konuşan kediler...',
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                // Zorluk
                const Text('Zorluk Seviyesi', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: _difficultyLabels.map((diff) {
                    final isSelected = _selectedDifficulty == diff;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(diff.toUpperCase(), style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _selectedDifficulty = diff),
                          selectedColor: AppTheme.secondaryColor,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),

                CustomButton(
                  text: '🤖 Hikayeyi Oluştur',
                  onPressed: _generate,
                  width: double.infinity,
                  height: 60,
                  fontSize: 18,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
