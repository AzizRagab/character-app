// lib/cubits/firestore_state.dart
import 'package:equatable/equatable.dart';
import '../models/character.dart';

abstract class FirestoreState extends Equatable {
  const FirestoreState();

  @override
  List<Object> get props => [];
}

class FirestoreInitial extends FirestoreState {}

class FirestoreLoading extends FirestoreState {}

class FirestoreLoaded extends FirestoreState {
  final List<Character> characters;
  const FirestoreLoaded(this.characters);

  @override
  List<Object> get props => [characters];
}

class FirestoreError extends FirestoreState {
  final String message;
  const FirestoreError(this.message);

  @override
  List<Object> get props => [message];
}