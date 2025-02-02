import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';

class MicrophoneListener {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  Function(double)? onVolumeChange; // Funktio, jolla välitetään äänenvoimakkuus pääkoodille

  // 🔥 **Lisätty StreamController äänen tallennukselle**
  final StreamController<List<int>> _audioStreamController = StreamController<List<int>>();

  Future<void> initializeRecorder() async {
  try {
    await _recorder.openRecorder();

    await _recorder.startRecorder(); // ✅ Poistetaan virheellinen `toStream`

    _recorder.setSubscriptionDuration(Duration(milliseconds: 100));
    _startListening();
  } catch (e) {
    print("❌ Mikrofonin käynnistyksen virhe: $e");
  }
}

  void _startListening() {
    _recorder.onProgress?.listen((event) {
      double volume = _processAudio(event.decibels ?? 0);
      print("🎤 Äänenvoimakkuus: $volume"); // ✅ Nyt print() on oikeassa paikassa
      onVolumeChange?.call(volume);
    });
  }

  double _processAudio(double decibels) {
    return (decibels + 60).clamp(0, 100); // Muunnetaan desibelit skaalalle 0-100
  }

  void dispose() {
    _recorder.closeRecorder();
    _audioStreamController.close(); // ✅ Suljetaan streami, jotta resursseja ei vuoda
  }
}
