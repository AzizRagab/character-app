// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/character.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إضافة مستند جديد مع ID تلقائي
  Future<String> addCharacter(Character character) async {
    try {
      final docRef = await _firestore
          .collection('characters')
          .add({
        ...character.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(), // الطابع الزمني للخادم
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw 'فشل في إضافة الشخصية: $e';
    }
  }

  // إضافة مستند مع ID محدد
  Future<void> addCharacterWithId(String id, Character character) async {
    try {
      await _firestore
          .collection('characters')
          .doc(id)
          .set({
        ...character.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'فشل في إضافة الشخصية: $e';
    }
  }

  // تحديث مستند موجود
  Future<void> updateCharacter(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('characters')
          .doc(id)
          .update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(), // تحديث الطابع الزمني
      });
    } catch (e) {
      throw 'فشل في تحديث الشخصية: $e';
    }
  }

  // تحديث حقل متداخل باستخدام Dot Notation
  Future<void> updateNestedField(String id, String fieldPath, dynamic value) async {
    try {
      await _firestore
          .collection('characters')
          .doc(id)
          .update({
        fieldPath: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'فشل في تحديث الحقل: $e';
    }
  }

  // زيادة قيمة رقمية (مثل عدد المشاهدات)
  Future<void> incrementViews(String id) async {
    try {
      await _firestore
          .collection('characters')
          .doc(id)
          .update({
        'views': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'فشل في زيادة العداد: $e';
    }
  }

  // إضافة عنصر لمصفوفة
  Future<void> addToArray(String id, String arrayField, dynamic element) async {
    try {
      await _firestore
          .collection('characters')
          .doc(id)
          .update({
        arrayField: FieldValue.arrayUnion([element]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'فشل في إضافة العنصر: $e';
    }
  }

  // حذف مستند
  Future<void> deleteCharacter(String id) async {
    try {
      await _firestore
          .collection('characters')
          .doc(id)
          .delete();
    } catch (e) {
      throw 'فشل في حذف الشخصية: $e';
    }
  }

  // جلب جميع الشخصيات
  Stream<List<Character>> getCharactersStream() {
    return _firestore
        .collection('characters')
        .orderBy('createdAt', descending: true) // ترتيب حسب وقت الإنشاء
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      return Character(
        id: doc.id,
        name: data['name'] ?? '',
        status: data['status'] ?? '',
        species: data['species'] ?? '',
        gender: data['gender'] ?? '',
        image: data['image'] ?? '',
        location: data['location'] ?? '',
        createdAt: data['createdAt']?.toDate(),
        updatedAt: data['updatedAt']?.toDate(),
      );
    }).toList());
  }
}