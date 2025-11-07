# 🧪 Bear Distance - Test Mode Guide

## 測試模式說明

為了方便測試，我已經啟用了**測試模式**，讓你可以快速驗證功能，而不需要等待真實的天數。

### 測試模式設定

- **10 秒 = 1 天**
- 測試模式已啟用（`_testMode = true`）
- 可以在 `lib/services/bear_service.dart` 中調整

## 快速測試流程

### 測試 1: 首次打卡 ✅

1. 運行 app: `flutter run`
2. 打開任何目標詳情頁面
3. 看到 Bear Distance Card 顯示 `TEST: 10s = 1 day` 標記
4. 點擊 ✓ 快速打卡按鈕
5. **預期結果**:
   - 出現 "🎉 Great Job!" modal
   - 距離顯示 5/5（綠色）
   - Console 顯示: `Bear: Check-in! Distance maintained at 5 (Test Mode: 10s = 1 day)`

### 測試 2: 等待 10 秒（模擬 1 天）⏱️

1. 打卡後，**等待 10 秒**
2. 離開頁面再回來（或重新進入 Goal Detail）
3. **預期結果**:
   - 出現 "⚠️ Bear is getting closer!" modal
   - 距離從 5 降到 4
   - 顏色變成橘色
   - Console 顯示: `Bear Test Mode: 10s elapsed = 1 simulated days`

### 測試 3: 連續等待（模擬多天）📉

繼續等待並觀察距離變化：

| 時間 | 距離 | 顏色 | 狀態 |
|------|------|------|------|
| 0s | 5 | 🟢 綠色 | Safe! |
| 10s | 4 | 🟠 橘色 | Getting closer |
| 20s | 3 | 🟠 橘色 | Getting closer |
| 30s | 2 | 🟠 橘色 | Danger! |
| 40s | 1 | 🔴 紅色 | Very close! |
| 50s | 0 | 🔴 紅色 | Caught! |

**操作方式**:
- 每等 10 秒，離開並重新進入 Goal Detail
- 或者等待 50 秒後再進入，直接看到距離 0

### 測試 4: 被抓到後重置 🔄

1. 等待 50 秒（距離降到 0）
2. 進入 Goal Detail，看到 "🐻 Bear caught you!" modal
3. 點擊 ✓ 快速打卡
4. **預期結果**:
   - 距離重置為 5/5
   - 顏色變回綠色
   - 出現 "🎉 Great Job!" modal

## 實時測試技巧

### 方法 1: 使用計時器 ⏲️

```
1. 打卡
2. 開始計時 10 秒
3. 10 秒後離開並重新進入頁面
4. 觀察距離變化
```

### 方法 2: 連續測試 🔁

```
1. 打卡（距離 = 5）
2. 等待 10 秒 → 重新進入 → 距離 = 4
3. 等待 10 秒 → 重新進入 → 距離 = 3
4. 等待 10 秒 → 重新進入 → 距離 = 2
5. 等待 10 秒 → 重新進入 → 距離 = 1
6. 等待 10 秒 → 重新進入 → 距離 = 0
7. 打卡 → 距離重置為 5
```

### 方法 3: 長時間等待 ⏳

```
1. 打卡
2. 等待 50 秒（做其他事）
3. 重新進入 Goal Detail
4. 應該直接看到距離 = 0
```

## Console 日誌

測試模式下，你會在 console 看到這些訊息：

```
Bear: Check-in! Distance maintained at 5 (Test Mode: 10s = 1 day)
Bear Test Mode: 10s elapsed = 1 simulated days
Bear: Distance decreased from 5 to 4 (Test Mode)
Bear Test Mode: 20s elapsed = 2 simulated days
Bear: Distance decreased from 4 to 3 (Test Mode)
...
```

## 調整測試間隔

如果 10 秒太長或太短，可以修改 `lib/services/bear_service.dart`:

```dart
// 改成 5 秒 = 1 天
static const int _testIntervalSeconds = 5;

// 或改成 30 秒 = 1 天
static const int _testIntervalSeconds = 30;
```

## 切換到正式模式

測試完成後，要切換到正式模式（使用真實天數）：

1. 打開 `lib/services/bear_service.dart`
2. 找到這行：
   ```dart
   static const bool _testMode = true;
   ```
3. 改成：
   ```dart
   static const bool _testMode = false;
   ```
4. 重新編譯 app

正式模式下：
- 使用真實的日期計算
- 不會顯示 "TEST: 10s = 1 day" 標記
- Console 不會顯示測試模式訊息

## 重置測試狀態

如果想重新開始測試，可以：

### 方法 1: 使用 Reset 功能

在 `goal_detail_screen.dart` 暫時添加一個重置按鈕：

```dart
// 在 _buildRecordButton() 中添加
ElevatedButton(
  onPressed: () async {
    await BearService.reset();
    await _checkBearStatus();
  },
  child: Text('Reset Bear (Debug)'),
)
```

### 方法 2: 清除 App 資料

- iOS: 刪除 app 重新安裝
- Android: 設定 → Apps → 清除資料

### 方法 3: 使用 SharedPreferences

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
```

## 常見問題

### Q: 為什麼等了 10 秒但距離沒變？

A: 需要**離開並重新進入** Goal Detail 頁面，才會觸發 `onActivate()` 檢查距離變化。

### Q: 可以在背景等待嗎？

A: 可以！時間計算是基於時間戳差異，不需要 app 保持開啟。

### Q: 測試模式會影響正式功能嗎？

A: 不會。測試模式只是改變時間計算方式，其他邏輯完全相同。切換到正式模式後，功能會使用真實日期。

### Q: 如何確認當前是測試模式？

A: 看 Bear Distance Card 上是否有 "TEST: 10s = 1 day" 橘色標記。

## 測試檢查清單

- [ ] 首次打卡顯示 maintain modal
- [ ] 10 秒後距離降到 4
- [ ] 20 秒後距離降到 3
- [ ] 30 秒後距離降到 2（橘色）
- [ ] 40 秒後距離降到 1（紅色）
- [ ] 50 秒後距離降到 0（被抓）
- [ ] 被抓後打卡重置為 5
- [ ] Console 顯示正確的測試模式訊息
- [ ] 測試標記正確顯示
- [ ] 顏色變化正確（綠→橘→紅）

## 下一步

測試完成後：
1. 確認所有功能正常
2. 切換到正式模式（`_testMode = false`）
3. 移除測試標記（或保留給開發用）
4. 準備發布

---

**提示**: 測試模式讓你可以在 1 分鐘內完整測試整個距離機制（0→5→0），非常方便！🚀
