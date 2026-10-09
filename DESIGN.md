---
name: Berlin Fotoautomat
colors:
  surface: '#121316'
  surface-dim: '#121316'
  surface-bright: '#38393c'
  surface-container-lowest: '#0d0e11'
  surface-container-low: '#1b1b1f'
  surface-container: '#1f1f23'
  surface-container-high: '#292a2d'
  surface-container-highest: '#343538'
  on-surface: '#e3e2e6'
  on-surface-variant: '#c7c9ae'
  inverse-surface: '#e3e2e6'
  inverse-on-surface: '#2f3034'
  outline: '#90937a'
  outline-variant: '#464834'
  surface-tint: '#bad206'
  primary: '#ffffff'
  on-primary: '#2d3400'
  primary-container: '#d6ef33'
  on-primary-container: '#5e6b00'
  inverse-primary: '#586400'
  secondary: '#ffb5a1'
  on-secondary: '#601400'
  secondary-container: '#ff5626'
  on-secondary-container: '#541000'
  tertiary: '#ffffff'
  on-tertiary: '#30312e'
  tertiary-container: '#e3e2df'
  on-tertiary-container: '#646562'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d6ef33'
  primary-fixed-dim: '#bad206'
  on-primary-fixed: '#191e00'
  on-primary-fixed-variant: '#424b00'
  secondary-fixed: '#ffdbd1'
  secondary-fixed-dim: '#ffb5a1'
  on-secondary-fixed: '#3b0900'
  on-secondary-fixed-variant: '#882000'
  tertiary-fixed: '#e3e2df'
  tertiary-fixed-dim: '#c7c6c3'
  on-tertiary-fixed: '#1b1c1a'
  on-tertiary-fixed-variant: '#464744'
  background: '#121316'
  on-background: '#e3e2e6'
  surface-variant: '#343538'
typography:
  headline-xl:
    fontFamily: Space Grotesk
    fontSize: 56px
    fontWeight: '700'
    lineHeight: 60px
    letterSpacing: -0.03em
  headline-xl-mobile:
    fontFamily: Space Grotesk
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 36px
    fontWeight: '600'
    lineHeight: 42px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 30px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Geist
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
    letterSpacing: -0.01em
  body-md:
    fontFamily: Geist
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: 0em
  body-sm:
    fontFamily: Geist
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0em
  label-lg:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 18px
    letterSpacing: 0.04em
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.06em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.08em
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 2rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style

This design system channels the mechanical grit, industrial romance, and raw analog immediacy of an authentic Berlin street *Fotoautomat* caught between an all-night underground techno club and wet pavement. It merges utilitarian hardware brutalism with high-performance modern web software.

### Tone & Personality
- **Raw, Industrial, & Unforgiving:** Heavy cast-metal frames, machined tolerances, zero artificial gloss, and authentic mechanical behavior.
- **Analog Immediacy:** Emphasizes real-time capture, optical framing, thermal receipt printouts, physical relays, and explosive Xenon flashes.
- **Berlin Underground Edge:** Functional, stark, disciplined, yet charged with subcultural kinetic energy.

### Target Audience & Emotional Arc
Aimed at digital natives, clubbers, photographers, and creatives fatigued by sterile corporate minimalism. The interface elicits tactile satisfaction, spontaneous urgency, and the nostalgic thrill of waiting for a wet chemical photostrip to slide down a rusted metal dispenser chute.

## Colors

The color system is rooted in deep cast-metal charcoals and high-contrast photochemical signaling. Dark mode is the absolute default, mimicking the interior of a darkened booth enclosure.

### Functional Palette
- **Cast Metal Base (`neutral`, `#121316`):** Deep carbon substrate for panels, screen curtains, and base structural shells.
- **Chassis Grey (`#1A1C20` / `#25282E`):** Layered sheet metal surfaces, recessed camera viewports, and machine housings.
- **Acid Phosphor (`primary`, `#E5FF44`):** High-voltage warning indicators, active camera viewports, countdown numbers, and primary actuation triggers.
- **Amber Filament (`secondary`, `#FF4400`):** Analog bulb alerts, optical recording tallies, heat warnings, and mechanical stops.
- **Matte Chemical White (`tertiary`, `#F3F2EE`):** The bleached base for photochemical photostrips, thermal ticket printouts, and primary high-contrast typography.
- **Halftone Silver (`#8A8D93`):** Technical notations, sensor telemetry, frame coordinates, and peripheral status readings.

## Typography

Typography establishes an austere dialogue between modern engineering and mechanical instrumentation.

### Font Roles
- **Headlines (`Space Grotesk`):** Aggressive, geometric neo-grotesque architecture. Used for structural station branding, state titles, and oversized numerical countdown digits.
- **Body (`Geist`):** Hyper-focused, disciplined neutral sans-serif designed for flawless readability on screens, diagnostic instructions, and user guidance.
- **Labels & Telemetry (`JetBrains Mono`):** Fixed-pitch industrial monospace applied to frame indexes (`FRAME: 03/04`), exposure times, hardware specs, status telemetry, and timestamp stamps.

### Micro-Typography Styling
- Monospace tags should be rendered in uppercase with positive letter spacing (`0.06em` to `0.08em`).
- Numerical sequences must use tabular lining figures to maintain grid integrity during real-time countdown updates.

## Layout & Spacing

The layout model mimics an industrial equipment chassis: rigid, structured, and modular. It relies on a 12-column structured grid for desktop workstations and a dense 4-column chassis on mobile devices.

### Layout Principles
- **Chassis Structure:** Outer margins establish an architectural "bezel" surrounding the live digital workspace. Viewport controls and live stream frames sit strictly flush against structural guide lines.
- **Modular Bays:** Controls, photo strip feeds, and live optical scopes reside in dedicated visual bays separated by explicit structural panel seams rather than soft whitespace.
- **Viewport Locking:** During active photo capture, auxiliary panels collapse to lock user focus directly into the 1:1 or 4:5 camera viewport console.

## Elevation & Depth

Depth is not achieved via soft dropshadows or floating blurred cards; it is constructed through physical industrial fabrication: stamped panels, mechanical bezels, tactile insets, and explosive optical light emission.

### Surface Tiers
1. **Base Chassis (`#121316`):** The outermost structural machine housing.
2. **Machined Panels (`#1A1C20`):** Fastened metal control modules featuring a `1px` high-contrast outer border (`#2D3139`) with hard inner corner insets.
3. **Recessed Optics / Viewfinders (`#090A0B`):** Countersunk apertures with a crisp `2px` inset line (`#000000`) and high-contrast framing reticles.
4. **Physical Media Overlay (`#F3F2EE`):** Chemical photo paper strips and thermal paper items sit squarely above the chassis with a stark, zero-blur hard projection offset (`4px 4px 0px rgba(0, 0, 0, 0.9)`).

### Optical Light & Xenon Flash
Elevation and priority spikes occur optically:
- **Xenon Discharge:** An instant `100ms` total-white screen saturation (`#FFFFFF`) with zero blur followed by a `400ms` phosphor decay.
- **Active Indicators:** High-intensity Acid Phosphor (`#E5FF44`) and Amber (`#FF4400`) emit a crisp, narrow-radius light field without ambient mud.

## Shapes

The design system enforces zero roundedness (`0px`) across all primary UI surfaces, panels, buttons, and camera frames.

### Geometric Rules
- **Pure Orthogonal Geometry:** Sharp corners reflect shear-cut sheet metal, machined aluminum framing, and razor-cut photochemical film edges.
- **Chamfered Accents:** Critical action elements (such as the primary mechanical shutter activator or bay indicators) may utilize a rigid 45-degree corner notch (`clip-path: polygon(...)`) sized at `6px` or `8px` to reinforce stamped military/industrial hardware aesthetics.
- **Perforations & Notches:** Photostrip dividers and ticket separators use square-punched or serrated triangular repeat patterns.

## Components

### Buttons & Actuators
- **Primary Trigger (Shutter):** Heavy industrial actuation block. High-contrast Acid Phosphor (`#E5FF44`) background with black monospace text (`#121316`), zero radius, 2px border in `#FFFFFF`. Hover triggers an invert or intense amber shift (`#FF4400`). Active state depresses physically by `2px 2px` with zero travel lag.
- **Secondary Toggle:** Cast-metal base (`#1A1C20`) with 1px border (`#33373E`). Monospace uppercase text with an embedded LED dot that switches from inert slate (`#494D55`) to bright neon phosphor upon engagement.

### Optical Viewfinder & Reticle
- **Camera Frame:** Sharp-bordered container flanked with 4-corner targeting brackets (`L`-shaped markers, 2px stroke).
- **Rule-of-Thirds & Center Crosshairs:** Monospaced coordinate markers (`+`, `X: 00`, `Y: 00`) rendered in translucent white (`rgba(243, 242, 238, 0.4)`).
- **Status OSD (On-Screen Display):** Live tally light (blinking red circle, 1Hz), exposure index, and countdown overlays set in oversized `Space Grotesk`.

### Photostrip & Film Carrier
- **The Strip Container:** Vertical 4-frame strip rendered in Matte Paper White (`#F3F2EE`) with authentic 12px frame separation borders.
- **Thermal Print Receipts:** Monospaced data printout at the strip footer displaying Unix timestamp, machine ID (`AUTOMAT_BER_09`), and grain contrast metrics.
- **Print Grain & Halftone:** Optional SVG dither noise filter applied to simulate silver halide chemical reproduction.

### Input Fields & Selectors
- **Machined Text Inputs:** Recessed carbon field (`#0E0F11`) with a continuous 1px border (`#2A2D35`). Focused state locks into a solid Acid Phosphor (`#E5FF44`) border with a non-blinking solid block cursor.
- **Rotary/Segmented Selectors:** Square segmented controls locked together like stamped switches. Active segment takes `#E5FF44` fill with `#121316` typography.

### Checkboxes & Binary Relays
- **Physical Relay Toggles:** Square 16px indicator with no radius. Unchecked shows a faint inner crosshair (`+`); checked state snaps to an immediate solid Acid Phosphor (`#E5FF44`) fill with a solid black dot in the center.

### Audio-Visual Feedback Specs
- Every interactive actuation must pair with low-latency click/clack mechanical relay sound design and optical state snapping. No gradual ease-in-out transitions over 150ms; states toggle with instant mechanical precision (0ms to 75ms linear transitions).