# 🚀 Quick Test Reference Card

## 測試模式已啟用！

**10 秒 = 1 天** 🕐

## 快速測試步驟

```
1. flutter run
2. 打開任何目標
3. 點擊 ✓ 打卡 → 距離 5/5 ✅
4. 等 10 秒 → 重新進入 → 距離 4/5 ⚠️
5. 等 10 秒 → 重新進入 → 距離 3/5 ⚠️
6. 等 10 秒 → 重新進入 → 距離 2/5 🟠
7. 等 10 秒 → 重新進入 → 距離 1/5 🔴
8. 等 10 秒 → 重新進入 → 距離 0/5 🐻
9. 點擊 ✓ 打卡 → 距離重置 5/5 ✅
```

## 時間表

| 時間 | 距離 | 顏色 | 狀態 |
|:----:|:----:|:----:|:-----|
| 0s   | 5/5  | 🟢   | Safe! |
| 10s  | 4/5  | 🟠   | Getting closer |
| 20s  | 3/5  | 🟠   | Getting closer |
| 30s  | 2/5  | 🟠   | Danger! |
| 40s  | 1/5  | 🔴   | Very close! |
| 50s  | 0/5  | 🔴   | Caught! |

## 識別測試模式

看到這個標記 = 測試模式啟用：
```
Bear Distance [TEST: 10s = 1 day]
```

## 切換到正式模式

編輯 `lib/services/bear_service.dart`:
```dart
static const bool _testMode = false; // 改成 false
```

## 調整測試速度

編輯 `lib/services/bear_service.dart`:
```dart
static const int _testIntervalSeconds = 5;  // 5秒 = 1天
static const int _testIntervalSeconds = 30; // 30秒 = 1天
```

## Console 訊息

```
✅ Bear: Check-in! Distance maintained at 5 (Test Mode: 10s = 1 day)
⏱️ Bear Test Mode: 10s elapsed = 1 simulated days
⚠️ Bear: Distance decreased from 5 to 4 (Test Mode)
```

## 重置狀態

```dart
await BearService.reset();
```

---

**完整文檔**: 查看 `TEST_MODE_GUIDE.md`
