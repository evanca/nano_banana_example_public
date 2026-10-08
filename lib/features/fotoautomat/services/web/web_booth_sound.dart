import 'dart:js_interop';
import 'dart:math';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../booth_hardware.dart';

/// Synthesised relay clicks via Web Audio, so no audio assets ship.
/// The context is created lazily inside the first user gesture.
class WebBoothSound implements BoothSound {
  web.AudioContext? _ctx;
  final _random = Random();

  web.AudioContext get _context {
    final ctx = _ctx ??= web.AudioContext();
    if (ctx.state == 'suspended') ctx.resume();
    return ctx;
  }

  @override
  void click() => _noise(seconds: 0.02, gain: 0.5, cutoff: 2400, decay: 260);

  @override
  void tick() => _tone(frequency: 1760, seconds: 0.05, gain: 0.08);

  @override
  void shutter() {
    _noise(seconds: 0.05, gain: 0.9, cutoff: 900, decay: 110);
    _noise(seconds: 0.06, gain: 0.7, cutoff: 500, decay: 90, delay: 0.09);
    _tone(frequency: 3200, seconds: 0.35, gain: 0.03, type: 'sine', delay: 0.12);
  }

  @override
  void dispense() {
    for (var i = 0; i < 10; i++) {
      _tone(frequency: 82, seconds: 0.09, gain: 0.06, type: 'sawtooth', delay: i * 0.12);
      _noise(seconds: 0.015, gain: 0.25, cutoff: 1800, decay: 300, delay: i * 0.12);
    }
  }

  void _noise({
    required double seconds,
    required double gain,
    required double cutoff,
    required double decay,
    double delay = 0,
  }) {
    final ctx = _context;
    final rate = ctx.sampleRate;
    final length = max(1, (seconds * rate).round());
    final samples = Float32List(length);
    for (var i = 0; i < length; i++) {
      samples[i] = (_random.nextDouble() * 2 - 1) * exp(-decay * i / rate);
    }
    final buffer = ctx.createBuffer(1, length, rate)..copyToChannel(samples.toJS, 0);
    final source = ctx.createBufferSource()..buffer = buffer;
    final filter = ctx.createBiquadFilter()..type = 'highpass';
    filter.frequency.value = cutoff;
    final amp = ctx.createGain();
    amp.gain.value = gain;
    source
      ..connect(filter)
      ..start(ctx.currentTime + delay);
    filter.connect(amp);
    amp.connect(ctx.destination);
  }

  void _tone({
    required double frequency,
    required double seconds,
    required double gain,
    String type = 'square',
    double delay = 0,
  }) {
    final ctx = _context;
    final start = ctx.currentTime + delay;
    final osc = ctx.createOscillator()..type = type;
    osc.frequency.value = frequency;
    final amp = ctx.createGain();
    amp.gain
      ..setValueAtTime(gain, start)
      ..exponentialRampToValueAtTime(0.0001, start + seconds);
    osc
      ..connect(amp)
      ..start(start)
      ..stop(start + seconds);
    amp.connect(ctx.destination);
  }
}
