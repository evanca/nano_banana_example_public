/// One art-direction preset. Everything structural in the prompt stays
/// fixed; only this block rotates, and its visual attributes move together.
class StripStyle {
  const StripStyle({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.iso,
    required this.grain,
    required this.gamma,
    required this.artDirection,
    required this.makeover,
  });

  final String id;

  /// Shown on the selector and printed on the receipt, so a good roll is
  /// recognisable afterwards.
  final String label;
  final String subtitle;

  /// Nominal emulsion settings printed on the receipt.
  final int iso;
  final double grain;
  final double gamma;

  final String artDirection;

  /// The Berlin underground look every sitter gets: hair, piercings,
  /// leather and metal, matched to the era of [artDirection].
  final String makeover;

  static const silber = StripStyle(
    id: 'silber',
    label: 'SILBER',
    subtitle: 'Silver gelatin b/w',
    iso: 400,
    grain: 0.18,
    gamma: 1.8,
    artDirection:
        'Classic black and white silver gelatin print, exactly like the '
        'chemical Photoautomat booths still standing on Berlin street corners. '
        'Deep rich blacks, soft bright highlights, visible fine silver grain, '
        'slightly uneven chemical development with a faint warm paper tone. '
        'A single hard flash from just above the lens. Behind each person a '
        'plain mid-grey booth curtain with soft vertical folds.',
    makeover:
        'Berlin techno goth. Hair: a severe asymmetric undercut slicked to one '
        'side, or a bleached platinum buzz cut. Piercings: a silver septum ring, '
        'a row of small hoops climbing one ear and an eyebrow bar. Outfit: a '
        'black leather biker jacket with silver zips over a black mesh top, a '
        'heavy silver curb chain and a padlock choker around the neck.',
  );

  static const orwo = StripStyle(
    id: 'orwo',
    label: 'ORWO 84',
    subtitle: 'East Berlin colour neg',
    iso: 100,
    grain: 0.24,
    gamma: 1.4,
    artDirection:
        'Faded East German colour negative film from a 1984 booth in '
        'Prenzlauer Berg. Muted olive greens, cyan-shifted shadows, warm '
        'magenta skin tones, soft halation around highlights, slightly lifted '
        'blacks and the gentle fading of a print kept forty years in a '
        'drawer. Behind each person a beige pleated booth curtain.',
    makeover:
        'East Berlin underground punk in the last years of the wall. Hair: a '
        'spiky home-cut crop teased straight up, or a short hennaed red flat '
        'top with dark roots. Piercings: safety pins through the earlobes and a '
        'small silver nose stud. Outfit: a worn black leather jacket with silver '
        'studs on the collar over a plain black shirt, a long ball chain with a '
        'dog tag and a bicycle chain wrapped around the wrist.',
  );

  static const xerox = StripStyle(
    id: 'xerox',
    label: 'XEROX',
    subtitle: 'Kreuzberg punk copy',
    iso: 1600,
    grain: 0.42,
    gamma: 2.6,
    artDirection:
        'Kreuzberg punk fanzine, 1981. Brutal high contrast black and white '
        'that looks photocopied several times: crushed solid blacks, blown '
        'out whites, coarse toner speckle, slight ink bleed and a misaligned '
        'copier streak across one frame. Behind each person a black booth '
        'wall covered in torn flyer fragments without any readable words.',
    makeover:
        'Kreuzberg squat punk. Hair: a tall spiked mohawk or liberty spikes '
        'with shaved sides. Piercings: rings and safety pins through both ears, '
        'a lip ring and a nose ring joined to the ear by a fine chain. Outfit: '
        'a studded black leather jacket with frayed patches that carry no '
        'readable words, a ripped black shirt, a spiked metal collar and heavy '
        'chains hanging across the chest.',
  );

  static const nacht = StripStyle(
    id: 'nacht',
    label: 'NACHT',
    subtitle: 'Techno, 5 a.m.',
    iso: 3200,
    grain: 0.31,
    gamma: 2.2,
    artDirection:
        'Five in the morning after a techno night in a Berlin club. Harsh '
        'direct on-camera flash on the faces against near-black surroundings, '
        'an acid green and burnt amber colour cast from club lights, light '
        'motion trails behind moving hair, a faint sheen of sweat, deep '
        'shadows and heavy high-ISO colour grain. Behind each person the dark '
        'booth interior lit only by the flash.',
    makeover:
        'Berlin techno dancefloor at dawn. Hair: a bleached buzz cut, a sharp '
        'micro fringe or a wet slicked-back undercut. Piercings: a septum ring, '
        'several ear hoops and a bridge piercing. Outfit: a black leather '
        'harness over a sheer black mesh top, a leather choker with a silver '
        'O-ring, a chunky silver chain necklace and small black sunglasses '
        'pushed up on the head.',
  );

  static const all = [silber, orwo, xerox, nacht];
}
