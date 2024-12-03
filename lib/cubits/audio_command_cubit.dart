import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

part 'audio_command_state.dart';

class AudioCommandCubit extends Cubit<AudioCommandState> {
  AudioCommandCubit() : super(AudioCommandInitial());

  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<void> initializeSpeech() async {
    bool available = await _speech.initialize();
    if (available) {
      emit(AudioCommandReady());
    } else {
      emit(AudioCommandError('Speech recognition not available'));
    }
  }

  Future<void> startListening() async {
    if (state is AudioCommandReady) {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            emit(AudioCommandResult(result.recognizedWords));
          }
        },
      );
      emit(AudioCommandListening());
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    emit(AudioCommandReady());
  }
}

