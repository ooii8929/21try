# Requirements Document

## Introduction

The Bear Habit Tracker is an interactive gamification feature that motivates users to maintain consistent check-ins for their goals. The system uses a "Bear Chasing Human" metaphor where a bear starts 5 units away and gets closer each day the user skips a check-in. Each goal has its own independent bear tracking, and the system provides real-time visual feedback through randomized images and distance indicators.

## Glossary

- **Bear System**: The gamification mechanism that tracks user consistency through a distance metaphor on a per-goal basis
- **Base Distance**: The maximum safe distance value, always set to 5
- **Computed Distance**: The current distance between user and bear, calculated as max(0, lastBearDistance - daysSinceLastCheckin)
- **Check-in**: User action that maintains the current distance and records the current date/time
- **Maintain Distance**: When checking in, the distance stays at its current value rather than resetting to 5
- **Event Type**: Classification of what happened: "maintain" (checked in), "decrement" (distance decreased), or "idle" (no change)
- **Image Gallery**: Collection of themed images organized by event type and distance level
- **Test Mode**: Development mode where 10 seconds equals 1 day for rapid testing
- **Real-time Update**: Automatic distance recalculation every second while viewing goal details
- **Per-Goal Tracking**: Each goal maintains its own independent bear state in the Goal model

## Requirements

### Requirement 1: Per-Goal Distance Calculation and Tracking

**User Story:** As a user, I want each of my goals to have its own independent bear tracking, so that I can manage different goals with different check-in patterns.

#### Acceptance Criteria

1. WHEN a new Goal is created, THE Goal SHALL initialize with lastBearDistance set to 5 and lastBearCheckin set to null
2. WHEN the Bear System calculates current distance for a Goal, THE Bear System SHALL compute the value as max(0, lastBearDistance - daysSinceLastCheckin)
3. WHEN no previous check-in exists for a Goal, THE Bear System SHALL return the base distance of 5
4. WHEN the computed distance reaches 0, THE Bear System SHALL maintain the value at 0 until the next check-in
5. WHEN calculating days since last check-in in production mode, THE Bear System SHALL use local date only (truncated to day, ignoring time)
6. WHEN calculating days since last check-in in test mode, THE Bear System SHALL use 10-second intervals to simulate days for rapid testing

### Requirement 2: Check-in Action with Distance Maintenance

**User Story:** As a user, I want to perform a check-in action that maintains my current distance, so that I can stop the bear from getting closer without resetting my progress.

#### Acceptance Criteria

1. WHEN the user performs a check-in action, THE Bear System SHALL maintain the current computed distance (not reset to 5)
2. WHEN the user performs a check-in action, THE Bear System SHALL record the current date/time in the Goal's lastBearCheckin field
3. WHEN the user performs a check-in action, THE Bear System SHALL update the Goal's lastBearDistance to the current computed distance
4. WHEN the user performs a check-in action, THE Bear System SHALL generate an event with type "maintain"
5. WHEN the user performs a check-in action, THE Bear System SHALL select a random image from the maintain gallery
6. WHEN the user checks in at distance 0, THE Bear System SHALL maintain distance at 0 (cannot recover without reset)

### Requirement 3: Event Detection and Real-time Updates

**User Story:** As a user, I want the system to detect when my distance has changed and update in real-time, so that I receive immediate visual feedback about my progress.

#### Acceptance Criteria

1. WHEN the computed distance is less than the Goal's lastBearDistance, THE Bear System SHALL generate an event with type "decrement"
2. WHEN the computed distance equals the Goal's lastBearDistance AND no check-in occurred, THE Bear System SHALL return null (no event)
3. WHEN a "decrement" event occurs, THE Bear System SHALL select a random image from the corresponding distance gallery (e.g., distance/d4/)
4. WHEN a "decrement" event occurs, THE Bear System SHALL update the Goal's lastBearDistance to the new computed distance
5. WHILE viewing a Goal Detail screen, THE Goal Detail Screen SHALL check distance every 1 second and update the UI if distance changes
6. WHEN distance changes during real-time monitoring, THE Goal Detail Screen SHALL update the distance display immediately without requiring navigation

### Requirement 4: Image Gallery Management

**User Story:** As a user, I want to see varied and contextually appropriate images based on my check-in behavior, so that the experience feels dynamic and engaging.

#### Acceptance Criteria

1. WHEN a "maintain" event occurs, THE Bear System SHALL randomly select one image from the maintain gallery
2. WHEN a "decrement" event occurs, THE Bear System SHALL randomly select one image from the gallery corresponding to the new distance level (d0 through d5)
3. WHEN selecting a random image, THE Bear System SHALL avoid repeating the previously shown image if more than one image is available in the gallery
4. WHEN the image gallery for a specific distance contains no images, THE Bear System SHALL handle the missing gallery gracefully without crashing
5. WHEN loading images, THE Bear System SHALL use the asset path structure: assets/bear/maintain/ and assets/bear/distance/d{0-5}/

### Requirement 5: State Persistence in Goal Model

**User Story:** As a user, I want my check-in history and distance to persist across app sessions, so that my progress is not lost when I close the app.

#### Acceptance Criteria

1. WHEN the Bear System saves state for a Goal, THE Bear System SHALL persist lastBearCheckin as a DateTime in the Goal's Isar collection
2. WHEN the Bear System saves state for a Goal, THE Bear System SHALL persist lastBearDistance as an integer in the Goal's Isar collection
3. WHEN the Bear System loads state for a Goal, THE Bear System SHALL retrieve lastBearCheckin from the Goal model
4. WHEN the Bear System loads state for a Goal, THE Bear System SHALL retrieve lastBearDistance from the Goal model
5. WHEN a Goal has no previous check-in, THE Goal SHALL have lastBearCheckin set to null and lastBearDistance set to 5

### Requirement 6: Goal Detail Screen Integration

**User Story:** As a user, I want the Bear Habit Tracker to be integrated into my goal detail page with real-time updates, so that I can track consistency for each individual goal.

#### Acceptance Criteria

1. WHEN viewing a goal detail screen, THE Goal Detail Screen SHALL display the current bear distance prominently in a dedicated card
2. WHEN viewing a goal detail screen, THE Goal Detail Screen SHALL provide a quick check-in button (✓) for immediate check-in
3. WHEN the user creates a new record for a goal, THE Goal Detail Screen SHALL automatically trigger a check-in for that Goal
4. WHEN the Goal Detail Screen activates (becomes visible), THE Goal Detail Screen SHALL call the Bear System's onActivate method to detect distance changes
5. WHEN a bear event occurs (maintain or decrement), THE Goal Detail Screen SHALL display a modal showing the event image and message
6. WHEN the Goal Detail Screen is visible, THE Goal Detail Screen SHALL start a timer that checks distance every 1 second
7. WHEN the Goal Detail Screen is disposed, THE Goal Detail Screen SHALL cancel the distance update timer

### Requirement 7: Visual Feedback and Status Indicators

**User Story:** As a user, I want clear visual feedback about my current distance and recent events with color-coded indicators, so that I understand my progress at a glance.

#### Acceptance Criteria

1. WHEN displaying the bear distance card, THE Goal Detail Screen SHALL show the format "{current}/5" with a visual progress bar
2. WHEN distance is greater than 2, THE Goal Detail Screen SHALL display the distance in green color indicating safety
3. WHEN distance is 1 or 2, THE Goal Detail Screen SHALL display the distance in orange color indicating warning
4. WHEN distance is 0, THE Goal Detail Screen SHALL display the distance in red color indicating danger
5. WHEN a "maintain" event occurs, THE Goal Detail Screen SHALL display contextual messages based on current distance
6. WHEN a "decrement" event occurs, THE Goal Detail Screen SHALL display a warning message with the previous and new distance values
7. WHEN distance reaches 0, THE Goal Detail Screen SHALL display a "bear caught you" message
8. WHEN displaying event modals, THE Goal Detail Screen SHALL provide a "Got it!" button to dismiss the modal
9. WHEN distance changes in real-time, THE Goal Detail Screen SHALL update the status text to reflect the current danger level

### Requirement 8: Test Mode and Development Tools

**User Story:** As a developer, I want a test mode that simulates days in seconds, so that I can rapidly test the bear distance feature without waiting for real days to pass.

#### Acceptance Criteria

1. WHEN test mode is enabled, THE Bear System SHALL treat 10 seconds as equivalent to 1 day
2. WHEN test mode is enabled, THE Bear System SHALL log simulated day calculations to the console for debugging
3. WHEN test mode is disabled, THE Bear System SHALL use real calendar days for distance calculations
4. WHEN the reset function is called for a Goal, THE Bear System SHALL set lastBearCheckin to null and lastBearDistance to 5
5. WHEN the reset function is called, THE Bear System SHALL log the reset action to the console
