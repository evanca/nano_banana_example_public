import 'dart:math';

/// One Y2K art-direction preset, rolled at random per generation.
class CoverStyle {
  const CoverStyle({
    required this.name,
    required this.palette,
    required this.wardrobe,
    required this.typography,
    required this.treatment,
  });

  /// Short label, so a good roll can be recognised.
  final String name;

  final String palette;
  final String wardrobe;
  final String typography;
  final String treatment;

  String get direction =>
      '''
ART DIRECTION — "$name":
- Palette and setting: $palette
- Wardrobe: $wardrobe
- Typography: $typography
- Photographic treatment: $treatment''';

  static CoverStyle random([Random? random]) =>
      all[(random ?? Random()).nextInt(all.length)];

  /// One per distinct visual language.
  static const List<CoverStyle> all = [
    CoverStyle(
      name: 'Electric Blue Grunge',
      palette:
          'a saturated cyan and electric-blue monochrome wash over the whole '
          'frame, with acid-yellow and lime highlights and a streak of hot '
          'pink light cutting diagonally across the image. Grimy, sun-bleached '
          'suburban setting — concrete, chain-link, weathered paint.',
      wardrobe:
          'distressed low-slung denim, frayed cropped tops, layered chunky '
          'knits, leg warmers or slouched boots, a small pendant necklace. '
          'Deliberately scruffy and undone.',
      typography:
          'a bold rounded serif logotype in acid yellow, slightly hand-drawn, '
          'sitting in the upper corner.',
      treatment:
          'heavy colour grading pushed to the point of channel clipping, high '
          'grain, hard on-camera flash, slight motion blur at the edges.',
    ),
    CoverStyle(
      name: 'Super Electric Techno',
      palette:
          'burnt orange and rust filling the frame, overlaid with a dense '
          'collage of blueprint linework, exploded technical diagrams, grids '
          'and vector arrows in white and black.',
      wardrobe:
          'baggy nylon trackwear, oversized windbreaker, bucket hat or '
          'bandana, wraparound sport shades, cornrows or spiky bleached tips. '
          'Breakdance-crew energy.',
      typography:
          'a chunky graffiti-style wordmark with a hard outline, plus a narrow '
          'strip of tiny monospace credits running edge to edge near the top.',
      treatment:
          'flat high-contrast cut-out photography layered over the diagram '
          'collage, halftone dots, visible registration marks.',
    ),
    CoverStyle(
      name: 'Millennium White',
      palette:
          'white on white, with a soft lavender and pale-blue radial glow '
          'blooming from behind the act. Weightless, heavenly, almost no '
          'shadow.',
      wardrobe:
          'a crisp all-white suit or an iridescent white tracksuit, '
          'white-on-white layering, holographic or chrome-finish fabric, '
          'silver-tinted wraparound shades, a thick silver chain.',
      typography:
          'a chrome liquid-metal wordmark with a strong bevel and specular '
          'highlight, centred low in the frame.',
      treatment:
          'clean studio lighting, heavy backlit haze, soft bloom, glossy '
          'retouching with no visible grain.',
    ),
    CoverStyle(
      name: 'Black & White Street',
      palette:
          'pure black and white, no colour at all. Shot on a city street '
          'against ornate old architecture, wide-angle and slightly distorted, '
          'the act close to the lens.',
      wardrobe:
          'tracksuit jacket, bandana or headband, chunky watch and rings, '
          'sportswear layering. Hands thrown toward the camera.',
      typography:
          'a bold lowercase sans wordmark set tight, plus a small '
          'PARENTAL ADVISORY block in a bottom corner.',
      treatment:
          'high-contrast greyscale, wide-angle lens distortion, deep focus so '
          'the architecture stays sharp behind the act.',
    ),
  ];
}
