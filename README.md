<p align="center">
  <img src="https://img.shields.io/badge/pub-0.1.0-blue?style=for-the-badge&logo=dart" alt="Pub Version"/>
  <img src="https://img.shields.io/badge/Flutter-3.0+-blue?style=for-the-badge&logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.0+-blue?style=for-the-badge&logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge" alt="MIT"/>
  <img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Web-lightgrey?style=for-the-badge" alt="Platform"/>
</p>

<h1 align="center">🧬 body_anatomy_viewer</h1>

<p align="center">
  <strong>A Flutter package for rendering 2D vector-style human anatomy with dynamic proportional morphing and interactive muscle highlighting.</strong>
</p>

<p align="center">
  Built entirely with <code>CustomPainter</code> — no image assets, no SVGs, no external dependencies. Every silhouette, muscle contour, and joint is computed in real time from a virtual canvas, making the body adapt naturally to the provided <code>BodyMetrics</code>.
</p>

---

## ✨ Features

| Feature | Description |
|---|---|
| 🎨 **Responsive Geometry** | Fully vector-based artwork rendered via `CustomPainter`. No bitmaps, no SVGs, zero asset overhead. |
| 📐 **Proportional Morphing** | Body proportions shift dynamically based on gender, height, weight, chest, waist, hips, and collar width. |
| 🧠 **Highly Accurate Anatomy** | Realistically splayed fingers, splayed feet, natural muscle contours, and puzzle-piece muscle borders. |
| 🔦 **Dynamic Highlights** | Highlight individual muscle groups with custom `Color` values. Clean white gaps between muscles create a clear anatomical map. |
| 👁️ **Three Views** | Front, Side, and Back views rendered side-by-side in a single widget. |

---

## 📦 Installation

### CLI

```bash
flutter pub add body_anatomy_viewer
```

### Manual

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  body_anatomy_viewer: ^0.1.0
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:body_anatomy_viewer/body_anatomy_viewer.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Body Anatomy')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BodyAnatomyViewer(
            metrics: const BodyMetrics(
              gender: Gender.female,
              heightCm: 168,
              weightKg: 60,
              chestCm: 95,
              waistCm: 65,
              hipCm: 100,
              collarCm: 38,
            ),
            highlightedMuscles: {
              'rectus_abdominis_upper_left': Colors.pink,
              'rectus_abdominis_upper_right': Colors.pink,
              'rectus_abdominis_mid_left': Colors.pinkAccent,
              'rectus_abdominis_mid_right': Colors.pinkAccent,
              'rectus_abdominis_lower_left': Colors.deepPurple,
              'rectus_abdominis_lower_right': Colors.deepPurple,
            },
            viewHeight: 360,
          ),
        ),
      ),
    );
  }
}
```

---

## 🗺️ Muscle Key Reference

Pass any of the following keys as entries in `highlightedMuscles` together with a `Color` value to paint that muscle group.

---

### 🔵 FRONT VIEW

#### Neck
| Key | Side |
|-----|------|
| `sternocleidomastoid_left` | Left |
| `sternocleidomastoid_right` | Right |

#### Torso
| Key | Side |
|-----|------|
| `pectoral_left` | Left |
| `pectoral_right` | Right |
| `rectus_abdominis_upper_left` | Left upper |
| `rectus_abdominis_upper_right` | Right upper |
| `rectus_abdominis_mid_left` | Left mid |
| `rectus_abdominis_mid_right` | Right mid |
| `rectus_abdominis_lower_left` | Left lower |
| `rectus_abdominis_lower_right` | Right lower |
| `serratus_anterior_left` | Left |
| `serratus_anterior_right` | Right |
| `obliques` | Both |

> **Alias:** `abdominals` highlights all six abdominal segments at once.

#### Shoulders & Arms
| Key | Side |
|-----|------|
| `deltoid_left` | Left |
| `deltoid_right` | Right |
| `biceps_left` | Left |
| `biceps_right` | Right |
| `brachioradialis_left` | Left |
| `brachioradialis_right` | Right |
| `forearm_flexor_left` | Left |
| `forearm_flexor_right` | Right |

#### Legs
| Key | Side |
|-----|------|
| `quadriceps_rectus_femoris_left` | Left |
| `quadriceps_rectus_femoris_right` | Right |
| `quadriceps_vastus_lateralis_left` | Left outer |
| `quadriceps_vastus_lateralis_right` | Right outer |
| `quadriceps_vastus_medialis_left` | Left inner |
| `quadriceps_vastus_medialis_right` | Right inner |
| `sartorius_left` | Left |
| `sartorius_right` | Right |
| `tibialis_anterior_left` | Left |
| `tibialis_anterior_right` | Right |
| `gastrocnemius_left` | Left calf |
| `gastrocnemius_right` | Right calf |

> **Alias:** `quadriceps_left` / `quadriceps_right` highlights all three quadriceps segments on that side at once.

---

### 🟠 BACK VIEW

#### Neck & Upper Back
| Key | Side |
|-----|------|
| `trapezius` | Both |

#### Shoulder Blades & Delts
| Key | Side |
|-----|------|
| `deltoid_left` | Left |
| `deltoid_right` | Right |
| `infraspinatus_left` | Left |
| `infraspinatus_right` | Right |
| `teres_major_left` | Left |
| `teres_major_right` | Right |

#### Mid & Lower Back
| Key | Side |
|-----|------|
| `latissimus_dorsi_left` | Left |
| `latissimus_dorsi_right` | Right |
| `erector_spinae_left` | Left |
| `erector_spinae_right` | Right |

#### Hips & Legs
| Key | Side |
|-----|------|
| `gluteus_maximus_left` | Left |
| `gluteus_maximus_right` | Right |
| `biceps_femoris_left` | Left hamstring |
| `biceps_femoris_right` | Right hamstring |
| `semitendinosus_left` | Left inner hamstring |
| `semitendinosus_right` | Right inner hamstring |
| `gastrocnemius_lateral_left` | Left lateral calf |
| `gastrocnemius_lateral_right` | Right lateral calf |
| `gastrocnemius_medial_left` | Left medial calf |
| `gastrocnemius_medial_right` | Right medial calf |

---

### 🟢 SIDE VIEW (Right Profile)

| Key | Area |
|-----|------|
| `deltoid_right` | Shoulder |
| `pectoral_right` | Chest |
| `abdominals` | Abs |
| `obliques` | Oblique |
| `gluteus_maximus_right` | Glute |
| `quadriceps_right` | Front thigh |
| `biceps_femoris_right` | Hamstring |
| `gastrocnemius_right` | Calf |

---

## ⚙️ API Reference

### `BodyMetrics`

Configuration object defining the subject's body dimensions. Every measurement is in centimeters except `weightKg`.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `gender` | `Gender` | `Gender.male` | Biological sex (`male` / `female`) |
| `heightCm` | `double` | `170.0` | Total height in cm |
| `weightKg` | `double` | `70.0` | Body weight in kg |
| `chestCm` | `double` | `95.0` | Chest circumference |
| `waistCm` | `double` | `80.0` | Waist circumference |
| `highHipCm` | `double` | `90.0` | High hip (upper hip) circumference |
| `hipCm` | `double` | `95.0` | Full hip circumference |
| `collarCm` | `double` | `42.0` | Collar / neck base circumference |
| `frontSleeveCm` | `double` | `60.0` | Front sleeve length |
| `inseamCm` | `double` | `78.0` | Inseam length |

**Computed getters:**

| Getter | Formula |
|--------|---------|
| `shoulderWidth` | `collarCm * 1.5` |
| `waistToHipRatio` | `waistCm / hipCm` |
| `bmi` | `weightKg / (heightM)²` |

### `BodyAnatomyViewer`

The main widget. Renders Front, Side, and Back panels in a horizontal row.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `metrics` | `BodyMetrics` | **required** | Body dimensions to render |
| `highlightedMuscles` | `Map<String, Color>` | `const {}` | Muscles to paint in custom colors |
| `viewHeight` | `double` | `360` | Total widget height in logical pixels |

---

## 🧪 Running the Example

```bash
cd example
flutter run
```

The example app demonstrates four pre-configured body types: **Hourglass (Female)**, **Muscular Male**, **Slim / Lean**, and **Overweight** — each with different highlighted muscle groups.

---

## 🤝 Contributing

Contributions are welcome and appreciated!

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/my-feature`
3. **Commit** your changes: `git commit -m 'Add some feature'`
4. **Push** to the branch: `git push origin feature/my-feature`
5. **Open** a Pull Request

Please make sure your code follows the existing style conventions and runs cleanly with `dart analyze`.

---

## 📄 License

```
MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<p align="center">
  Made with ❤️ for the Flutter community
</p>
