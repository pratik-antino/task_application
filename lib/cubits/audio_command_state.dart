part of 'audio_command_cubit.dart';

abstract class AudioCommandState {}

class AudioCommandInitial extends AudioCommandState {}

class AudioCommandReady extends AudioCommandState {}

class AudioCommandListening extends AudioCommandState {}

class AudioCommandResult extends AudioCommandState {
  final String text;

  AudioCommandResult(this.text);
}

class AudioCommandError extends AudioCommandState {
  final String message;

  AudioCommandError(this.message);
}

