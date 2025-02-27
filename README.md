
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

import 'package:flutter/material.dart';
import 'package:mp_audio_stream/mp_audio_stream.dart';

void main() {
  final audioStream = getAudioStream();
  const rate = 44100;
  const channels = 2;
  const freqL = 440;
  const freqR = 660;
  int inc = 0;
  final Stopwatch stopwatch = Stopwatch();

//default init params: {int bufferMilliSec = 3000,
//                      int waitingBufferMilliSec = 100,
//                      int channels = 1,
//                      int sampleRate = 44100}
  audioStream.init(
      sampleRate: rate,
      channels: channels,
      bufferMilliSec: 200,
      waitingBufferMilliSec:
          0); //Call this from Flutter's State.initState() method

  audioStream.resume(); //For the web, call this after user interaction

  stopwatch.reset();
  stopwatch.start();

  Timer.periodic(Duration(milliseconds: 100), (timer) {
    List<double> samples = [];
    for (;
        samples.length <
            ((stopwatch.elapsedMicroseconds) / 1000000 * rate * channels)
                .round();
        inc++) {
      samples.add(math.sin(2 * math.pi * ((inc * freqL) % rate) / rate));
      samples.add(math.sin(2 * math.pi * ((inc * freqR) % rate) / rate));
    }
    stopwatch.reset();
    audioStream.push(Float32List.fromList(samples));
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello, Sine Waves',
      home: Scaffold(
        appBar: AppBar(title: const Text('Hello, Sine Waves')),
      ),
    );
  }
}
// audioStream.uninit(); //Call this from Flutter's State.dispose()
```

For more API Documents, visit [pub.dev](https://pub.dev/packages/mp_audio_stream).

A runnable Flutter example application is at `/example/`.

# For developers

Update miniaudio submodule after `git clone`.

```
git submodule update --init
```
