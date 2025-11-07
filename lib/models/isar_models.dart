import 'package:isar/isar.dart';

part 'isar_models.g.dart';

@Collection()
class Goal {
  Id id = Isar.autoIncrement; // 本地自增ID
  late String uuid; // 穩定ID（跨裝置/上雲可用）
  late String title; // 目標名稱
  DateTime createdAt = DateTime.now();

  // Bear Distance 相關欄位
  DateTime? lastBearCheckin; // 最後一次打卡時間
  int lastBearDistance = 5; // 最後記錄的距離（預設 5）

  // 一個 Goal 底下多個 Record
  final records = IsarLinks<Record>();
}

@Collection()
class Record {
  Id id = Isar.autoIncrement;
  late String uuid; // 穩定ID
  late String title; // 這筆紀錄的標題
  String description = ''; // 描述/重點
  late String assetId; // 相簿影片 localIdentifier（必填）
  DateTime createdAt = DateTime.now();

  // 反向：此 Record 隸屬哪個 Goal
  final goal = IsarLink<Goal>();
}
