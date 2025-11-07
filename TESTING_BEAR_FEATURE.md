# Testing the Bear Distance Feature

## Quick Test Guide

### Prerequisites
- App installed and running
- At least one goal created

### Test 1: First Check-in ✅

1. Open any goal detail screen
2. Tap the quick check-in button (✓ icon)
3. **Expected**: 
   - Modal appears with "🎉 Great Job!" title
   - Shows "maintain" message
   - Distance indicator shows 5/5 (all green)
   - Bear distance card shows "Safe! Keep checking in daily"

### Test 2: View Distance Card 📊

1. Look at the bear distance card in goal detail
2. **Expected**:
   - Shows 🐻 emoji
   - Displays "Bear Distance" title
   - Shows current distance (5/5 initially)
   - Visual bar with 5 segments (all filled green)
   - Status text: "Safe! Keep checking in daily"

### Test 3: Skip a Day (Simulated) ⏭️

**Option A: Change Device Date**
1. Close the app
2. Go to device Settings → Date & Time
3. Disable automatic date/time
4. Set date to tomorrow
5. Open app and go to goal detail
6. **Expected**:
   - Modal appears with "⚠️ Bear is getting closer!"
   - Shows distance decreased from 5 to 4
   - Distance card shows 4/5 (orange color)
   - Status text: "Getting closer... Check in soon!"

**Option B: Wait 24 Hours** (Real test)
1. Check in today
2. Wait until tomorrow
3. Open goal detail
4. Should see decrement modal

### Test 4: Multiple Skips 📉

1. Keep advancing date (or waiting days) without checking in
2. Each day, distance should decrease by 1
3. **Expected progression**:
   - Day 1: Distance 5 → 4 (orange, "Getting closer")
   - Day 2: Distance 4 → 3 (orange, "Getting closer")
   - Day 3: Distance 3 → 2 (orange, "Danger! Bear is very close!")
   - Day 4: Distance 2 → 1 (red, "Danger! Bear is very close!")
   - Day 5: Distance 1 → 0 (red, "🐻 Oh no! Bear caught you!")

### Test 5: Reset After Being Caught 🔄

1. After distance reaches 0
2. Tap quick check-in button
3. **Expected**:
   - Modal shows "🎉 Great Job!"
   - Distance resets to 5/5
   - Card turns green again
   - Status: "Safe! Keep checking in daily"

### Test 6: Video Recording Check-in 🎥

1. Tap "Record Try" button
2. Record a video
3. Save the record
4. **Expected**:
   - Same bear check-in behavior as quick check-in
   - Distance resets to 5
   - Shows maintain modal

### Test 7: Navigation Behavior 🔄

1. Check in on goal detail
2. Navigate away (back to home)
3. Navigate back to goal detail
4. **Expected**:
   - No modal appears (already checked in today)
   - Distance card shows 5/5
   - No duplicate events

### Test 8: Multiple Goals 🎯

1. Create multiple goals
2. Check in on Goal A
3. Open Goal B
4. **Expected**:
   - Bear distance is SHARED across all goals
   - Goal B also shows distance 5/5
   - One check-in affects all goals

## Debug Commands

### Check Current State
Add this temporarily to test:
```dart
final state = await BearService.getState();
debugPrint('Last check-in: ${state.lastCheckinLocalDate}');
debugPrint('Distance: ${await BearService.getCurrentDistance()}');
```

### Reset Bear State
Add this button temporarily for testing:
```dart
ElevatedButton(
  onPressed: () async {
    await BearService.reset();
    setState(() {});
  },
  child: Text('Reset Bear'),
)
```

### Force Decrement Event
Change device date forward to trigger decrement without waiting.

## Common Issues & Solutions

### Issue: Modal doesn't appear
**Solution**: Check console for errors, ensure images exist or error handling works

### Issue: Distance doesn't change
**Solution**: 
- Verify SharedPreferences is working
- Check date calculations
- Look for timezone issues

### Issue: Images not loading
**Solution**: 
- Images are optional - placeholder icon shows if missing
- Add actual images to `assets/bear/` directories
- Run `flutter clean` and rebuild

### Issue: Distance resets unexpectedly
**Solution**: 
- Check if multiple check-ins are being triggered
- Verify date comparison logic
- Check SharedPreferences persistence

## Expected Console Logs

When working correctly, you should see:
```
Bear: Check-in! Distance maintained at 5
Bear: Distance decreased from 5 to 4
```

## Visual Checklist

- [ ] Bear distance card appears in goal detail
- [ ] Distance indicator shows correct number
- [ ] Color changes based on distance (green/orange/red)
- [ ] Status text updates appropriately
- [ ] Modal appears on check-in
- [ ] Modal appears when distance decreases
- [ ] Modal can be dismissed
- [ ] Distance persists across app restarts
- [ ] Quick check-in triggers bear event
- [ ] Video recording triggers bear event

## Performance Check

- [ ] No lag when opening goal detail
- [ ] Modal appears smoothly
- [ ] No memory leaks (check with DevTools)
- [ ] SharedPreferences reads are fast
- [ ] Image loading doesn't block UI

## Next Steps After Testing

1. Add actual bear images to assets
2. Customize messages and colors
3. Consider adding animations
4. Add sound effects (optional)
5. Implement notifications for low distance
6. Add statistics tracking
