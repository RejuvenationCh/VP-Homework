# Week 4 — H1 responsive pass

Checked on 15 October 2026. The app has two screens: Storage overview and File manager. This pass covers H1 and the two run modes; H2 and H3 are separate tasks.

The table records widget-test results. The test suite runs both screens at 320 × 568, 430 × 932, and 800 × 1280 dp, then swaps width/height for landscape. Every size is combined with normal data, a 200-character filename, zero items, 500 items, light/dark mode, and keyboard insets. All combinations include simulated safe-area padding. That makes 192 layout cases.

## Results

| Screen | Test | Result | Fix / observation |
| --- | --- | --- | --- |
| Storage overview | Small phone, 320 dp | Pass | Summary and map stack above folders; the whole page scrolls. |
| Storage overview | Large phone, 430 dp | Pass | Same stacked structure with more room for the map and folder rows. |
| Storage overview | Tablet, 800 dp | Pass | At 700 dp of available width, the map and folder list become separate, scrollable side-by-side panes. |
| Storage overview | Landscape, all three sizes | Pass | Both panes can scroll independently in the wide layout; short phone content remains reachable by scrolling. |
| Storage overview | 200-character item name | Pass | Overview shows fixed folder names, so the filename is not displayed here; opening files uses the same long-name data. |
| Storage overview | Zero items | Pass | Folder-off icon, message, and Restore demo files action. Zero-count folder rows and the tap-folder hint are hidden. |
| Storage overview | 500 items | Pass | Aggregates into five folders. Bubble diameters are capped to fit their positions; this screen does not render 500 file tiles. |
| Storage overview | Keyboard / short screen | Pass for inset; field visibility N/A | Tested with 260 dp portrait / 180 dp landscape insets. Content stays scrollable. This screen has no text field. |
| Storage overview | Dark mode | Pass | Uses a dark ColorScheme with matching surface, text, progress, and folder colours. Visual preview inspected. |
| File manager | Small phone, 320 dp | Pass | Two columns, fixed tile height, and a two-row selection bar avoid the narrow-screen overflow. |
| File manager | Large phone, 430 dp | Pass | Three columns. Selection summary and actions fit on one row. |
| File manager | Tablet, 800 dp | Pass | At 700 dp of available width, summary and categories move into a 250 dp sidebar; the file grid scrolls separately. Categories wrap in the sidebar. |
| File manager | Landscape, all three sizes | Pass | On short phones, summary/categories scroll with files rather than consuming a fixed height above them. Selection and Clear remain usable with the keyboard inset. |
| File manager | 200-character item name | Pass | Filename uses one line with ellipsis. Size text and computed labels also have finite line limits and overflow handling. Full filename remains in the tile's accessibility label. |
| File manager | Zero items | Pass | Folder-off icon, message, and Restore demo files action. An empty category offers Show all files. |
| File manager | 500 items | Pass | Uses SliverGrid.builder, with no shrinkWrap. Tests verify fewer than 100 tiles are built at once and the final file is reachable. |
| File manager | Keyboard / short screen | Pass for inset; field visibility N/A | Tested with 260 dp portrait / 180 dp landscape insets, including selection actions. This screen has no text field. |
| File manager | Dark mode | Pass | Dark theme keeps filename, size chips, selections, and error-coloured Delete legible. Visual preview inspected. |

## Layout problem log

| Problem noticed | Status | Fix / remaining limit |
| --- | --- | --- |
| Selecting a file at 320 dp caused a RenderFlex overflow of 62 pixels on the right. | Fixed | Selection summary moves above the actions below 430 dp. Actions use Wrap; SafeArea protects the gesture-bar area. The small-phone navigation/selection regression test reproduces this path. |
| The original three-column grid gave small phones unnecessarily narrow file tiles. | Fixed | Two columns below 360 dp of grid width, three below 700 dp, four above. Tiles have enough vertical room for checkbox, icon, name, and size chip. |
| Summary and categories occupied fixed space above the file grid on short screens. | Fixed | Phone header is a sliver in the same scroll view as the files. The wide sidebar also scrolls. |
| Tablet layout only stretched the original phone page. | Fixed | LayoutBuilder changes both screens to side-by-side sections at 700 dp. |
| Empty File manager only said “No media”; overview still showed zero-count folders and a tap-folder hint. | Fixed | Shared empty-state widget supplies icon, message, and action. The overview hides the irrelevant rows and hint. |
| Similar-sized folders in the 500-item fixture could place bubbles outside the map's right/bottom edges. | Fixed | Each position has a maximum diameter. A geometry test checks all five bubbles stay within the map. Bubble areas are still approximate because of minimum touch sizes and slot caps. |
| Tablet sidebar showed only part of a category chip in the horizontal strip. | Fixed | Categories wrap in the sidebar. On phones, the category strip deliberately scrolls horizontally; all categories are reachable. |
| Only a light theme existed, so system dark mode had no matching appearance. | Fixed | Added a generated dark scheme while preserving the existing light palette and Source Sans 3 font. |
| Keyboard field-visibility test has no field to exercise. | Not applicable | The harness simulates reduced space, not a functioning software keyboard. Repeat a real focus/keyboard test when a text field is added. |
| The outer device frame scales down on a small host window. | Expected harness behaviour | Layout still receives the full selected dp dimensions. Use Chrome with a large window for class demonstration; the control panel scrolls on a narrow host window. |

## Verification and limits

Run:

```sh
flutter analyze
flutter test
```

All 197 tests passed, and flutter analyze reported no issues. Both web builds passed: lib/main.dart and lib/main_emulator.dart.

The suite includes 192 layout cases plus the original cleanup/navigation test, small-phone selection regression, harness-control check, bubble-bounds check, and restore/navigation check. The layout cases fail on Flutter exceptions, including RenderFlex overflow warnings. They also check breakpoint changes, empty-state actions, selection/Clear, and lazy loading through the end of the 500-file list.

Visual checks covered a live Chrome harness, tablet overview, the 500-file overview, a dark small-phone file manager with a long name, the dark tablet file manager, and the empty file manager. These complement the automated layout checks; they are not a claim of testing on every physical device.

Native Android/iOS device checks and a classmate demonstration still need to be done. Neither screen has a text field, so the homework's field-visibility clause remains N/A. Delete/Offload affect mock items in memory; Restore demo files reloads the sample data and keeps the overview in sync.

Suggested H1 commit message, for when I commit it myself:

```text
feat: responsive menu screen with adaptive breakpoints and empty state
```
