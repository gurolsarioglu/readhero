import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// SQLite veritabanı yöneticisi
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Veritabanı instance'ını al
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('readhero.db');
    return _database!;
  }

  /// Veritabanını başlat
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Tabloları oluştur
  Future<void> _createDB(Database db, int version) async {
    // Users tablosu
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        phone TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        name TEXT NOT NULL,
        is_verified INTEGER DEFAULT 0,
        email_verified INTEGER DEFAULT 0,
        phone_verified INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_users_phone ON users(phone)');

    // Students tablosu
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        grade_level INTEGER NOT NULL CHECK(grade_level BETWEEN 1 AND 4),
        avatar TEXT DEFAULT 'default',
        current_points INTEGER DEFAULT 0,
        total_points INTEGER DEFAULT 0,
        badges TEXT DEFAULT '[]',
        daily_goal INTEGER DEFAULT 20,
        weekly_goal INTEGER DEFAULT 5,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_students_user ON students(user_id)');
    await db.execute('CREATE INDEX idx_students_grade ON students(grade_level)');

    // Stories tablosu
    await db.execute('''
      CREATE TABLE stories (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        grade_level INTEGER NOT NULL CHECK(grade_level BETWEEN 1 AND 4),
        word_count INTEGER NOT NULL,
        difficulty TEXT CHECK(difficulty IN ('easy', 'medium', 'hard')),
        keywords TEXT DEFAULT '[]',
        moral_lesson TEXT,
        is_offline INTEGER DEFAULT 0,
        is_ai_generated INTEGER DEFAULT 0,
        source TEXT DEFAULT 'builtin',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_stories_grade ON stories(grade_level)');
    await db.execute('CREATE INDEX idx_stories_category ON stories(category)');

    // Reading Sessions tablosu
    await db.execute('''
      CREATE TABLE reading_sessions (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        story_id TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        duration INTEGER,
        word_count INTEGER NOT NULL,
        wpm REAL,
        completion_rate REAL DEFAULT 100.0,
        audio_path TEXT,
        is_completed INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY (story_id) REFERENCES stories(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_sessions_student ON reading_sessions(student_id)');
    await db.execute('CREATE INDEX idx_sessions_story ON reading_sessions(story_id)');
    await db.execute('CREATE INDEX idx_sessions_date ON reading_sessions(start_time)');

    // Quizzes tablosu
    await db.execute('''
      CREATE TABLE quizzes (
        id TEXT PRIMARY KEY,
        story_id TEXT NOT NULL,
        questions TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (story_id) REFERENCES stories(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_quizzes_story ON quizzes(story_id)');

    // Quiz Results tablosu
    await db.execute('''
      CREATE TABLE quiz_results (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        session_id TEXT NOT NULL,
        quiz_id TEXT NOT NULL,
        answers TEXT NOT NULL,
        correct_count INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        score REAL NOT NULL,
        time_spent INTEGER,
        points_earned INTEGER DEFAULT 0,
        completed_at INTEGER NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY (session_id) REFERENCES reading_sessions(id) ON DELETE CASCADE,
        FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_quiz_results_student ON quiz_results(student_id)');
    await db.execute('CREATE INDEX idx_quiz_results_date ON quiz_results(completed_at)');

    // Rewards tablosu
    await db.execute('''
      CREATE TABLE rewards (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        required_points INTEGER NOT NULL,
        is_unlocked INTEGER DEFAULT 0,
        unlocked_at INTEGER,
        is_claimed INTEGER DEFAULT 0,
        claimed_at INTEGER,
        created_by TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');

    await db.execute('CREATE INDEX idx_rewards_student ON rewards(student_id)');

    // Progress tablosu
    await db.execute('''
      CREATE TABLE progress (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        date INTEGER NOT NULL,
        daily_reading_time INTEGER DEFAULT 0,
        daily_books_completed INTEGER DEFAULT 0,
        daily_points_earned INTEGER DEFAULT 0,
        daily_goal_achieved INTEGER DEFAULT 0,
        weekly_books_completed INTEGER DEFAULT 0,
        weekly_goal_achieved INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
        UNIQUE(student_id, date)
      )
    ''');

    await db.execute('CREATE INDEX idx_progress_student ON progress(student_id)');
    await db.execute('CREATE INDEX idx_progress_date ON progress(date)');

    // Goals tablosu
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        type INTEGER NOT NULL,
        category INTEGER NOT NULL,
        target_value INTEGER NOT NULL,
        current_value INTEGER DEFAULT 0,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        is_completed INTEGER DEFAULT 0,
        completed_at INTEGER,
        reward_points INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_goals_student ON goals(student_id)');
    await db.execute('CREATE INDEX idx_goals_type ON goals(type)');
    await db.execute('CREATE INDEX idx_goals_category ON goals(category)');

    // Audio Recordings tablosu (1. sınıf için ses kayıtları)
    await db.execute('''
      CREATE TABLE audio_recordings (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        story_id TEXT NOT NULL,
        file_path TEXT NOT NULL,
        duration INTEGER NOT NULL,
        recorded_at INTEGER NOT NULL,
        file_size INTEGER DEFAULT 0,
        story_title TEXT,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY (story_id) REFERENCES stories(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_audio_student ON audio_recordings(student_id)');
    await db.execute('CREATE INDEX idx_audio_story ON audio_recordings(story_id)');
    await db.execute('CREATE INDEX idx_audio_date ON audio_recordings(recorded_at)');

    // Difficult Words tablosu (zorlanılan kelimeler)
    await db.execute('''
      CREATE TABLE difficult_words (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        story_id TEXT NOT NULL,
        word TEXT NOT NULL,
        meaning TEXT,
        example_sentence TEXT,
        marked_at INTEGER NOT NULL,
        review_count INTEGER DEFAULT 0,
        is_learned INTEGER DEFAULT 0,
        learned_at INTEGER,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY (story_id) REFERENCES stories(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_words_student ON difficult_words(student_id)');
    await db.execute('CREATE INDEX idx_words_story ON difficult_words(story_id)');
    await db.execute('CREATE INDEX idx_words_learned ON difficult_words(is_learned)');
    
    // ✅ DEMO HİKAYELER EKLE (Hemen test için hazır içerik)
    debugPrint('📚 Demo hikayeler yükleniyor...');
    await _insertDemoStories(db);
    debugPrint('✅ Demo hikayeler yüklendi!');
  }
  
  /// Demo hikayeleri veritabanına ekle
  Future<void> _insertDemoStories(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // 1. Sınıf Hikayeleri
    await db.insert('stories', {
      'id': 'demo_story_1',
      'title': 'Cesur Tavşan',
      'content': '''Orman'da Pamuk adında küçük bir tavşan varmış. Pamuk çok korkak bir tavşanmış. Her şeyden korkarmış.

Bir gün ormanda yangın çıkmış. Tüm hayvanlar korkmuş. Kimse ne yapacağını bilememiş.

Pamuk nehri görmüş. "Hemen nehirden su taşıyalım!" demiş. Tüm hayvanlar Pamuk'u dinlemiş.

Hep birlikte su taşımışlar. Yangını söndürmüşler. Ormanı kurtarmışlar.

Hayvanlar Pamuk'a çok teşekkür etmiş. "Sen çok cesaretlisin!" demişler.

Pamuk artık kendine güveniyormuş. Korkularını yenmiş.''',
      'category': 'Hayvanlar',
      'grade_level': 1,
      'word_count': 76,
      'difficulty': 'easy',
      'keywords': '["cesaret","hayvanlar","orman","dostluk"]',
      'moral_lesson': 'Korkularımızı yenebiliriz.',
      'is_offline': 1,
      'is_ai_generated': 0,
      'source': 'builtin',
      'created_at': now,
      'updated_at': now,
    });
    
    await db.insert('stories', {
      'id': 'demo_story_2',
      'title': 'Büyülü Bahçe',
      'content': '''Ali okula giderken garip bir bahçe görmüş. Bahçenin kapısı açıkmış.

İçeri girmiş. Çiçekler konuşuyormuş! "Hoş geldin Ali!" demişler.

Bir gül Ali'ye şaka yapmış. Suyla onu ıslatmış. Ali gülmüş.

Papatyalar dans etmiş. Laleler şarkı söylemiş. Ali çok eğlenmiş.

Eve gitme zamanı gelmiş. Çiçekler üzülmüş. "Yarın gel!" demişler.

Ali her gün o bahçeye gitmeye başlamış. Çiçekler onun en iyi arkadaşları olmuş.''',
      'category': 'Macera',
      'grade_level': 1,
      'word_count': 68,
      'difficulty': 'easy',
      'keywords': '["macera","arkadaşlık","hayal gücü"]',
      'moral_lesson': 'Hayal kurmak güzeldir.',
      'is_offline': 1,
      'is_ai_generated': 0,
      'source': 'builtin',
      'created_at': now,
      'updated_at': now,
    });
    
    // 2. Sınıf Hikayeleri
    await db.insert('stories', {
      'id': 'demo_story_3',
      'title': 'Küçük Kedi Minnos',
      'content': '''Bir zamanlar Minnos adında küçük bir kedi varmış. Minnos çok oyuncu bir kediymiş. Her şeyle oynarmış.

Bir gün yün yumağı bulmuş. Yumağı patisine dolamış. Yuvarlanmaya başlamış. Tüm evi karıştırmış!

Ann

esi eve gelmiş. Evi görmüş. "Minnos ne yaptın?" demiş. Minnos çok utanmış.

"Kusura bakma anne" demiş. "Toplamama yardım eder misin?"

Birlikte evi toplamışlar. Her şeyi yerine koymuşlar. Ev tertemiz olmuş.

Annesi Minnos'u öpmüş. "Hatanı kabul edip düzelttin. Aferin sana!" demiş.

Minnos artık daha dikkatli oynamaya başlamış.''',
      'category': 'Hayvanlar',
      'grade_level': 2,
      'word_count': 98,
      'difficulty': 'easy',
      'keywords': '["sorumluluk","hayvanlar","aile","özür"]',
      'moral_lesson': 'Hatalarımızı kabul etmeliyiz.',
      'is_offline': 1,
      'is_ai_generated': 0,
      'source': 'builtin',
      'created_at': now,
      'updated_at': now,
    });
    
    // 3. Sınıf Hikayesi  
    await db.insert('stories', {
      'id': 'demo_story_4',
      'title': 'Orman Koruyucuları',
      'content': '''Elif ve arkadaşları pikniğe gitmişlerdi. Ormanda güzel vakit geçiriyorlardı. Ama bir şey fark ettiler - her yerde çöp vardı!

Plastik şişeler, poşetler, kağıtlar... Orman kirli görünüyordu. Hayvanlar da rahatsız görünüyordu.

Elif "Biz bu ormanı temizlemeliyiz!" dedi. Arkadaşları da katıldı. Eldiven giydiler, çöp poşetleri aldılar.

Saatlerce çalıştılar. Bütün çöpleri topladılar. Geri dönüşüm için ayırdılar. Orman yeniden güzelleşti.

Bir sincap geldi. "Teşekkür ederiz!" dedi. Kuşlar şarkı söyledi. Tavşanlar zıplayarak sevinç gösterisi yaptı.

Çocuklar çok mutlu oldu. Evlerine dönerken, "Her hafta gelip ormanı kontrol edelim" diye karar verdiler.

Elif ve arkadaşları Orman Koruyucuları kulübünü kurdular. Artık doğayı korumak için çalışıyorlardı.''',
      'category': 'Doğa',
      'grade_level': 3,
      'word_count': 129,
      'difficulty': 'medium',
      'keywords': '["doğa","çevre","sorumluluk","takım çalışması"]',
      'moral_lesson': 'Doğayı korumak hepimizin görevidir.',
      'is_offline': 1,
      'is_ai_generated': 0,
      'source': 'builtin',
      'created_at': now,
      'updated_at': now,
    });
  }

  /// Veritabanı upgrade
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Migration işlemleri buraya eklenecek
    if (oldVersion < newVersion) {
      // Örnek: Yeni sütun ekleme
      // await db.execute('ALTER TABLE users ADD COLUMN new_column TEXT');
    }
  }

  /// Veritabanını kapat
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }

  /// Veritabanını sıfırla (test için)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'readhero.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // ==================== CRUD İŞLEMLERİ ====================

  /// Generic Create
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  /// Generic Read (Single)
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Generic Read (All)
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  /// Generic Update
  Future<int> update(String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Generic Delete
  Future<int> delete(String table, String id) async {
    final db = await database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Custom Query
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Raw Query
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // ==================== QUIZ İŞLEMLERİ ====================

  /// Quiz ekle
  Future<void> insertQuiz(QuizModel quiz) async {
    final db = await database;
    await db.insert('quizzes', quiz.toMap());
  }

  /// Hikaye ID'sine göre quiz getir
  Future<QuizModel?> getQuizByStoryId(String storyId) async {
    final db = await database;
    final results = await db.query(
      'quizzes',
      where: 'story_id = ?',
      whereArgs: [storyId],
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    return QuizModel.fromMap(results.first);
  }

  /// Quiz sonucu ekle
  Future<void> insertQuizResult(QuizResultModel result) async {
    final db = await database;
    await db.insert('quiz_results', result.toMap());
  }

  /// Öğrenciye göre quiz sonuçlarını getir
  Future<List<QuizResultModel>> getQuizResultsByStudent(String studentId) async {
    final db = await database;
    final results = await db.query(
      'quiz_results',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'completed_at DESC',
    );
    
    return results.map((map) => QuizResultModel.fromMap(map)).toList();
  }

  /// Hikayeye göre quiz sonuçlarını getir
  Future<List<QuizResultModel>> getQuizResultsByStory(String storyId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT qr.* FROM quiz_results qr
      INNER JOIN quizzes q ON qr.quiz_id = q.id
      WHERE q.story_id = ?
      ORDER BY qr.completed_at DESC
    ''', [storyId]);
    
    return results.map((map) => QuizResultModel.fromMap(map)).toList();
  }

  /// Quiz ID'sine göre quiz getir
  Future<QuizModel?> getQuizById(String quizId) async {
    final db = await database;
    final results = await db.query(
      'quizzes',
      where: 'id = ?',
      whereArgs: [quizId],
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    return QuizModel.fromMap(results.first);
  }

  // ==================== STORY İŞLEMLERİ ====================

  /// Hikaye ekle
  Future<void> insertStory(StoryModel story) async {
    final db = await database;
    await db.insert('stories', story.toMap());
  }

  /// Hikaye ID'sine göre hikaye getir
  Future<StoryModel?> getStoryById(String storyId) async {
    final db = await database;
    final results = await db.query(
      'stories',
      where: 'id = ?',
      whereArgs: [storyId],
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    return StoryModel.fromMap(results.first);
  }

  /// Sınıf seviyesine göre hikayeleri getir
  Future<List<StoryModel>> getStoriesByGrade(int gradeLevel) async {
    final db = await database;
    final results = await db.query(
      'stories',
      where: 'grade_level = ?',
      whereArgs: [gradeLevel],
      orderBy: 'created_at DESC',
    );
    
    return results.map((map) => StoryModel.fromMap(map)).toList();
  }

  /// Kategoriye göre hikayeleri getir
  Future<List<StoryModel>> getStoriesByCategory(String category) async {
    final db = await database;
    final results = await db.query(
      'stories',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    
    return results.map((map) => StoryModel.fromMap(map)).toList();
  }

  /// Hikaye güncelle
  Future<void> updateStory(String storyId, Map<String, dynamic> data) async {
    final db = await database;
    await db.update(
      'stories',
      data,
      where: 'id = ?',
      whereArgs: [storyId],
    );
  }

  // ==================== READING SESSION İŞLEMLERİ ====================

  /// Okuma oturumu ekle
  Future<void> insertReadingSession(ReadingSessionModel session) async {
    final db = await database;
    await db.insert('reading_sessions', session.toMap());
  }

  /// Öğrenciye göre okuma oturumlarını getir
  Future<List<ReadingSessionModel>> getReadingSessionsByStudent(String studentId) async {
    final db = await database;
    final results = await db.query(
      'reading_sessions',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'start_time DESC',
    );
    
    return results.map((map) => ReadingSessionModel.fromMap(map)).toList();
  }

  /// Hikayeye göre okuma oturumlarını getir
  Future<List<ReadingSessionModel>> getReadingSessionsByStory(String storyId) async {
    final db = await database;
    final results = await db.query(
      'reading_sessions',
      where: 'story_id = ?',
      whereArgs: [storyId],
      orderBy: 'start_time DESC',
    );
    
    return results.map((map) => ReadingSessionModel.fromMap(map)).toList();
  }

  /// Okuma oturumu güncelle
  Future<void> updateReadingSession(String sessionId, Map<String, dynamic> data) async {
    final db = await database;
    await db.update(
      'reading_sessions',
      data,
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // ==================== STUDENT İŞLEMLERİ ====================

  /// Öğrenci ekle
  Future<void> insertStudent(StudentModel student) async {
    final db = await database;
    await db.insert('students', student.toMap());
  }

  /// Öğrenci ID'sine göre öğrenci getir
  Future<StudentModel?> getStudentById(String studentId) async {
    final db = await database;
    final results = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [studentId],
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    return StudentModel.fromMap(results.first);
  }

  /// Kullanıcıya göre öğrencileri getir
  Future<List<StudentModel>> getStudentsByUser(String userId) async {
    final db = await database;
    final results = await db.query(
      'students',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );
    
    return results.map((map) => StudentModel.fromMap(map)).toList();
  }

  /// Öğrenci güncelle
  Future<void> updateStudent(String studentId, Map<String, dynamic> data) async {
    final db = await database;
    await db.update(
      'students',
      data,
      where: 'id = ?',
      whereArgs: [studentId],
    );
  }

  /// Öğrenci sil
  Future<void> deleteStudent(String studentId) async {
    final db = await database;
    await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [studentId],
    );
  }

  // ==================== GOAL İŞLEMLERİ ====================

  /// Hedef ekle
  Future<void> insertGoal(Map<String, dynamic> goal) async {
    final db = await database;
    await db.insert('goals', goal);
  }

  /// Hedef güncelle
  Future<void> updateGoal(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('goals', data, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== AUDIO RECORDING İŞLEMLERİ ====================

  /// Ses kaydı ekle
  Future<void> insertAudioRecording(Map<String, dynamic> recording) async {
    final db = await database;
    await db.insert('audio_recordings', recording);
  }

  /// Öğrenciye göre ses kayıtlarını getir
  Future<List<Map<String, dynamic>>> getAudioRecordingsByStudent(String studentId) async {
    final db = await database;
    return await db.query(
      'audio_recordings',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'recorded_at DESC',
    );
  }

  // ==================== DIFFICULT WORDS İŞLEMLERİ ====================

  /// Zor kelime ekle
  Future<void> insertDifficultWord(Map<String, dynamic> word) async {
    final db = await database;
    await db.insert('difficult_words', word);
  }

  /// Öğrenciye göre zor kelimeleri getir
  Future<List<Map<String, dynamic>>> getDifficultWordsByStudent(String studentId) async {
    final db = await database;
    return await db.query(
      'difficult_words',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'marked_at DESC',
    );
  }
}

