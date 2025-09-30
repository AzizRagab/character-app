// lib/cubits/character_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'character_state.dart'; // تأكد من هذا الاستيراد
import '../services/api_service.dart';

class CharacterCubit extends Cubit<CharacterState> {
  final ApiService _apiService;

  CharacterCubit(this._apiService) : super(CharacterInitial());

  Future<void> fetchCharacters() async {
    emit(CharacterLoading());
    try {
      final characters = await _apiService.getCharacters();
      emit(CharacterLoaded(characters));
    } catch (e) {
      emit(CharacterError(e.toString()));
    }
  }
}