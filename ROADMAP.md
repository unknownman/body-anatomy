<p align="center">
  <img src="https://img.shields.io/badge/status-active-brightgreen?style=for-the-badge" alt="Status"/>
  <img src="https://img.shields.io/badge/phase-1%20Interactive%20Tap-blue?style=for-the-badge" alt="Phase"/>
</p>

<h1 align="center">🗺️ body_anatomy_viewer — Roadmap</h1>

<p align="center">
  <strong>A phased development plan for evolving from a static CustomPainter anatomy renderer into a fully interactive, multi-system medical & fitness visualization tool.</strong>
</p>

---

## 📍 Vision

`body_anatomy_viewer` is built from the ground up on raw vector math and Flutter's `CustomPainter` — no SVGs, no assets, no external dependencies. This roadmap charts the journey from today's highlight-ready viewer to an interactive, layer-switchable anatomy platform that supports muscular, skeletal, cardiovascular, and nervous system overlays with smooth performance across mobile, desktop, and web.

---

## 📐 Versioning Strategy

| Release | Focus | Target |
|---------|-------|--------|
| `v0.2.0` | Interactive tap & selection | Nearest milestone |
| `v0.3.0` | Visual polish & theming | Near-term |
| `v0.4.0` | Skeletal system layer | Medium-term |
| `v0.5.0` | Vascular & nervous layers | Medium-term |
| `v1.0.0` | Stable, tested, published | Long-term |

---

## 🎯 Phase 1 — Interactive Tap Detection

> **Goal:** Turn the viewer from a passive renderer into a tappable, interactive anatomy map.  
> **Est. complexity:** Medium — requires refactoring painters to expose hit regions + wiring gesture handling.

### TODO

- [ ] **Interactive Muscle Selection**
  Implement per-muscle tap detection by wrapping each `CustomPaint` in a `GestureDetector`. On tap, compute the local offset and iterate over every highlighted muscle path calling `Path.contains(Offset)`. The first match wins.

  *Implementation sketch:*
  ```dart
  // Each painter provides a hit-test map
  Map<String, Path> get hitRegions;

  // GestureDetector onTap uses it
  void _handleTapUp(TapUpDetails details) {
    final localPos = _renderBox.globalToLocal(details.globalPosition);
    for (final entry in _painter.hitRegions.entries) {
      if (entry.value.contains(localPos)) {
        onMuscleTap?.call(entry.key);
        return;
      }
    }
  }
  ```

- [ ] **Interactive Callbacks**
  Add `onMuscleTap(String muscleKey)` and `onMuscleLongPress(String muscleKey)` callbacks to `BodyAnatomyViewer`. Also expose `selectedMuscles` and `onSelectionChanged` for controlled / uncontrolled usage patterns.

- [ ] **Native Multi-Selection State**
  Build selection state management directly into the widget:
  - Tap a muscle → select it (append to selection set).
  - Tap the same muscle again → deselect it.
  - Support `selectionMode: SelectionMode.single | SelectionMode.multiple`.
  - Highlight selected muscles with a distinct stroke or glow automatically.

---

## 🎨 Phase 2 — Visual Polish & Customization Extensions

> **Goal:** Make the viewer production-ready for light and dark UIs, add rich fill styles, and let users zoom into fine details.  
> **Est. complexity:** Medium.

### TODO

- [ ] **Gradated & Shaded Muscle Fills**
  Extend the `highlightedMuscles` map to accept a `Paint` object instead of a flat `Color`, or add a `muscleShaders` parameter that maps muscle keys to `Gradient` or `Shader` instances. This enables:
  - Heatmaps for muscle activation / fatigue.
  - Soreness intensity visualization.
  - Layered shading for 3D depth effect (e.g., radial gradient from center of each muscle).

  *API proposal:*
  ```dart
  BodyAnatomyViewer(
    muscleShaders: {
      'quadriceps_left': RadialGradient(colors: [Colors.red, Colors.orange]),
    },
  )
  ```

- [ ] **Dark Mode Styling**
  Detect the `Theme.brightness` from context and automatically switch:
  - Silhouette fill → dark grey (`Color(0xFF2A2A2A)`) on dark, light grey on light.
  - Background → `Color(0xFF1A1A1A)` on dark.
  - Muscle gap strokes → subtle dark separators instead of white.
  - Highlighted muscles → slightly desaturated for eye comfort.
  - Expose `lightTheme` and `darkTheme` override parameters for custom color schemes.

- [ ] **Advanced Zoom & Pan**
  Wrap the three-panel `Row` in an `InteractiveViewer` with:
  - Min/max scale bounds (1.0x – 5.0x).
  - Double-tap to zoom on a specific muscle (center the tapped region).
  - Two-finger pan and pinch-to-zoom.
  - Boundary clamping so users can't scroll the body off-screen.
  - **Important:** Sync zoom level across all three views so Front / Side / Back zoom and pan in lockstep.

---

## 🦴 Phase 3 — Additional Anatomical Systems (Multi-Layer Architecture)

> **Goal:** Add hierarchical body system layers (skeletal → cardiovascular → nervous) with toggling and cross-fade transitions.  
> **Est. complexity:** High — brand-new painters, data models, and layer management.

### TODO

- [ ] **Skeletal System Layer**
  Design and implement a `SkeletalPainter` that draws vector paths for:
  - Skull (cranium + mandible profile)
  - Cervical / Thoracic / Lumbar spine (simplified segmented column)
  - Ribcage (12 pairs in simplified contour)
  - Pelvis (ilium, ischium, pubis outline)
  - Clavicles & Scapulae
  - Humerus, Radius, Ulna (upper & lower arm)
  - Femur, Tibia, Fibula (upper & lower leg)
  - Hands and feet (simplified phalanges)

  Add a `BodySystem` enum:
  ```dart
  enum BodySystem { muscular, skeletal, cardiovascular, nervous, combined }
  ```

  Refactor `BodyAnatomyViewer` to accept:
  ```dart
  BodyAnatomyViewer(
    activeSystems: {BodySystem.muscular, BodySystem.skeletal},
  )
  ```

- [ ] **Cardiovascular & Nervous Layers**
  Add simplified vector overlays for:
  - **Heart** (stylized silhouette in chest cavity).
  - **Major arteries / veins** (aorta, vena cava, carotid, femoral — as tapered strokes).
  - **Major nerves** (spinal cord, sciatic nerve, brachial plexus — as dashed lines).

  These layers intentionally stay schematic (not fully anatomical) to keep path complexity manageable and performance snappy.

- [ ] **Toggleable Layer Views**
  - Build a `BodyLayerController` class with `ValueNotifier<bool>` for each layer.
  - Provide a built-in layer legend / toggle UI or expose the controller so consumers can build their own.
  - Implement cross-fade transitions between system toggles using `AnimatedOpacity` or a custom `TweenAnimationBuilder<double>` that lerps the alpha of each painter.

---

## ⚡ Phase 4 — Performance Optimization & State Management

> **Goal:** Keep the renderer buttery-smooth at 60 FPS on mobile and 120 FPS on desktop/web, even with multiple active layers and complex morphing.  
> **Est. complexity:** Medium — profiling, caching, selective repaints.

### TODO

- [ ] **Path Caching**
  Each painter currently rebuilds every `Path` from scratch on every `paint()` call. Introduce a `PathCache` per painter instance:
  - Key: `(metrics.hashCode, activeSystems.hashCode)`.
  - Value: `Map<String, Path>` of all computed paths.
  - Invalidate only when `BodyMetrics` or active system flags actually change.
  - For skeletal paths (which don't morph), cache them indefinitely.

  ```dart
  class _PathCache {
    final Map<int, Map<String, Path>> _cache = {};
    Map<String, Path>? get(int key) => _cache[key];
    void set(int key, Map<String, Path> paths) => _cache[key] = paths;
  }
  ```

- [ ] **Repaint Minimization**
  Audit every `CustomPainter` subclass:
  - Override `shouldRepaint` to compare all relevant fields deeply.
  - Use `==` and `hashCode` on `BodyMetrics`, `highlightedMuscles`, and system flags.
  - Wrap `CustomPaint` in a `RepaintBoundary` so that scrolling or animating outside the viewer doesn't trigger repaints of the anatomy canvases.
  - Consider splitting each layer into its own `CustomPaint` in a `Stack` so toggling a layer off doesn't repaint the others.

- [ ] **Web CanvasKit Optimization**
  - Test on both `--web-renderer=canvaskit` and `--web-renderer=html`.
  - Profile with `flutter run --profile -d chrome` and identify slow `Path` operations.
  - Replace `Path.combine()` operations with pre-combined cached paths (Path.combine is expensive on CanvasKit).
  - Use `Canvas.clipPath` sparingly; prefer pre-clipped cached paths.
  - Add a `useHardwareAcceleration` flag that falls back to simplified path rendering on low-end WebGL contexts.

---

## 🧪 Phase 5 — Testing, Documentation & Automation

> **Goal:** Ship with confidence. Golden tests, interactive demos, and CI that catch regressions before they reach users.  
> **Est. complexity:** Medium — tooling setup + creating reference images.

### TODO

- [ ] **Golden UI Tests**
  Write `flutter test --update-goldens`–compatible golden tests for:
  - **Front, Side, Back** views each at:
    - Slim (height: 180cm, weight: 65kg)
    - Athletic (height: 175cm, weight: 75kg)
    - Muscular (height: 180cm, weight: 90kg)
    - Overweight (height: 170cm, weight: 95kg)
  - Each golden test renders the full `BodyAnatomyViewer` at a fixed size and compares against a reference image.
  - Run `flutter test --tags golden` on CI (tagged so unit tests run separately).
  - Add a `// TODO: regenerate goldens` workflow that can be triggered manually.

  *Test structure:*
  ```dart
  testWidgets('Front view - Athletic build - golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BodyAnatomyViewer(
          metrics: BodyMetrics(gender: Gender.male, heightCm: 175, weightKg: 75, ...),
          viewHeight: 400,
        ),
      ),
    );
    await expectLater(find.byType(BodyAnatomyViewer), matchesGoldenFile('goldens/athletic_front.png'));
  });
  ```

- [ ] **Interactive Web Demo (GitHub Pages)**
  Build and deploy a `gh-pages` branch with a full interactive demo:
  - Sliders for every `BodyMetrics` field (height, weight, chest, waist, hip, collar, etc.).
  - Gender toggle (Male / Female / Non-binary with adjustable proportions).
  - Clickable muscle map — tap a muscle on the rendered body to see its name and highlight it.
  - Layer toggles (muscular / skeletal / combined) once Phase 3 is complete.
  - Responsive layout: stacked panels on mobile, side-by-side on desktop.
  - Deploy via GitHub Actions on every push to `main`.

  *Suggested tech:* Pure Flutter Web + GitHub Pages deploy action.

- [ ] **Continuous Integration (CI)**
  Create `.github/workflows/ci.yml` that runs on every PR and push to `main`:

  ```yaml
  name: CI
  on: [push, pull_request]
  jobs:
    analyze:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: subosito/flutter-action@v2
        - run: flutter analyze
    format:
      run: dart format --set-exit-if-changed .
    test:
      run: flutter test
    golden:
      run: flutter test --tags golden
  ```

---

## 🌟 Stretch Goals (No Timeline)

These are big, exciting ideas that don't have a firm place in the roadmap yet but are absolutely worth exploring.

- **Animation / Morphing Transitions:** Smoothly animate between two `BodyMetrics` configurations (e.g., "before / after" transformation) using `Tween<BodyMetrics>` and `Lerp` on the painter.
- **Body Fat % Visualization:** Use the `BodyMetrics` to estimate body fat and render a subcutaneous fat layer as a semi-transparent overlay.
- **Left Side Profile:** Add a `showLeftSide: bool` parameter to render the mirror of the side view.
- **Label Overlays:** Auto-generate leader lines and text labels for each visible muscle / bone, ideal for educational diagrams.
- **Accessibility:** Add `Semantics` nodes for every muscle region so screen readers can announce which muscle was tapped.
- **Localization (i18n):** Support muscle key display names in multiple languages (EN, ES, FR, DE, JA, ZH).

---

## 🧭 How to Contribute

1. Check the **Phase 1** issues (tagged `good first issue`) if you're new to the project.
2. Comment on an issue you'd like to work on so others know it's claimed.
3. Follow the existing code conventions (look at `FrontBodyPainter` as a reference).
4. Run `dart analyze` and `flutter test` before submitting.
5. Open a PR with a clear description of what changed and why.

> **Questions or ideas?** Open a [Discussion](https://github.com/your-org/body_anatomy_viewer/discussions) — every suggestion helps shape the roadmap.

---

<p align="center">
  <sub>Made with ❤️ for the Flutter community</sub>
</p>
