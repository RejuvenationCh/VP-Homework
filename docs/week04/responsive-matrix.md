# H1 - responsive check
The app has two screens: storage overview and file manager.

I used the emulator at 320, 430, and 800 dp, then checked each one in landscape too. The tests also cover the long filename, empty data, 500 files, dark mode, and keyboard overlay. This gives 192 layout cases across both screens.
Keep H2 errors set to Off when checking H1.

## Results

| Screen | Test | Pass / fail | Fixes / notes |
| --- | --- | --- | --- |
| Storage overview | Small phone, 320 dp | Pass | The map and folders are stacked. The page scrolls so the bottom content is still reachable. |
| Storage overview | Large phone, 430 dp | Pass | Same layout, with more space for the map and folder rows. |
| Storage overview | Tablet, 800 dp | Pass | At 700 dp, the map goes on the left and the folders go on the right. Each side can scroll. |
| Storage overview | Landscape, all three sizes | Pass | Content is still reachable by scrolling, even on the short phone view. |
| Storage overview | 200-character item name | Pass | This screen uses folder names. The long filename is checked when opening the file manager. |
| Storage overview | Zero items | Pass | Shows an icon, a message, and Restore demo files. Empty folder rows and the tap-folder hint are hidden. |
| Storage overview | 500 items | Pass | The five folders show counts and sizes from all 500 files. The bubbles stay inside the map. |
| Storage overview | Keyboard on a short screen | Fail | The keyboard overlay check passes, but there is no text field yet, so field visibility has not been tested. |
| Storage overview | Dark mode | Pass | Text, folder colours, and the storage bar are still readable in the preview. |
| File manager | Small phone, 320 dp | Pass | Two grid columns. The selection text goes above the buttons so the bar fits. |
| File manager | Large phone, 430 dp | Pass | Three grid columns. The selection text and buttons fit on one row. |
| File manager | Tablet, 800 dp | Pass | At 700 dp, the storage info and categories move to a 250 dp sidebar. The grid scrolls beside it, and the category chips wrap. |
| File manager | Landscape, all three sizes | Pass | The header scrolls with the files on short screens. Selection and Clear still work with the keyboard overlay. |
| File manager | 200-character item name | Pass | The name uses maxLines: 1 and ellipsis. Size labels and other changing text also have line limits. The full name stays in the accessibility label. |
| File manager | Zero items | Pass | Shows an icon, a message, and Restore demo files. An empty category has Show all files. |
| File manager | 500 items | Pass | Uses SliverGrid.builder without shrinkWrap. The test checks that fewer than 100 tiles are built at once and that the last file can be reached. |
| File manager | Keyboard on a short screen | Fail | The keyboard overlay check passes, including the selection buttons, but there is no text field to test actual focus and visibility. |
| File manager | Dark mode | Pass | The filenames, size labels, selection, and Delete button are still readable in the preview. |

## Problems and fixes

| Problem | Status | Fix / note |
| --- | --- | --- |
| Selecting a file at 320 dp caused a 62 px overflow on the right. | Fixed | Below 430 dp, the selection text goes above the buttons. The buttons use Wrap, and SafeArea keeps them above the gesture bar. |
| Three columns made the small-phone tiles too narrow. | Fixed | The grid uses two columns below 360 dp of grid width, three below 700 dp, and four above that. |
| The header took up too much space on short screens. | Fixed | It now scrolls with the files. The tablet sidebar can scroll too. |
| The tablet view was just a wider phone layout. | Fixed | LayoutBuilder changes both screens to a side-by-side layout at 700 dp. |
| The empty file manager only said No media. The overview still showed empty folders. | Fixed | Added an icon, message, and action. Hid the empty folder rows and the tap-folder hint. |
| Similar-sized folders could push bubbles outside the map. | Fixed | Each bubble has a size limit for its position. A test checks that all five stay inside the map. Their areas are approximate because of these limits and the minimum touch size. |
| A category chip was partly cut off in the tablet sidebar. | Fixed | The chips wrap in the sidebar. On phones, the category row scrolls sideways. |
| The app only had a light theme. | Fixed | Added a dark colour scheme. The light colours and Source Sans 3 font stay the same. |
| There is no text field for the keyboard test. | Still missing | The overlay reduces the available height by 260 dp in portrait and 180 dp in landscape. It does not test a real text field or keyboard. |
| The emulator frame gets smaller when the window is small. | Expected | The app still receives the selected dp size. A larger Chrome window makes it easier to show in class. The controls can scroll. |

## Checks

```sh
flutter analyze
flutter test
```

The original H1 run passed 197 tests and had no analysis issues. Both web builds passed too. The latest full run after H2 passed 204 tests with clean analysis, including the 192 H1 layout cases.
The H1 cases check for Flutter errors, layout changes at the breakpoint, empty-state actions, selection and Clear, and scrolling to the last file in the 500-item data set.
I also checked the Chrome emulator and previews of the tablet overview, 500-file overview, dark file manager, long filename, and empty state.
