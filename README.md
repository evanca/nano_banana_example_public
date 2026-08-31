# Nano Banana CD Cover: starter

Turn a selfie into a 2000s-style CD cover. Gemini's image model draws the
whole jewel-case spread (front, spine and back) in one call, and returns the
album identity as JSON so the sheet can print it beside the artwork.

**Start here.** You get ten Dart files that draw the sheet and nothing that
makes it work. Each widget holds the values it shows, and the four buttons call
an empty function. You add the rest.

## Run it

```
flutter pub get
flutter run -d chrome
```

You configure nothing. The starter pulls two dependencies, makes no network
calls, and runs on Android, iOS, web and desktop as-is.

## What's already here

The repo holds ten Dart files and one image. `main.dart` starts the app and
hands it `CoverPage`. The files under `features/cover/` build the sheet.

The sheet is one column, top to bottom:

```
CoverPage                  one column, capped at CoverLayout.maxSheetWidth
├── CoverMasthead          job line, headline, blurb
├── ProofPanel             the plate, holding the placeholder image
├── PlateSpecs             the specs table
│   └── SpecRow × 6        one label/value row each
└── CoverActions           the four controls
    ├── DashedAction × 3   upload a photo, take a selfie, download spread
    └── PressAction        make the cover
```

| File | What it is |
| --- | --- |
| `lib/main.dart` | Starts the app and shows `CoverPage`. It passes `MaterialApp` no theme, so you see stock Material. |
| `lib/features/cover/cover_layout.dart` | One constant: the width the sheet stops growing past. A proof sheet has a page size, and full-bleed controls on a wide monitor look broken. |
| `lib/features/cover/cover_page.dart` | The column. It scrolls, centres itself, caps its width, and stacks the four sections with fixed gaps. |
| `lib/features/cover/widgets/cover_masthead.dart` | Job line, headline and blurb. Three `Text` widgets with fixed strings. |
| `lib/features/cover/widgets/proof_panel.dart` | The bordered plate. It holds the placeholder image at a fixed 2:1. |
| `lib/features/cover/widgets/plate_specs.dart` | The specs table: a heading and six rows, each value typed into the widget. |
| `lib/features/cover/widgets/spec_row.dart` | One row of that table. Label on the left at flex 4, value right-aligned at flex 5. |
| `lib/features/cover/widgets/cover_actions.dart` | The four controls, plus `_todo()`, the empty callback all four of them call. |
| `lib/features/cover/widgets/dashed_action.dart` | The outlined secondary button. Takes a label, a leading widget and an `onPressed`, and dims itself when that is null. |
| `lib/features/cover/widgets/press_action.dart` | The large primary button. A label and a trailing aside on one row. |
| `assets/placeholder_cover.png` | A monochrome two-panel inlay wireframe, 1200x600. It stands in for a cover until step 3 generates a real one. |

No file names a colour beyond stock `Colors.black`, and no `TextStyle` sets
anything but a size. You add the theme in step 5, and this code takes it
without rework.

## Where you start

Step 1 puts a controller behind the sheet. Two files change most:
`CoverActions`, because its buttons need something to call, and `ProofPanel`,
because the plate then shows what the controller holds instead of a fixed
image.

`_todo()` in `cover_actions.dart` does nothing. All four buttons point at it.
Follow it and you see what this branch is missing.

## Steps

| Step | Branch | Adds |
| --- | --- | --- |
| **0** | **`00_starter`** | **the static sheet 📍** |
| 1 | `01_state` | state and a stub service |
| 2 | `02_photo` | the photo: picker, camera, download |
| 3 | `03_model` | the model: Firebase AI Logic and Gemini |
| 4 | `04_sheet` | the sheet: responsive layout, press log, error panel |
| 5 | `05_design` | the look: theme, fonts, animations |

Steps 3 onward need a Firebase project on the Blaze plan, because image
generation has no free tier. Step 3 walks you through the console, and
`flutterfire configure` writes the config. That file is gitignored, so you use
your own project.
