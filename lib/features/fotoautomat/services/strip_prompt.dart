import '../models/strip_style.dart';

/// Builds the developing instructions. Written in plain sentences without
/// capitals or placeholders, because the model paints formatting it cannot
/// tell apart from lettering.
String buildStripPrompt(StripStyle style, {required int frameCount}) =>
    '''
You are the developing tank inside a real Berlin street Photoautomat, the chemical photo booth found on Kastanienallee or outside Warschauer Strasse station. Turn the $frameCount supplied webcam photos into one authentic photo strip of the same moments, restyled with a Berlin underground makeover.

Layout: one long, narrow vertical strip of matte off-white photo paper, about four times taller than it is wide, lying perfectly straight in the centre and running the full height of the image from top edge to bottom edge. $frameCount frames are stacked from top to bottom; frame one is the first photo, frame two the second, and so on. Every frame has the same near-square size, with narrow even paper borders around and between the frames, like a real booth strip. Left and right of the strip is only the plain, flat, near-black matte metal of the booth's dispenser tray, evenly lit and empty: no table, no hands, no other objects.

Poses, and this matters most: the fun of a booth strip is that every frame catches a different moment, so each frame must be an edit of its own photo, not a newly posed picture. Copy from each photo exactly: the facial expression (smile or no smile, open or closed mouth, tongue, raised eyebrows, squint, wink or closed eyes), the direction of the gaze, the tilt and turn of the head, the lean of the body and shoulders, and every hand gesture with the same hand, the same fingers raised or bent and the same position relative to the face and body. Keep the framing of each photo: the same distance from the lens and the same position in the frame. When cropping a wide photo to the near-square frame, keep every visible hand and gesture inside the frame, zooming out slightly rather than cutting one off. Never add hands that are not in the photo, never remove hands that are, and never let the poses drift towards each other: four photos, four different moments.

Faces: these are real people who will look for themselves in the strip. Keep facial features, face shape, skin tone, age and the number of people exactly as in the photos, so everyone is instantly recognisable. Do not beautify, slim, smooth or swap anyone.

Makeover: change only hair, clothing and jewellery, following the look below, and leave everything else about each person as described above. Completely replace their hairstyle; do not keep the original cut, length or colour. Completely replace the clothing worn in the photos; do not keep the original garment, its colour, its pattern or its neckline. Add the piercings, chains and jewellery of the look so they are clearly visible on the face, ears and neck. The makeover is identical in every frame, because the strip is one sitting, while the poses stay different. When several people appear, give each their own variation of the look.

The look: ${style.makeover}

Background: replace whatever room is behind them with the booth interior described in the art direction, identical in all frames.

Text: the strip carries no writing at all. No captions, dates, frame numbers, logos, stamps or watermarks, no readable words on patches, badges or clothing, and never paint instruction words or style names into the image.

Art direction, ${style.subtitle.toLowerCase()}: ${style.artDirection}

Commit fully to this look and art direction: the haircut, piercings, black leather and chains, and the film stock, colour, grain, lighting and booth interior should all be unmistakable at a glance. But never at the expense of the poses: someone looking at the strip next to the four webcam photos should match every expression and gesture frame by frame.

After the image, write one short sentence of at most twelve words in the voice of the booth's darkroom technician, remarking on this particular strip. Plain text only.
''';

/// Introduces one photo so the model maps photos to frames in order.
String framePhotoLabel(int index, int frameCount) =>
    'Photo for frame ${index + 1} of $frameCount${index == 0 ? ', the top frame' : ''}:';
