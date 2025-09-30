// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ تسجيل الدخول
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw _getAuthError(e.toString());
    }
  }

  // ✅ التسجيل
  Future<UserModel?> register({
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
    try {
      print('🎯 بدء عملية التسجيل...');

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ تم إنشاء المستخدم في Authentication: ${result.user!.uid}');

      if (result.user != null) {
        UserModel newUser = UserModel(
          uid: result.user!.uid,
          fName: fName,
          mName: mName,
          lName: lName,
          email: email,
          gender: gender,
          age: age,
          phone: phone,
          address: address,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );

        print('📝 بيانات المستخدم الجاهزة للتخزين:');
        print(newUser.toMap());

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(newUser.toMap());

        print('🎉 تم حفظ البيانات في Firestore بنجاح!');
        return newUser;
      }
      return null;
    } catch (e) {
      print('❌ خطأ في التسجيل: $e');
      throw _getAuthError(e.toString());
    }
  }

  // ✅ تسجيل الخروج - الدالة المفقودة
  Future<void> logout() async {
    await _auth.signOut();
    print('🚪 تم تسجيل الخروج');
  }

  // ✅ جلب بيانات المستخدم - الدالة المفقودة
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        print('✅ تم جلب بيانات المستخدم: ${userDoc.data()}');
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
      print('❌ بيانات المستخدم غير موجودة');
      return null;
    } catch (e) {
      print('❌ خطأ في جلب بيانات المستخدم: $e');
      throw 'فشل في جلب بيانات المستخدم: $e';
    }
  }

  // ✅ تحديث الملف الشخصي - الدالة المفقودة
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore.collection('users').doc(uid).update(updates);
      print('✅ تم تحديث الملف الشخصي: $updates');
    } catch (e) {
      print('❌ خطأ في تحديث الملف الشخصي: $e');
      throw 'فشل في تحديث الملف الشخصي: $e';
    }
  }

  // ✅ حذف الحساب - الدالة المفقودة
  Future<void> deleteAccount(String uid) async {
    try {
      // حذف من Authentication
      await _auth.currentUser!.delete();
      // حذف من Firestore
      await _firestore.collection('users').doc(uid).delete();
      print('✅ تم حذف الحساب بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف الحساب: $e');
      throw 'فشل في حذف الحساب: $e';
    }
  }

  // ✅ التحقق من وجود بيانات المستخدم
  Future<void> checkUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        print('✅ بيانات المستخدم موجودة في Firestore');
        print('📄 البيانات: ${doc.data()}');
      } else {
        print('❌ بيانات المستخدم غير موجودة في Firestore');
      }
    } catch (e) {
      print('❌ خطأ في التحقق من البيانات: $e');
    }
  }

  String _getAuthError(String error) {
    if (error.contains('invalid-email')) return 'البريد الإلكتروني غير صحيح';
    if (error.contains('user-not-found')) return 'المستخدم غير موجود';
    if (error.contains('wrong-password')) return 'كلمة المرور خاطئة';
    if (error.contains('email-already-in-use')) return 'البريد الإلكتروني مستخدم بالفعل';
    if (error.contains('weak-password')) return 'كلمة المرور ضعيفة';
    return 'حدث خطأ أثناء المصادقة';
  }
}