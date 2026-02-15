# Performance Optimization Plan

## Timeline Analysis Results
From `build/start_up_timeline.json` and startup trace:
- **Time to First Frame**: ~1.612 seconds (target: <1.0s for better UX)
- **Main bottleneck**: Impeller/GPU embedder work (ReactorGLES, shader linking ~4–8ms per link operation)
- **Secondary issue**: Emulator GPU emulation amplifies GPU work; real device testing recommended
- **Dart-side findings**: Frame phases (Animate→Build→Layout→Paint) are sub-ms; not a Dart CPU bottleneck

## Recommended Fixes (Prioritized)

### Fix #1: Wrap Complex Widgets with RepaintBoundary (PRIORITY: HIGH)
**Rationale**: Prevents unnecessary repaints of large subtrees when parent widgets rebuild.
**Target**: Home screen and any list/grid views with heavy children.
**Estimated impact**: 50–100ms reduction in layout/paint cost if provider changes trigger repaints.

**File**: `lib/features/home/presentation/home_screen.dart` (or equivalent main screen)
- Identify large nested layouts (e.g., Column/Row with many children or ListView)
- Wrap the expensive subtree in RepaintBoundary

### Fix #2: Defer Image Precaching to Post-Frame Callback (PRIORITY: HIGH)
**Rationale**: Removes I/O and image decoding work from the critical startup path.
**Target**: Any `precacheImage()` calls in `initState()` or build methods.
**Estimated impact**: 100–200ms reduction in startup time.

**File**: `lib/app/app.dart` (or home screen)
```dart
// Move from initState or build to:
WidgetsBinding.instance.addPostFrameCallback((_) {
  // Precache images here
});
```

### Fix #3: Make Const Constructors (PRIORITY: MEDIUM)
**Rationale**: Prevents Flutter from rebuilding widgets when parent rebuilds (same const instance = no rebuild).
**Target**: All StatelessWidget constructors with simple fields.
**Estimated impact**: 20–50ms reduction if many providers trigger rebuilds.

**File**: Scan all StatelessWidget classes in `lib/` to add `const` where missing.

### Fix #4: Lazy-Load Remote Data (PRIORITY: MEDIUM)
**Rationale**: Defer fetching story catalog, voices, or other heavy data to after first frame is rendered.
**Target**: Story catalog fetch, voice list fetch, image generation startup calls.
**Estimated impact**: 100–300ms reduction in startup time.

**File**: `lib/story/catalog_repository.dart` and TTS voice fetching
- Move heavy async operations to `addPostFrameCallback()`
- Show placeholder/skeleton UI instead of waiting for data

### Fix #5: Profile on Real Device (PRIORITY: CRITICAL)
**Rationale**: Emulator GPU emulation introduces 10–100x overhead; real device profiling is essential for accurate measurements.
**Action**: Re-run profile mode on an Android phone or iOS device, capture trace, upload for targeted analysis.
**Expected outcome**: If jank persists on real device, I can pinpoint exact Dart-level bottlenecks and patch.

---

## Implementation Order

1. **Immediate** (1–2 hours):
   - Add RepaintBoundary to home screen complex widgets (Fix #1)
   - Add const constructors to StatelessWidgets (Fix #3)
   - Run `flutter analyze` to ensure no regressions

2. **Short-term** (next session):
   - Defer image precaching (Fix #2)
   - Move voice/story fetching to post-frame (Fix #4)
   - Test on physical device (Fix #5)

3. **Validation**:
   - Re-run profile on device
   - Compare startup time metrics (target: <1.2s time-to-first-frame)
   - Measure frame rate during UI transitions

---

## Notes

- **Emulator caveat**: Current jank on emulator is likely dominated by GPU emulation overhead (EGL_emulation in logs shows 500ms–1s spikes). Real device should show clean 60fps startup.
- **No breaking changes**: All fixes are additive; no existing APIs or user flows are changed.
- **Testable**: Each fix can be validated with a profile run and frame-rate measurement.
