// lib/cubits/firestore_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firestore_state.dart'; // تأكد من استيراد State
import '../services/firestore_service.dart';
import '../models/character.dart';

class FirestoreCubit extends Cubit<FirestoreState> {
  final FirestoreService _firestoreService;

  FirestoreCubit(this._firestoreService) : super(FirestoreInitial());

  // جلب البيانات من Firestore
  void listenToCharacters() {
    emit(FirestoreLoading());

    try {
      _firestoreService.getCharactersStream().listen((characters) {
        emit(FirestoreLoaded(characters));
      }, onError: (error) {
        emit(FirestoreError(error.toString()));
      });
    } catch (e) {
      emit(FirestoreError(e.toString()));
    }
  }

  // إضافة شخصية جديدة
  Future<void> addCharacter(Character character) async {
    try {
      await _firestoreService.addCharacter(character);
      // لا نحتاج emit لأن الـ stream سيتحدث تلقائياً
    } catch (e) {
      emit(FirestoreError(e.toString()));
    }
  }

  // تحديث شخصية
  Future<void> updateCharacter(String id, Map<String, dynamic> updates) async {
    try {
      await _firestoreService.updateCharacter(id, updates);
    } catch (e) {
      emit(FirestoreError(e.toString()));
    }
  }

  // حذف شخصية
  Future<void> deleteCharacter(String id) async {
    try {
      await _firestoreService.deleteCharacter(id);
    } catch (e) {
      emit(FirestoreError(e.toString()));
    }
  }
}