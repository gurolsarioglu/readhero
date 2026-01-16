/// Uygulama route sabitleri
class AppRoutes {
  // Auth Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verification = '/verification';

  // Student Routes
  static const String selectStudent = '/select-student';
  static const String addStudent = '/add-student';
  static const String studentHome = '/student-home';
  static const String library = '/library';
  static const String storyDetail = '/story-detail';
  static const String reading = '/reading';
  static const String quizIntro = '/quiz-intro';
  static const String quiz = '/quiz';
  static const String quizResult = '/quiz-result';
  static const String rewards = '/rewards';
  static const String rewardsShowcase = '/rewards-showcase';


  // Parent Routes
  static const String parentDashboard = '/parent-dashboard';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String studentManagement = '/student-management';
  static const String rewardManagement = '/reward-management';

  // AI & Test Routes
  static const String aiTest = '/ai-test';
  static const String generateStory = '/generate-story';

  // Utility Routes
  static const String eyeBreak = '/eye-break';
  static const String profile = '/profile';
}
