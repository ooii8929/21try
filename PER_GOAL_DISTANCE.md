# 🎯 每個 Goal 獨立距離

## 重大改變：從全局共享改為每個 Goal 獨立

### 之前（全局共享）
```
Goal A: 距離 2/5 🐻
Goal B: 距離 2/5 🐻 (相同)
Goal C: 距離 2/5 🐻 (相同)

在任何 Goal 打卡 → 所有 Goal 的距離都改變
```

### 現在（每個 Goal 獨立）
```
Goal A: 距離 5/5 🐻 (獨立)
Goal B: 距離 2/5 🐻 (獨立)
Goal C: 距離 0/5 🐻 (獨立)

在 Goal A 打卡 → 只影響 Goal A 的距離
```

## 新的行為

### 情境 1: 新建 Goal
```
1. 新建 Goal A
2. Goal A 的距離 = 5/5 ✅ (預設值)
3. 不受其他 Goal 影響
```

### 情境 2: 多個 Goal 獨立追蹤
```
Goal A (學吉他):
- Day 1: 打卡 → 距離 5/5
- Day 2: 打卡 → 距離 5/5
- Day 3: 沒打卡 → 距離 4/5

Goal B (練習冥想):
- Day 1: 打卡 → 距離 5/5
- Day 2: 沒打卡 → 距離 4/5
- Day 3: 沒打卡 → 距離 3/5

Goal C (公開演講):
- Day 1: 打卡 → 距離 5/5
- Day 2: 沒打卡 → 距離 4/5
- Day 3: 打卡 → 距離 4/5
```

### 情境 3: 測試模式下的獨立性
```
Goal A:
0s:  打卡 → 距離 5/5
10s: 沒打卡 → 距離 4/5
20s: 打卡 → 距離 4/5

Goal B (同時):
0s:  打卡 → 距離 5/5
10s: 打卡 → 距離 5/5
20s: 沒打卡 → 距離 4/5

兩個 Goal 完全獨立！
```

## 資料儲存

### Goal 模型新增欄位
```dart
@Collection()
class Goal {
  // ... 原有欄位
  
  // Bear Distance 相關欄位
  DateTime? lastBearCheckin;  // 最後一次打卡時間
  int lastBearDistance = 5;   // 最後記錄的距離（預設 5）
}
```

### 資料庫遷移
- 舊的 Goal 會自動獲得預設值：
  - `lastBearCheckin = null`
  - `lastBearDistance = 5`
- 新建的 Goal 也是相同預設值
- 不需要手動遷移資料

## API 變更

### BearService 方法簽名

**之前（全局）**:
```dart
BearService.getCurrentDistance()
BearService.doCheckin()
BearService.onActivate()
BearService.reset()
```

**現在（每個 Goal）**:
```dart
BearService.getCurrentDistance(goalId)
BearService.doCheckin(goalId)
BearService.onActivate(goalId)
BearService.reset(goalId)
```

### 使用範例

```dart
// 獲取 Goal A 的距離
final distanceA = await BearService.getCurrentDistance(goalA.id);

// Goal A 打卡
final event = await BearService.doCheckin(goalA.id);

// 檢查 Goal A 的距離變化
final eventA = await BearService.onActivate(goalA.id);

// 重置 Goal A 的距離
await BearService.reset(goalA.id);
```

## 優點

### 1. 更合理的追蹤
```
✅ 每個目標有自己的進度
✅ 不會互相影響
✅ 更精確的習慣追蹤
```

### 2. 新建 Goal 不受影響
```
✅ 新建 Goal 總是從 5/5 開始
✅ 不會因為其他 Goal 而顯示 0
✅ 更好的使用者體驗
```

### 3. 獨立管理
```
✅ 可以專注於某個 Goal
✅ 不同 Goal 可以有不同策略
✅ 更靈活的使用方式
```

## 測試方式

### 測試 1: 新建 Goal
```
1. 新建 Goal A
2. 打開 Goal A 詳情
3. 距離應該顯示 5/5 ✅
```

### 測試 2: 多個 Goal 獨立
```
1. 在 Goal A 打卡（距離 5/5）
2. 等 10 秒（Goal A 距離降到 4/5）
3. 打開 Goal B
4. Goal B 距離應該是 5/5 ✅（不受 Goal A 影響）
```

### 測試 3: 獨立打卡
```
1. Goal A 打卡（距離 5/5）
2. Goal B 不打卡，等 10 秒（距離 4/5）
3. Goal A 距離仍是 5/5 ✅
4. Goal B 距離是 4/5 ✅
```

### 測試 4: 重置功能
```
1. Goal A 距離降到 2/5
2. 點擊 Goal A 的重置按鈕
3. Goal A 距離變成 5/5 ✅
4. Goal B 距離不受影響 ✅
```

## 遷移指南

### 對現有資料的影響

**舊的 Goal（沒有 Bear 資料）**:
- `lastBearCheckin = null`
- `lastBearDistance = 5`
- 第一次打卡時會設定 `lastBearCheckin`

**新的 Goal**:
- 自動獲得預設值
- 從 5/5 開始

### 不需要做什麼

✅ Isar 會自動處理新欄位
✅ 預設值會自動套用
✅ 不需要手動遷移資料
✅ 不需要清除舊資料

## 效能考量

### 資料庫查詢
- 每次需要查詢 Goal 資料
- 但因為有 Isar 的快取，效能影響極小
- 每秒一次的查詢不會造成問題

### 記憶體使用
- 每個 Goal 多了 2 個欄位
- 記憶體增加可忽略不計

## 未來擴展

### 可能的功能

1. **Goal 統計**
   - 顯示每個 Goal 的最長連續打卡
   - 顯示平均距離
   - 顯示總打卡次數

2. **Goal 比較**
   - 比較不同 Goal 的表現
   - 顯示最活躍的 Goal
   - 顯示需要關注的 Goal

3. **全局統計**
   - 所有 Goal 的總打卡次數
   - 平均距離
   - 最佳表現的 Goal

## 常見問題

### Q: 舊的 Goal 會怎樣？
A: 自動獲得預設值（距離 5），不受影響。

### Q: 需要重新安裝 App 嗎？
A: 不需要，Isar 會自動處理資料庫遷移。

### Q: 會丟失舊的距離資料嗎？
A: 舊的全局距離資料不會遷移，但不影響使用。每個 Goal 從 5 開始。

### Q: 效能會變差嗎？
A: 不會，影響極小。

### Q: 可以改回全局共享嗎？
A: 可以，但需要修改程式碼。不建議。

## 總結

✅ **每個 Goal 獨立追蹤**
✅ **新建 Goal 從 5/5 開始**
✅ **不會互相影響**
✅ **更合理的設計**
✅ **自動資料庫遷移**

這個改變讓 Bear Distance 功能更加合理和實用！🎯
