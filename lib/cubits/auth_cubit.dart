// lib/cubits/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        await _authService.checkUserData(user.uid);
        emit(AuthSuccess());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

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
    emit(AuthLoading());
    try {
      print('🚀 بدء عملية التسجيل في Cubit...');

      final user = await _authService.register(
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

      if (user != null) {
        print('✅ التسجيل مكتمل في Cubit');
        emit(AuthSuccess());
      } else {
        print('❌ فشل التسجيل في Cubit - user is null');
        emit(AuthFailure('فشل في إنشاء المستخدم'));
      }
    } catch (e) {
      print('❌ خطأ في Cubit: $e');
      emit(AuthFailure(e.toString()));
    }
  }

  // ✅ إضافة دالة logout المفقودة
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}