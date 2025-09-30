// lib/models/character.dart
class Character {
  final String id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String image;
  final String location;
  final DateTime? createdAt; // إضافة الطابع الزمني
  final DateTime? updatedAt; // إضافة وقت التحديث

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.image,
    required this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
      species: json['species'] ?? 'Unknown',
      gender: json['gender'] ?? 'Unknown',
      image: json['image'] ?? '',
      location: json['location']['name'] ?? 'Unknown',
      // يمكن إضافة parsing للطابع الزمني إذا كان موجوداً في الـ API
    );
  }

  // دالة لتحويل النموذج إلى Map لـ Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'status': status,
      'species': species,
      'gender': gender,
      'image': image,
      'location': location,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}