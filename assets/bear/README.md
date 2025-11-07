# Bear Habit Image Gallery

This directory contains images for the Bear Distance mechanism.

## Directory Structure

```
assets/bear/
├── maintain/           # Images shown when user checks in (distance stays at 5)
│   ├── maintain_001.png
│   ├── maintain_002.png
│   └── maintain_003.png
├── distance/           # Images shown when distance decreases
│   ├── d5/            # Distance = 5 (safe)
│   │   └── d5_001.png
│   ├── d4/            # Distance = 4
│   │   ├── d4_001.png
│   │   └── d4_002.png
│   ├── d3/            # Distance = 3
│   │   ├── d3_001.png
│   │   └── d3_002.png
│   ├── d2/            # Distance = 2 (danger)
│   │   ├── d2_001.png
│   │   └── d2_002.png
│   ├── d1/            # Distance = 1 (very close)
│   │   ├── d1_001.png
│   │   └── d1_002.png
│   └── d0/            # Distance = 0 (caught!)
│       ├── d0_001.png
│       └── d0_002.png
```

## Image Requirements

- **Format**: PNG (with transparency support)
- **Recommended Size**: 800x600px or similar aspect ratio
- **Style**: Consistent visual style across all images
- **Content**: 
  - `maintain/`: Happy, encouraging bear images
  - `d5/`: Bear far away, safe
  - `d4-d3/`: Bear getting closer
  - `d2-d1/`: Bear very close, urgent
  - `d0/`: Bear caught the user

## Adding Images

1. Create images following the naming convention
2. Place them in the appropriate directory
3. Update `pubspec.yaml` if needed (currently using default asset loading)
4. Images are randomly selected to avoid repetition

## Placeholder Images

Until you add actual images, the app will show a placeholder icon when images fail to load.
