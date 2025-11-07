# 🐛 Debug Guide - 距離不減少問題

## 問題描述

距離不會減少，console 也沒有顯示倒數的 log。

## Debug 步驟

### 步驟 1: 檢查 Console Log

運行 app 後，在 console 中應該看到這些 log：

#### 打卡時
```
Bear: Check-in for Goal X! Distance maintained at Y (Test Mode: 10s = 1 day)
```

#### 每秒檢查距離時
```
Bear: Goal X has no check-in history, returning base distance 5
或
Bear: Goal X - lastDistance: 5, daysGap: 0, computed: 5
Bear Test Mode: 0s elapsed = 0 simulated days
```

#### 10 秒後（距離應該減少）
```
Bear Test Mode: 10s elapsed = 1 simulated days
Bear: Goal X - lastDistance: 5, daysGap: 1, computed: 4
Bear: Goal X onActivate - previous: 5, computed: 4, gap: 1
Bear: Distance decreased for Goal X from 5 to 4 (Test Mode)
```

### 步驟 2: 測試流程

1. **重置 Goal**
   ```
   - 點擊 🔄 重置按鈕
   - Console 應該顯示: "Bear: Reset for Goal X"
   ```

2. **打卡**
   ```
   - 點擊 ✓ 打卡按鈕
   - Console 應該顯示: "Bear: Check-in for Goal X! Distance maintained at 5"
   ```

3. **觀察 Console（每秒）**
   ```
   第 1 秒: Bear Test Mode: 1s elapsed = 0 simulated days
   第 2 秒: Bear Test Mode: 2s elapsed = 0 simulated days
   ...
   第 9 秒: Bear Test Mode: 9s elapsed = 0 simulated days
   第 10 秒: Bear Test Mode: 10s elapsed = 1 simulated days ⚡
   ```

4. **第 10 秒時應該發生**
   ```
   - Console: "Bear: Goal X - lastDistance: 5, daysGap: 1, computed: 4"
   - UI: 距離從 5/5 變成 4/5
   ```

### 步驟 3: 檢查資料

如果沒有 log，可能是：

#### 問題 1: Goal 沒有打卡記錄
```dart
// 檢查 Goal 的資料
final goal = await IsarService.getGoalById(goalId);
print('lastBearCheckin: ${goal.lastBearCheckin}');
print('lastBearDistance: ${goal.lastBearDistance}');
```

**預期結果**:
- 打卡前: `lastBearCheckin: null`, `lastBearDistance: 5`
- 打卡後: `lastBearCheckin: 2025-11-07 14:30:00`, `lastBearDistance: 5`

#### 問題 2: 計時器沒有運行
```dart
// 在 _startDistanceUpdateTimer 中添加 log
void _startDistanceUpdateTimer() {
  _distanceUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
    print('Timer tick: checking distance for goal ${widget.goal.id}');
    // ...
  });
}
```

#### 問題 3: Goal ID 不正確
```dart
// 檢查 Goal ID
print('Current Goal ID: ${widget.goal.id}');
```

## 常見問題

### Q1: Console 完全沒有 log
**可能原因**: 
- App 沒有正確運行
- Console 被過濾了
- Debug 模式沒有啟用

**解決方法**:
```bash
flutter run --verbose
```

### Q2: 有 log 但距離不變
**可能原因**:
- `daysGap` 一直是 0
- `lastBearCheckin` 沒有正確保存
- 時間計算有問題

**檢查**:
```
看 console 中的 "Bear Test Mode: Xs elapsed = Y simulated days"
- 如果 X 一直是 0，表示時間沒有經過
- 如果 Y 一直是 0，表示計算有問題
```

### Q3: 打卡後立刻變成 0
**可能原因**:
- `lastBearCheckin` 保存的時間不對
- 舊資料殘留

**解決方法**:
1. 點擊 🔄 重置按鈕
2. 重新打卡
3. 觀察 console

### Q4: 每次進入頁面距離都重置
**可能原因**:
- `onActivate` 邏輯有問題
- 資料沒有正確保存

**檢查**:
```
看 console 中的 "Bear: Goal X onActivate - ..."
- 應該只在距離真的改變時才顯示 "Distance decreased"
```

## 手動測試腳本

### 測試 1: 基本流程
```
1. 打開 Goal Detail
2. 點擊 🔄 重置
3. 點擊 ✓ 打卡
4. 等待 10 秒（不要離開頁面）
5. 觀察距離是否從 5 變成 4
```

**預期 Console Log**:
```
Bear: Reset for Goal 1
Bear: Check-in for Goal 1! Distance maintained at 5 (Test Mode: 10s = 1 day)
Bear Test Mode: 1s elapsed = 0 simulated days
Bear Test Mode: 2s elapsed = 0 simulated days
...
Bear Test Mode: 10s elapsed = 1 simulated days
Bear: Goal 1 - lastDistance: 5, daysGap: 1, computed: 4
```

### 測試 2: 離開再回來
```
1. 打卡
2. 等待 10 秒
3. 離開頁面（回到 Home）
4. 再次進入 Goal Detail
5. 應該看到 decrement modal
```

**預期 Console Log**:
```
Bear: Goal 1 onActivate - previous: 5, computed: 4, gap: 1
Bear: Distance decreased for Goal 1 from 5 to 4 (Test Mode)
```

### 測試 3: 連續減少
```
1. 打卡（距離 5）
2. 等待 10 秒（距離 4）
3. 等待 10 秒（距離 3）
4. 等待 10 秒（距離 2）
5. 等待 10 秒（距離 1）
6. 等待 10 秒（距離 0）
```

**預期**: 每 10 秒距離減少 1

## 如果還是不行

### 最後手段：完全重置

1. **清除 App 資料**
   ```bash
   # iOS
   刪除 app 重新安裝
   
   # Android
   設定 → Apps → 清除資料
   ```

2. **重新生成資料庫**
   ```bash
   flutter pub run build_runner clean
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **重新運行**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## 提供 Debug 資訊

如果問題持續，請提供：

1. **Console 完整 log**（從打卡到 10 秒後）
2. **Goal 資料**
   ```dart
   final goal = await IsarService.getGoalById(goalId);
   print('Goal: ${goal?.toJson()}');
   ```
3. **當前時間**
   ```dart
   print('Current time: ${DateTime.now()}');
   ```
4. **測試模式確認**
   ```dart
   print('Test mode: $_testMode');
   print('Test interval: $_testIntervalSeconds');
   ```

## 快速檢查清單

- [ ] Console 有顯示 "Bear Test Mode" log
- [ ] 打卡後有顯示 "Check-in for Goal X" log
- [ ] 每秒有顯示時間經過的 log
- [ ] 10 秒後有顯示 "simulated days = 1"
- [ ] 距離有從 5 變成 4
- [ ] UI 有即時更新
- [ ] 顏色有改變（綠 → 橘）

如果以上都沒有，請提供完整的 console log！
