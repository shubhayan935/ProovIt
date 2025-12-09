# Design Updates - Cal AI Inspired

## Overview
The app has been redesigned to follow Cal AI's clean, minimal design language while maintaining the ProovIt earthy color palette and brand identity.

## Key Changes

### 1. Custom App Header
**Component**: `AppHeader.swift`

- App icon + "ProovIt" branding centered at top
- Optional back button on left side
- Consistent across all main screens
- Clean white background with subtle shadow
- Replaces standard iOS navigation bar

**Usage**:
```swift
AppHeader() // For tabs
AppHeader(showBackButton: true, onBackTap: { dismiss() }) // For detail screens
```

### 2. Step Indicators
**Component**: `StepIndicator.swift`

- Numbered circular steps (1, 2, 3)
- Current step highlighted in dark
- Used in proof capture flow:
  - Step 1: Select photo
  - Step 2: Confirm photo
  - Step 3: AI verification result

**Usage**:
```swift
StepIndicator(currentStep: 1, totalSteps: 3)
```

### 3. Screen-by-Screen Updates

#### Home View
**Before**: Standard navigation title
**After**:
- Custom AppHeader at top
- Title section below header
- Cleaner card layout
- Better empty state

#### Proof Capture View
**Before**: Simple photo picker
**After**:
- Step indicator (1 of 3)
- Back button in top left
- "Perfect! Scan now." confirmation message
- Gradient border on selected image
- Contextual tips with icons
- Sticky "Next" button at bottom

**Key Elements**:
- Large camera icon when no photo selected
- Two-button layout: "Choose from Library" (dark) + "Take Photo" (light)
- TipRow components for instructions
- Smooth transitions between states

#### AI Result View
**Before**: Simple result card
**After**:
- Step indicator (3 of 3)
- X button to dismiss
- Large image preview at top
- Result in elevated card with shadow
- Confidence badge with gauge icon
- Sticky action button at bottom
- Different states: Loading → Result → Success

**Visual Hierarchy**:
1. Image preview (top)
2. Large icon (checkmark/x)
3. Bold title
4. Confidence badge
5. Explanation text
6. Action button (bottom)

#### Social Feed View
**After**:
- Custom AppHeader
- Title + subtitle section
- Cleaner card spacing
- Better empty state

#### Profile View
**After**:
- Custom AppHeader
- Larger profile icon (100x100)
- Tagline under username
- Red outlined logout button

### 4. Button Styles

**Primary Action** (Dark):
```swift
.background(AppColors.textDark)
.foregroundColor(AppColors.cardWhite)
.cornerRadius(20)
```

**Secondary Action** (Light):
```swift
.background(AppColors.cardWhite)
.foregroundColor(AppColors.textDark)
.overlay(RoundedRectangle(cornerRadius: 20).stroke(...))
```

**Destructive** (Red Outline):
```swift
.foregroundColor(.red)
.overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red.opacity(0.3)))
```

### 5. Layout Patterns

**Sticky Bottom Button**:
```swift
VStack(spacing: 0) {
    Divider()
    Button(...) { }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.lg)
        .background(AppColors.background)
}
```

**Content Padding**:
- Add `.padding(.bottom, 120)` to ScrollView content when bottom button is present
- This prevents content from being hidden under the button

**Elevated Cards**:
```swift
.background(AppColors.cardWhite)
.cornerRadius(24)
.shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
```

### 6. Typography Usage

| Element | Style | Usage |
|---------|-------|-------|
| Page titles | H1 (28pt semibold) | "Today's Goals", "Capture your proof" |
| Section titles | H2 (22pt semibold) | Goal titles, result titles |
| Card titles | H3 (18pt semibold) | "Great job!", confirmation messages |
| Body text | Body (16pt regular) | Descriptions, instructions |
| Metadata | Caption (12pt regular) | Timestamps, counts |

### 7. Icon Usage

**Main Icons** (SF Symbols):
- `flame.fill` - Streaks, activity
- `camera.circle.fill` - Photo capture
- `checkmark.circle.fill` - Success
- `xmark.circle.fill` - Failure
- `camera.viewfinder` - Camera tip
- `light.max` - Lighting tip
- `checkmark.seal` - Verification tip
- `gauge.high` - Confidence badge

**Sizes**:
- Empty states: 80x80
- Section headers: 16-20pt
- Tips/metadata: 14-18pt

### 8. Color Application

**Backgrounds**:
- Main background: `AppColors.background` (beige)
- Cards: `AppColors.cardWhite` (white)
- Overlays: `AppColors.sageGreen.opacity(0.1)`

**Text**:
- Primary: `AppColors.textDark`
- Secondary: `AppColors.textMedium`
- On dark buttons: `AppColors.cardWhite`

**Accents**:
- Success: `AppColors.primaryGreen`
- Streak icons: `AppColors.sand`
- Failure: `.red`
- Warning: `.orange`

### 9. Animations & Transitions

**Loading States**:
```swift
ProgressView()
    .tint(AppColors.primaryGreen)
    .scaleEffect(1.5)
```

**Image Borders** (Gradient):
```swift
.overlay(
    RoundedRectangle(cornerRadius: 20)
        .strokeBorder(
            LinearGradient(
                colors: [AppColors.primaryGreen.opacity(0.5),
                        AppColors.sageGreen.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 3
        )
)
```

**Shadows**:
- Light cards: `radius: 8, x: 0, y: 3`
- Elevated cards: `radius: 12, x: 0, y: 4`
- Buttons: `radius: 4, x: 0, y: 2`

### 10. Spacing System

**Vertical Stack Spacing**:
- Between major sections: `AppSpacing.xl` (24pt)
- Between related items: `AppSpacing.lg` (16pt)
- Within cards: `AppSpacing.md` (12pt)
- Between text lines: `AppSpacing.sm` (8pt)

**Horizontal Padding**:
- Screen edges: `AppSpacing.lg` (16pt)
- Wide content: `AppSpacing.xl` (24pt)
- Tight content: `AppSpacing.md` (12pt)

## Design Principles

1. **Clarity First**: Clear visual hierarchy, obvious actions
2. **Consistent Headers**: All screens use AppHeader or custom header with same structure
3. **Progressive Disclosure**: Step indicators show progress through flows
4. **Contextual Help**: Tips appear when relevant (TipRow component)
5. **Sticky Actions**: Important buttons stay accessible at bottom
6. **Earthy & Calm**: Maintain warm, natural color palette
7. **White Space**: Generous padding prevents crowding
8. **Subtle Shadows**: Depth without being heavy

## Comparison to Cal AI

### Similarities
✅ Centered branding at top
✅ Step indicators for multi-step flows
✅ Large, clear imagery
✅ Contextual instructions with icons
✅ Sticky bottom buttons
✅ Minimal navigation chrome
✅ Success confirmation messages

### ProovIt Differences
🌿 Earthy color palette (vs Cal AI's blue/white)
🌿 Rounded corners (20px vs Cal AI's sharper)
🌿 Flame/streak iconography (vs food/nutrition)
🌿 Social feed (Cal AI is single-player)
🌿 Habit verification (vs calorie counting)

## Migration Notes

### Before Updating
All screens used:
- Standard `NavigationStack` with `.navigationTitle()`
- iOS default navigation bar
- Varying button styles
- Inconsistent spacing

### After Updating
All screens now:
- Use custom `AppHeader` component
- Have `.navigationBarHidden(true)`
- Follow consistent button styles
- Use spacing constants from `AppSpacing`

### Breaking Changes
None - all changes are additive. Old views still work but use new components for consistency.

## Future Enhancements

- [ ] Add animation to step transitions
- [ ] Implement haptic feedback on success/failure
- [ ] Add pull-to-refresh on feed
- [ ] Animate streak counter increments
- [ ] Add confetti animation on goal completion
- [ ] Implement dark mode variants
- [ ] Add swipe gestures for navigation

## Testing Checklist

- [x] All screens display AppHeader correctly
- [x] Step indicators show correct step
- [x] Back buttons work on all detail screens
- [x] Bottom buttons stay visible when keyboard appears
- [x] Empty states display properly
- [x] Loading states show progress indicator
- [x] Success/failure states use correct colors
- [x] Images scale correctly on different devices
- [x] Text remains readable on all screen sizes
- [x] Buttons are tappable (44x44 minimum)

---

**Design Updated**: December 2025
**Inspiration**: Cal AI
**Color Palette**: ProovIt Earthy Theme
**Status**: ✅ Complete
