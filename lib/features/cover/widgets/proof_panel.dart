import 'package:flutter/material.dart';

import '../../../services/nano_banana_service.dart';
import '../../../state/cover_controller.dart';
import '../../../theme/press_theme.dart';
import 'eject_disc.dart';
import 'proof_body.dart';
import 'proof_frame.dart';

/// The plate, its furniture, and the disc behind it.
class ProofPanel extends StatefulWidget {
  const ProofPanel({required this.controller, super.key});

  final CoverController controller;

  @override
  State<ProofPanel> createState() => _ProofPanelState();
}

class _ProofPanelState extends State<ProofPanel> {
  /// Out as soon as a cover lands; tap to load it back in.
  bool _discOut = true;

  CoverDraft? _lastDraft;

  void _toggle() => setState(() => _discOut = !_discOut);

  @override
  void initState() {
    super.initState();
    _lastDraft = widget.controller.draft;
  }

  @override
  void didUpdateWidget(ProofPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new run is a new disc.
    final draft = widget.controller.draft;
    if (!identical(draft, _lastDraft)) {
      _lastDraft = draft;
      if (draft?.image != null && !_discOut) {
        setState(() => _discOut = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final done = controller.status == CoverStatus.ready &&
        controller.draft?.image != null;

    Widget plate = DecoratedBox(
      decoration: BoxDecoration(
        color: Press.paperLight,
        border: Border.all(color: Press.inkAt(0.42)),
      ),
      child: ProofFrame(
        pixelSize: controller.draft?.pixelSize,
        caption: controller.failedStage != null
            ? 'Spread — not imposed'
            : 'Spread — back / front',
        rightNote: 'CMYK · uncoated',
        child: ProofBody(controller: controller),
      ),
    );

    if (done && !_discOut) {
      // Absorbs the tap, or it falls through to the disc and toggles twice.
      plate = GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: plate,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Sized from the plate so the proportion holds at every width.
        final discSize = (constraints.maxWidth * EjectDisc.plateFraction)
            .clamp(180.0, 420.0);
        final reserve = discSize * EjectDisc.protrusion;

        return Stack(
          children: [
            // Behind the plate. Flutter never hit-tests out-of-bounds children,
            // so the reserved strip is what keeps the ejected half clickable.
            if (done)
              EjectDisc(
                ejected: _discOut,
                size: discSize,
                reserve: reserve,
                left: constraints.maxWidth * EjectDisc.centreFraction -
                    discSize / 2,
                onTap: _toggle,
              ),
            Padding(
              padding: EdgeInsets.only(bottom: done ? reserve : 0),
              child: plate,
            ),
          ],
        );
      },
    );
  }
}
