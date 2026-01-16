// Tüm modelleri export eden barrel dosyası
export 'user_model.dart';
export 'student_model.dart';
export 'story_model.dart';
export 'reading_session_model.dart';
export 'quiz_model.dart';
export 'quiz_result_model.dart';
export 'reward_model.dart';
export 'progress_model.dart';
export 'goal.dart';
export 'audio_recording.dart';
export 'difficult_word.dart';

// Model alias'ları - kodda kısa isimler kullanılabilir
import 'story_model.dart';
import 'student_model.dart';
import 'reading_session_model.dart';
import 'quiz_result_model.dart';

typedef Story = StoryModel;
typedef Student = StudentModel;
typedef ReadingSession = ReadingSessionModel;
typedef QuizResult = QuizResultModel;
