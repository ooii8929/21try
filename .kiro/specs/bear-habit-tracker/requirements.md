# Requirements Document

## Introduction

The Bear Habit Tracker is an interactive gamification feature that motivates users to maintain consistent check-ins for their goals. The system uses a "Bear Chasing Human" metaphor where a bear starts 5 units away and gets closer each day the user skips a check-in. Visual feedback through randomized images reinforces the urgency and celebrates consistency.

## Glossary

- **Bear System**: The gamification mechanism that tracks user consistency through a distance metaphor
- **Base Distance**: The maximum safe distance value, always set to 5
- **Computed Distance**: The current distance between user and bear, calculated as max(0, baseDistance - daysSinceLastCheckin)
- **Check-in**: User action that resets the distance to 5 and records the current date
- **Event Type**: Classification of what happened: "maintain" (checked in today), "decrement" (distance decreased), or "idle" (no change)
- **Image Gallery**: Collection of themed images organized by event type and distance level
- **Local Date**: Date truncated to day precision in the user's timezone (e.g., Asia/Taipei)

## Requirements

### Requirement 1: Distance Calculation and Tracking

**User Story:** As a user, I want the system to automatically track how many days have passed since my last check-in, so that I can see the consequences of skipping days.

#### Acceptance Criteria

1. WHEN the Bear System initializes, THE Bear System SHALL set the base distance to 5
2. WHEN the Bear System calculates current distance, THE Bear System SHALL compute the value as max(0, baseDistance - daysSinceLastCheckin)
3. WHEN no previous check-in exists, THE Bear System SHALL treat daysSinceLastCheckin as 0
4. WHEN the computed distance reaches 0, THE Bear System SHALL maintain the value at 0 until the next check-in
5. WHEN calculating days since last check-in, THE Bear System SHALL use local date only (truncated to day, ignoring time)

### Requirement 2: Check-in Action

**User Story:** As a user, I want to perform a check-in action that resets my distance to safety, so that I can maintain my streak and keep the bear away.

#### Acceptance Criteria

1. WHEN the user performs a check-in action, THE Bear System SHALL set the computed distance to 5
2. WHEN the user performs a check-in action, THE Bear System SHALL record the current local date as lastCheckinDate
3. WHEN the user performs a check-in action, THE Bear System SHALL generate an event with type "maintain"
4. WHEN the user performs a check-in action, THE Bear System SHALL select a random image from the maintain gallery
5. WHEN the user checks in multiple times on the same day, THE Bear System SHALL maintain distance at 5 and generate "maintain" events

### Requirement 3: Event Detection

**User Story:** As a user, I want the system to detect when my distance has changed, so that I receive appropriate visual feedback about my progress.

#### Acceptance Criteria

1. WHEN the computed distance is less than the last shown distance, THE Bear System SHALL generate an event with type "decrement"
2. WHEN the computed distance equals the last shown distance AND no check-in occurred, THE Bear System SHALL generate an event with type "idle"
3. WHEN a "decrement" event occurs, THE Bear System SHALL select a random image from the corresponding distance gallery (e.g., distance/d4/)
4. WHEN an "idle" event occurs, THE Bear System SHALL NOT change the displayed image
5. WHEN the Bear System generates any event, THE Bear System SHALL update the lastShownDistance to the current computed distance

### Requirement 4: Image Gallery Management

**User Story:** As a user, I want to see varied and contextually appropriate images based on my check-in behavior, so that the experience feels dynamic and engaging.

#### Acceptance Criteria

1. WHEN a "maintain" event occurs, THE Bear System SHALL randomly select one image from the maintain gallery
2. WHEN a "decrement" event occurs, THE Bear System SHALL randomly select one image from the gallery corresponding to the new distance level (d0 through d5)
3. WHEN selecting a random image, THE Bear System SHALL avoid repeating the previously shown image if more than one image is available in the gallery
4. WHEN the image gallery for a specific distance contains no images, THE Bear System SHALL handle the missing gallery gracefully without crashing
5. WHEN loading images, THE Bear System SHALL use the asset path structure: assets/bear/maintain/ and assets/bear/distance/d{0-5}/

### Requirement 5: State Persistence

**User Story:** As a user, I want my check-in history and distance to persist across app sessions, so that my progress is not lost when I close the app.

#### Acceptance Criteria

1. WHEN the Bear System saves state, THE Bear System SHALL persist lastCheckinDate as an ISO date string (date only, no time)
2. WHEN the Bear System saves state, THE Bear System SHALL persist lastShownDistance as an integer value
3. WHEN the Bear System loads state, THE Bear System SHALL retrieve lastCheckinDate and parse it to a DateTime object
4. WHEN the Bear System loads state, THE Bear System SHALL retrieve lastShownDistance as an integer
5. WHEN no persisted state exists, THE Bear System SHALL initialize with null lastCheckinDate and lastShownDistance of 5

### Requirement 6: Goal Integration

**User Story:** As a user, I want the Bear Habit Tracker to be integrated into my goal detail page, so that I can track consistency for each individual goal.

#### Acceptance Criteria

1. WHEN viewing a goal detail screen, THE Goal Detail Screen SHALL display the current bear distance prominently
2. WHEN viewing a goal detail screen, THE Goal Detail Screen SHALL provide a check-in button for the user to record today's check-in
3. WHEN the user creates a new record for a goal, THE Goal Detail Screen SHALL automatically trigger a check-in for the Bear System
4. WHEN the Goal Detail Screen activates (becomes visible), THE Goal Detail Screen SHALL call the Bear System's onActivate method to detect distance changes
5. WHEN a bear event occurs (maintain or decrement), THE Goal Detail Screen SHALL display a modal or overlay showing the event image and message

### Requirement 7: Visual Feedback

**User Story:** As a user, I want clear visual feedback about my current distance and recent events, so that I understand my progress at a glance.

#### Acceptance Criteria

1. WHEN displaying the bear distance, THE Goal Detail Screen SHALL show the format "Distance: {current} / 5"
2. WHEN a "maintain" event occurs, THE Goal Detail Screen SHALL display the event image with the message "You checked in today! Distance stays at 5."
3. WHEN a "decrement" event occurs, THE Goal Detail Screen SHALL display the event image with a message indicating the new distance (e.g., "Distance decreased to 4. Check in to stay safe!")
4. WHEN distance reaches 0, THE Goal Detail Screen SHALL display a message indicating the bear has caught the user (e.g., "The bear caught you! Check in to reset.")
5. WHEN displaying event modals, THE Goal Detail Screen SHALL provide a dismiss action to close the modal
