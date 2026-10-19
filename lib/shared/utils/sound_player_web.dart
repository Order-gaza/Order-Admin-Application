import 'dart:html' as html;

/// Web synthesizer for playing a clean "beep beep" notification alert.
void playWebSound() {
  try {
    final script = html.ScriptElement()
      ..text = '''
        (function() {
          try {
            var context = new (window.AudioContext || window.webkitAudioContext)();
            var osc = context.createOscillator();
            var gain = context.createGain();
            osc.connect(gain);
            gain.connect(context.destination);
            osc.type = "sine";
            osc.frequency.value = 880;
            
            // Double beep
            gain.gain.setValueAtTime(0, context.currentTime);
            gain.gain.linearRampToValueAtTime(0.3, context.currentTime + 0.05);
            gain.gain.linearRampToValueAtTime(0, context.currentTime + 0.15);
            
            gain.gain.setValueAtTime(0, context.currentTime + 0.2);
            gain.gain.linearRampToValueAtTime(0.3, context.currentTime + 0.25);
            gain.gain.linearRampToValueAtTime(0, context.currentTime + 0.35);
            
            osc.start(context.currentTime);
            osc.stop(context.currentTime + 0.4);
          } catch(e) {}
        })();
      ''';
    html.document.body?.children.add(script);
    script.remove();
  } catch (_) {
    // Standard browser restriction: auto-play/audio context is blocked
    // until user interacts with the page (clicks/taps). Once they click anywhere,
    // this plays correctly.
  }
}
