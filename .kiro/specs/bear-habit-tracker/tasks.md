# Implementation Plan

- [ ] 1. Create bear state data models and utilities
  - Create `lib/models/bear_models.dart` with BearState, BearEvent, and BearEventType classes
  - Implement JSON serialization/deserialization for BearState
  - Implement copyWith method for immutable state updates
  - Add date utility function for local date truncation
  - _Requirements: 1.1, 1.2, 1.3, 3.1, 3.2, 5.1, 5.2_

- [ ] 2. Implement bear state persistence service
  - Create `lib/services/bear_state_service.dart` for SharedPreferences operations
  - Implement loadState method to retrieve bear state for a goal
  - Implement saveState method to persist bear state for a goal
  - Implement clearState method for testing/reset functionality
  - Handle missing or corrupted data gracefully with default values
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 3. Implement image gallery service
  - Create `lib/services/image_gallery_service.dart` for asset image management
  - Implement getMaintainImage method to select random maintain images
  - Implement getDistanceImage method to select random distance-specific images
  - Implement logic to avoid repeating the last shown image
  - Handle missing or empty galleries gracefully
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 4. Implement core bear tracking logic
  - Create `lib/services/bear_service.dart` with core business logic
  - Implement getCurrentDistance method to calculate and return current distance
  - Implement distance calculation logic: max(0, baseDistance - daysSinceLastCheckin)
  - Implement event type detection (maintain, decrement, idle)
  - Implement message generation for each event type
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 3.1, 3.2, 3.5_

- [ ] 5. Implement check-in functionality
  - Add doCheckin method to BearService
  - Reset distance to 5 on check-in
  - Update lastCheckinDate to current local date
  - Generate maintain event with random image
  - Persist updated state via BearStateService
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ] 6. Implement activation detection
  - Add onActivate method to BearService
  - Calculate current computed distance based on days since last check-in
  - Compare with lastShownDistance to detect decrements
  - Generate decrement event if distance decreased
  - Return null for idle events (no change)
  - Update lastShownDistance after detection
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 7. Add bear image assets to project
  - Create asset directory structure: assets/bear/maintain/ and assets/bear/distance/d0-d5/
  - Add placeholder images for maintain gallery (at least 2 images)
  - Add placeholder images for each distance level d0 through d5 (at least 1 image each)
  - Update pubspec.yaml to include bear asset directories
  - _Requirements: 4.1, 4.2, 4.5_

- [ ] 8. Create bear event modal widget
  - Create `lib/widgets/bear_event_modal.dart` for displaying events
  - Display event image if available
  - Display event message text
  - Style modal with AppColors theme
  - Add dismiss button to close modal
  - Handle null image paths gracefully
  - _Requirements: 7.2, 7.3, 7.4, 7.5_

- [ ] 9. Integrate bear distance display into goal detail screen
  - Add bear distance section above progress section in GoalDetailScreen
  - Display current distance in format "Distance: X / 5"
  - Add bear icon for visual identification
  - Style section consistently with existing UI
  - Load distance on screen initialization
  - _Requirements: 6.1, 7.1_

- [ ] 10. Integrate bear activation into goal detail screen lifecycle
  - Call BearService.onActivate in initState of GoalDetailScreen
  - Call BearService.onActivate in didPopNext when returning from child routes
  - Show bear event modal if event is not idle
  - Update distance display after activation
  - _Requirements: 6.4_

- [ ] 11. Integrate check-in trigger with record creation
  - Modify record button tap handler to detect successful record creation
  - Call BearService.doCheckin after record is saved
  - Show maintain event modal after check-in
  - Update distance display to show 5
  - _Requirements: 6.3_

- [ ] 12. Add shared_preferences dependency
  - Add shared_preferences package to pubspec.yaml
  - Run flutter pub get to install dependency
  - Verify package is available for import
  - _Requirements: 5.1, 5.2_

- [ ]* 13. Write unit tests for bear models
  - Test BearState JSON serialization and deserialization
  - Test BearState copyWith method
  - Test BearEvent creation with different event types
  - Test date utility function for local date truncation
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ]* 14. Write unit tests for bear services
  - Test BearService distance calculation with various day gaps
  - Test BearService event type detection logic
  - Test BearService message generation
  - Test BearStateService save and load operations
  - Test ImageGalleryService image selection and avoidance logic
  - _Requirements: 1.1, 1.2, 1.3, 3.1, 3.2, 4.1, 4.2, 4.3, 5.1, 5.2_

- [ ]* 15. Write widget tests for bear UI components
  - Test bear distance display renders correctly
  - Test bear event modal displays image and message
  - Test modal dismiss functionality
  - Test handling of null image paths
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_
