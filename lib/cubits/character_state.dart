// lib/cubits/character_state.dart
import 'package:equatable/equatable.dart';
import '../models/character.dart'; // تأكد من استيراد النموذج

abstract class CharacterState extends Equatable {
  const CharacterState();

  @override
  List<Object> get props => [];
}

class CharacterInitial extends CharacterState {}

class CharacterLoading extends CharacterState {}

class CharacterLoaded extends CharacterState {
  final List<Character> characters;
  const CharacterLoaded(this.characters);

  @override
  List<Object> get props => [characters];
}

class CharacterError extends CharacterState {
  final String message;
  const CharacterError(this.message);

  @override
  List<Object> get props => [message];
}