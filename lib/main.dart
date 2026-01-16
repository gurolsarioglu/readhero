import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_routes.dart';
import 'controllers/controllers.dart';
import 'services/ai_all_in_one.dart';
import 'views/auth/splash_view.dart';
import 'views/auth/onboarding_view.dart';
import 'views/auth/register_view.dart';
import 'views/auth/login_view.dart';
import 'views/auth/verification_view.dart';
import 'views/student/add_student_view.dart';
import 'views/student/select_student_view.dart';
import 'views/student/library_view.dart';
import 'views/student/story_detail_view.dart';
import 'views/student/reading_view.dart';
import 'views/student/quiz_intro_view.dart';
import 'views/student/quiz_view.dart';
import 'views/student/quiz_result_view.dart';
import 'views/student/rewards_showcase_view.dart';
import 'views/student/ai_test_view.dart';
import 'views/parent/rewards_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // AI Servisini Başlat
  await AIService.instance.initialize();
  
  runApp(const ReadHeroApp());
}

class ReadHeroApp extends StatelessWidget {
  const ReadHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => StudentController()),
        ChangeNotifierProvider(create: (_) => AIController()),
        ChangeNotifierProvider(create: (_) => StoryController()),
        ChangeNotifierProvider(create: (_) => ReadingController()),
        ChangeNotifierProvider(create: (_) => QuizController()),
        ChangeNotifierProvider(create: (_) => RewardController()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashView(),
          AppRoutes.onboarding: (context) => const OnboardingView(),
          AppRoutes.register: (context) => const RegisterView(),
          AppRoutes.login: (context) => const LoginView(),
          AppRoutes.verification: (context) => const VerificationView(),
          AppRoutes.addStudent: (context) => const AddStudentView(),
          AppRoutes.selectStudent: (context) => const SelectStudentView(),
          AppRoutes.library: (context) => const LibraryView(),
          AppRoutes.storyDetail: (context) => const StoryDetailView(),
          AppRoutes.reading: (context) => const ReadingView(),
          AppRoutes.rewardsShowcase: (context) => const RewardsShowcaseView(),
          AppRoutes.rewardManagement: (context) => const RewardsView(),
          AppRoutes.aiTest: (context) => const AITestView(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.quizIntro) {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => QuizIntroView(
                storyId: args['storyId'] ?? '',
                storyTitle: args['storyTitle'] ?? '',
                sessionId: args['sessionId'] ?? '',
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
