// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fName;
  final String mName;
  final String lName;
  final String email;
  final String gender;
  final int age;
  final String? phone;
  final String? address;
  final String? profileImage;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  UserModel({
    required this.uid,
    required this.fName,
    required this.mName,
    required this.lName,
    required this.email,
    required this.gender,
    required this.age,
    this.phone,
    this.address,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$fName ${mName.isNotEmpty ? '$mName ' : ''}$lName';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fName': fName,
      'mName': mName,
      'lName': lName,
      'email': email,
      'gender': gender,
      'age': age,
      'phone': phone,
      'address': address,
      'profileImage': profileImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fName: map['fName'] ?? '',
      mName: map['mName'] ?? '',
      lName: map['lName'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      phone: map['phone'],
      address: map['address'],
      profileImage: map['profileImage'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}