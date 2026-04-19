# Design Tokens

## Spacing System (4pt basis, 8pt rhythmus)

```dart
abstract final class AppSpacing {
  static const double xxs = 4;   // space_1
  static const double xs = 8;    // space_2
  static const double sm = 12;  // space_3
  static const double md = 16;   // space_4
  static const double lg = 20;   // space_5
  static const double xl = 24;  // space_6
  static const double xxl = 32;  // space_8
  static const double xxxl = 40; // space_10
  static const double touchMin = 48;
  static const double buttonHeight = 56;
}
```

### Usage Guidelines

| Token | Usage |
|-------|-------|
| `xxs` (4) | Tight spacing within components |
| `xs` (8) | Between related elements |
| `sm` (12) | List item padding |
| `md` (16) | Screen padding, card padding |
| `lg` (20) | Section spacing |
| `xl` (24) | Large section gaps |
| `xxl` (32) | Hero card padding |
| `xxx1` (40) | Major section separators |
| `touchMin` (48) | Minimum touch target |
| `buttonHeight` (56) | Standard button height |

---

## Radius System

```dart
abstract final class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;
}
```

### Usage Guidelines

| Token | Usage |
|-------|-------|
| `sm` (10) | Small chips, badges |
| `md` (14) | Text fields, medium cards |
| `lg` (18) | Primary buttons, cards |
| `xl` (24) | Score buttons, hero cards |
| `pill` (999) | Player avatar chips |

---

## Elevation System

```dart
abstract final class AppElevation {
  static const double none = 0;
  static const double low = 2;
  static const double medium = 4;
  static const double high = 8;
}
```

---

## Duration System

```dart
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration scoreFeedback = Duration(milliseconds: 100);
}
```

---

## Screen Padding Rules

```dart
// Screen padding horizontal: 16
// Screen padding top: 16-24
// Screen padding bottom with sticky controls: 24

// Card padding:
// - small: 12
// - standard: 16
// - hero card: 20-24

// List items: 8 or 12
// Large sections: 24 or 32

// Touch Targets:
// - Minimum: 48x48
// - Preferred for score buttons: 56
```
