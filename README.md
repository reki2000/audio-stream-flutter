
A Flutter plugin for multi-platform, simple audio stream playback with real-time generated audio data streams

## Features

- Continuously plays buffered audio data at 44.1kHz until the buffer is empty
- Supported format: float32 multi-channel
- Suppots all flutter platforms: Android, iOS, macOS, Linux, Windows, and Web platforms
  - Web platform implementaion relies on WebAudio and `AudioWorkletProcessor`
  - Other platforms utilize [miniaudio](https://github.com/mackron/miniaudio.git), an outstandig multi-platform audio library

## Getting started

```
flutter pub add mp_audio_stream
```

## Usage

```dart
import 'dart:math' as math;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mp_audio_stream/mp_audio_stream.dart';

void main() async {
  final audioStream = getAudioStream();

  //default init params: {int bufferMilliSec = 3000,
  //                      int waitingBufferMilliSec = 100,
  //                      int channels = 1,
  //                      int sampleRate = 44100}
  int stereo = 2;
  audioStream.init(channels: stereo); //Call this from Flutter's State.init() method

  const rate = kIsWeb ? 8000 : 44100;
  const freqL = 440;
  const freqR = 660;
  Float32List samples = kIsWeb ? Float32List(3072) : Float32List(8500) // arbitrary, but work nicely

  audioStream.resume(); //For the web, call this before before calling push(..)
  final int microseconds = (1000000 * samples.length / (rate * stereo)).floor();
  int inc = 0;
  Timer t = Timer.periodic(Duration(microseconds: microseconds), (timer) {
    for (var s = 0; s < samples.length - 1; inc++) {
      samples[s++] = math.sin(2 * math.pi * ((inc * freqL) % rate) / rate);
      samples[s++] = math.sin(2 * math.pi * ((inc * freqR) % rate) / rate);
    }
    audioStream.push(samples);
  });

  audioStream.uninit(); //Call this from Flutter's State.dispose()
}
```

For more API Documents, visit [pub.dev](https://pub.dev/packages/mp_audio_stream).
