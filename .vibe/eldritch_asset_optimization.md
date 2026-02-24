# Eldritch Asset Optimization Strategy

This document outlines the plan to reduce the asset footprint from ~800MB to <100MB to fit within Supabase's free tier (1GB) and handle 512MB RAM constraints.

## 1. Asset Prioritization List

### [MUST-HAVE] Static Images (WebP Compressed)
These require high-fidelity art that cannot be easily reconstructed via UI:
- **Investigator Portraits**: The faces of the heroes.
- **Ancient One Sheets**: Complex large-scale illustrations.
- **Unique Encounter Art**: Key thematic locations (R'lyeh, Plateau of Leng).
- **Monster Art**: Unique monster illustrations.

### [REPLACEABLE] Dynamic UI (Flutter Engine)
These will be generated on-the-fly using the "Dynamic Card Engine":
- **Condition Cards**: (Cursed, Blessed, Injured). Frame + Text + Status Icon.
- **Spell Cards**: Standard frame + Text. Icons used for magic type.
- **Item Cards (Non-Unique)**: Generic weapon/item frame + Text + Icon overlay.
- **Stat Tokens**: Health (Hearts), Sanity (Brains), Clues (Magnifying glass) - using SVG icons.

## 2. Technical Solutions

### A. WebP Conversion Pipeline
- **Target**: Convert all extracted PNGs to WebP.
- **Settings**: Quality 75-80% (Lossy).
- **Estimated Gain**: 70-90% reduction in file size.

### B. Dynamic Card Engine (Flutter)
- **Concept**: Instead of 1000 unique card images, we use:
    - `CardTemplate` widget: Handles background, border, and layout.
    - `Assets`: 10-20 high-quality border "parts" (Corners, edges).
    - `Data`: JSON in Database containing Title, Subtitle, and Body text.
- **Memory Optimization**: Only load small icons and border fragments into RAM. Avoid loading large bitmap card images.

### C. RAM Management (512MB Constraints)
- **Image Cache**: Explicitly limit Flutter's `PaintingBinding.instance.imageCache.maximumSize` to ~100MB.
- **Lazy Loading**: Only load assets for the current game state (e.g., only the selected Ancient One and Investigators).

## 3. Next Steps
1. Create Python script for WebP conversion.
2. Design the `CardTemplate` base widget in Flutter.
3. Clean up the `E:\image\eldrich horror\new` directory of unnecessary clones.
