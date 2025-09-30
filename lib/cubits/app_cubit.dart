// lib/cubits/app_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

// States
abstract class AppState {}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppLoginSuccess extends AppState {}

class AppRegisterSuccess extends AppState {}

class AppProfileLoaded extends AppState {
  final UserModel user;
  AppProfileLoaded(this.user);
}

class AppError extends AppState {
  final String message;
  AppError(this.message);
}

class AppCubit extends Cubit<AppState> {
  final AuthService _authService;

  AppCubit(this._authService) : super(AppInitial());

  // تسجيل الدخول
  Future<void> login(String email, String password) async {
    emit(AppLoading());
    try {
      await _authService.login(email, password);
      emit(AppLoginSuccess());
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  // التسجيل
  Future<void> register({
    required String email,
    required String password,
    required String fName,
    required String mName,
    required String lName,
    required String gender,
    required int age,
    String? phone,
    String? address,
  }) async {
    emit(AppLoading());
    try {
      await _authService.register(
        email: email,
        password: password,
        fName: fName,
        mName: mName,
        lName: lName,
        gender: gender,
        age: age,
        phone: phone,
        address: address,
      );
      emit(AppRegisterSuccess());
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    emit(AppLoading());
    try {
      await _authService.logout();
      emit(AppInitial());
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  // جلب بيانات البروفايل
  Future<void> loadProfile(String uid) async {
    emit(AppLoading());
    try {
      final user = await _authService.getUserData(uid);
      if (user != null) {
        emit(AppProfileLoaded(user));
      } else {
        emit(AppError('المستخدم غير موجود'));
      }
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }
}