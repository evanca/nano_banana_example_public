import 'cover_styles.dart';

/// Builds the prompt for one CD inlay wrap. Only [style] varies per run.
String buildCoverPrompt(CoverStyle style) =>
    '''
You are art-directing an early-2000s hip-hop / alternative CD album.

Language rule, which overrides everything below it.

Keep the voice of the era. Its slang, its stylised spelling, its swagger and
its bravado are the point: names like "Tha Northside Click", "Blueprint Lyfe"
or "Concrete Rosez" are exactly right, and so are track titles that sound like
they came off a real sleeve in 2001.

What must never appear, in the JSON or painted into the artwork: slurs of any
kind, racial or ethnic epithets, profanity, sexual content, and anything
demeaning to any group of people. This holds even though records of the era
often used them. If a name or title you are about to write would break it,
pick another one in the same voice.

Start by looking at the supplied photo and counting the people in it. Those
people are "the act":
- one person — a solo artist.
- two or more — a group, and every single one of them is a member.
Never drop a person, never invent an extra one, and never replace anyone with
a different face. If the photo shows four people, the artwork shows those same
four people.

First invent the album identity and report it as a JSON object inside a
```json fenced code block, with exactly these keys:
  "artistName": string — the name of the act, in the style of the era. A stage
      name if the photo shows one person, a group name if it shows several.
  "albumTitle": string — short, Y2K flavour
  "catalogNumber": string — a catalogue number like "745.98.02"
  "label": string — an invented record label

Then generate the complete printed inlay artwork as a single image, inventing
10-12 track titles with running times and typesetting all of it into the
artwork itself. Keep every face from the photo clearly recognisable as itself.

The artist name and album title painted into the artwork must match the JSON
above character for character — they are shown side by side.

Every piece of text in the artwork must be one of those invented strings.
Never paint instruction words, field labels or placeholders such as "artist
name", "album title" or "track list" into the image.

Produce one single wide landscape image, 2:1 aspect ratio, laid out as a
two-panel album inlay:

- Right half = the front cover. The act posed as the recording artist,
  confident and direct-to-camera. If the act is a group, arrange them as a
  posed group shot — every member in frame, faces unobscured, at a scale
  where each is clearly identifiable, with the composition reading as one
  crew rather than separate cut-outs.
  Wardrobe — this is important: completely replace the clothing worn in the
  supplied photo, for every person in it. Do not keep the original garments,
  their colours, their patterns or their necklines. Nothing anyone is wearing
  in the source photo should survive into the artwork. Dress the act according
  to the art direction below; for a group, style them as one crew in that same
  direction, varying the individual garments so they look styled together
  rather than uniformed.
  Set the act's name and the album title on this panel as designed lettering.
  Print only those two invented strings — never the words "artist name",
  "album title", or any other field label or placeholder. Spell every word
  correctly and keep the lettering clearly legible.
- Left half = the back cover, carrying the printed track list: 10-12 numbered
  tracks, each with a title and a running time in m:ss, set in small clean
  type that stays readable against the artwork. Add a record label name and
  a small copyright line at the bottom. No faces on this half — the artwork
  continues behind the type, calm enough to read against.
  The album title and the act's name must be spelled identically on both
  halves.

The two halves must read as one continuous image. The background must flow
unbroken across the centre fold, with no seam, no tonal step and no visible
join.

${style.direction}

Commit fully to this art direction: the palette, wardrobe, lettering and film
treatment above should all be unmistakable at a glance.
''';
