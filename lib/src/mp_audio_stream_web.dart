import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' show document, HTMLScriptElement;

import '../mp_audio_stream.dart' as mpaudio;

extension type JSAudioStream(JSObject _) implements JSObject {
  external void init(
      int bufferLength, int waitingBufferLength, int channels, int sampleRate);
  external void uninit();
  external void resume();
  external void push(JSFloat32Array buf);
  external JSAudioStreamStat get stat;
  external void resetStat();
}

extension type JSAudioStreamStat(JSObject _) implements JSObject {
  external int get fullCount;
  external int get exhaustCount;
}

@JS("AudioStream")
external JSAudioStream? get _stream;

/// Contol class for AudioStream on web platform. Use `getAudioStream()` to get its instance.
class AudioStreamImpl extends mpaudio.AudioStream {
  void delay(Function(JSAudioStream) fn) {
    if (_stream != null) {
      fn(_stream!);
      return;
    }

    (() async {
      while (_stream == null) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      fn(_stream!);
    })();
  }

  AudioStreamImpl() {
    final scriptTag = document.createElement('script') as HTMLScriptElement;
    scriptTag.src = "/assets/packages/mp_audio_stream/js/audio_stream.js";
    document.head?.append(scriptTag);
  }

  @override
  int init(
      {int bufferMilliSec = 3000,
      int waitingBufferMilliSec = 100,
      int channels = 1,
      int sampleRate = 44100}) {
    delay((s) => s.init(
        channels * (bufferMilliSec * sampleRate / 1000) as int,
        channels * (waitingBufferMilliSec * sampleRate / 1000) as int,
        channels,
        sampleRate));
    return 0;
  }

  @override
  void uninit() {
    delay((s) => s.uninit());
  }

  @override
  void resume() {
    delay((s) => s.resume());
  }

  @override
  int push(Float32List buf) {
    delay((s) => s.push(buf.toJS));
    return 0;
  }

  @override
  mpaudio.AudioStreamStat stat() {
    if (_stream == null) return mpaudio.AudioStreamStat.empty();

    final statJsObj = _stream!.stat;
    return mpaudio.AudioStreamStat(
        full: statJsObj.fullCount, exhaust: statJsObj.exhaustCount);
  }

  @override
  void resetStat() {
    delay((s) => s.resetStat());
  }
}
