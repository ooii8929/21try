import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/isar_models.dart';

class IsarService {
  static Isar? _isar;
  static bool _isInitialized = false;
  static const Uuid _uuid = Uuid();

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [GoalSchema, RecordSchema],
      directory: dir.path,
      name: 'twenty_one_try_db',
    );
    _isInitialized = true;

    // 初始化預設數據
    await _initializeDefaultData();
  }

  static Future<void> _initializeDefaultData() async {
    final existingGoals = await getAllGoals();
    if (existingGoals.isEmpty) {
      // 添加預設 goals
      final defaultGoals = [
        Goal()
          ..uuid = _uuid.v4()
          ..title = 'Learn to play the guitar'
          ..createdAt = DateTime.now(),
        Goal()
          ..uuid = _uuid.v4()
          ..title = 'Practice mindfulness'
          ..createdAt = DateTime.now(),
        Goal()
          ..uuid = _uuid.v4()
          ..title = 'Improve public speaking'
          ..createdAt = DateTime.now(),
      ];

      for (final goal in defaultGoals) {
        await saveGoal(goal);
      }
    }
  }

  static Isar get isar {
    if (!_isInitialized || _isar == null) {
      throw Exception('Isar not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  // Goal operations
  static Future<List<Goal>> getAllGoals() async {
    return await isar.goals.where().findAll();
  }

  static Future<Goal?> getGoalById(int id) async {
    return await isar.goals.get(id);
  }

  static Future<int> saveGoal(Goal goal) async {
    // 確保 uuid 被初始化
    try {
      goal.uuid; // 嘗試訪問，如果沒有初始化會拋出錯誤
    } catch (e) {
      goal.uuid = _uuid.v4();
    }

    return await isar.writeTxn(() async {
      return await isar.goals.put(goal);
    });
  }

  static Future<bool> deleteGoal(int id) async {
    return await isar.writeTxn(() async {
      return await isar.goals.delete(id);
    });
  }

  // Record operations
  static Future<List<Record>> getAllRecords() async {
    return await isar.records.where().findAll();
  }

  static Future<Record?> getRecordById(int id) async {
    return await isar.records.get(id);
  }

  static Future<List<Record>> getRecordsByGoalId(int goalId) async {
    final goal = await isar.goals.get(goalId);
    if (goal == null) return [];

    await goal.records.load();
    return goal.records.toList();
  }

  static Future<int> saveRecord(Record record) async {
    // 確保 uuid 被初始化
    try {
      record.uuid; // 嘗試訪問，如果沒有初始化會拋出錯誤
    } catch (e) {
      record.uuid = _uuid.v4();
    }

    return await isar.writeTxn(() async {
      return await isar.records.put(record);
    });
  }

  static Future<int> saveRecordWithGoal(Record record, int goalId) async {
    // 確保 uuid 被初始化
    try {
      record.uuid; // 嘗試訪問，如果沒有初始化會拋出錯誤
    } catch (e) {
      record.uuid = _uuid.v4();
    }

    return await isar.writeTxn(() async {
      // 確保 goal 存在
      final goal = await isar.goals.get(goalId);
      if (goal == null) {
        throw Exception('Goal with id $goalId not found');
      }

      // 保存 record
      final recordId = await isar.records.put(record);

      // 建立關聯
      final savedRecord = await isar.records.get(recordId);
      if (savedRecord != null) {
        savedRecord.goal.value = goal;
        await savedRecord.goal.save();
      }

      // 更新 goal 的 records 列表
      goal.records.add(savedRecord!);
      await goal.records.save();

      return recordId;
    });
  }

  static Future<bool> deleteRecord(int id) async {
    return await isar.writeTxn(() async {
      return await isar.records.delete(id);
    });
  }
}
