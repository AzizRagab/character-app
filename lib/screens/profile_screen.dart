// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userData;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final _fNameController = TextEditingController();
  final _mNameController = TextEditingController();
  final _lNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedGender = 'ذكر';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        print('👤 جلب بيانات المستخدم: ${user.uid}');
        final authService = AuthService(); // إنشاء instance من AuthService
        final userData = await authService.getUserData(user.uid);
        setState(() {
          _userData = userData;
          _initializeControllers();
        });
      } catch (e) {
        print('❌ خطأ في تحميل البيانات: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحميل البيانات: $e')),
        );
      }
    } else {
      print('❌ لا يوجد مستخدم مسجل الدخول');
    }
  }

  void _initializeControllers() {
    if (_userData != null) {
      _fNameController.text = _userData!.fName;
      _mNameController.text = _userData!.mName;
      _lNameController.text = _userData!.lName;
      _ageController.text = _userData!.age.toString();
      _phoneController.text = _userData!.phone ?? '';
      _addressController.text = _userData!.address ?? '';
      _selectedGender = _userData!.gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          if (!_isEditing) IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = true),
          ),
          if (_isEditing) IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() => _isEditing = false);
              _initializeControllers();
            },
          ),
        ],
      ),
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade100,
                child: _userData!.profileImage != null
                    ? ClipOval(
                  child: Image.network(
                    _userData!.profileImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),

              // معلومات المستخدم
              _buildInfoField('الاسم الكامل', _userData!.fullName),
              _buildEditableField(
                'الاسم الأول',
                _fNameController,
                Icons.person,
                isRequired: true,
              ),
              _buildEditableField(
                'الاسم الأوسط',
                _mNameController,
                Icons.person_outline,
              ),
              _buildEditableField(
                'الاسم الأخير',
                _lNameController,
                Icons.person_outline,
                isRequired: true,
              ),
              _buildInfoField('البريد الإلكتروني', _userData!.email),
              _buildGenderField(),
              _buildEditableField(
                'العمر',
                _ageController,
                Icons.cake,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              _buildEditableField(
                'رقم الهاتف',
                _phoneController,
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildEditableField(
                'العنوان',
                _addressController,
                Icons.home,
                maxLines: 2,
              ),
              _buildInfoField(
                'تاريخ الإنشاء',
                '${_userData!.createdAt.toDate()}',
              ),
              _buildInfoField(
                'آخر تحديث',
                '${_userData!.updatedAt.toDate()}',
              ),

              const SizedBox(height: 30),

              // أزرار التحديث والحذف
              if (_isEditing) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _updateProfile,
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ التغييرات'),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showDeleteDialog,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'حذف الحساب',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return ListTile(
      leading: const Icon(Icons.info, color: Colors.grey),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Widget _buildEditableField(
      String label,
      TextEditingController controller,
      IconData icon, {
        bool isRequired = false,
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: _isEditing
          ? TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: isRequired
            ? (value) {
          if (value == null || value.isEmpty) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        }
            : null,
      )
          : Text(label),
      subtitle: _isEditing ? null : Text(controller.text.isEmpty ? 'غير محدد' : controller.text),
    );
  }

  Widget _buildGenderField() {
    return ListTile(
      leading: const Icon(Icons.people, color: Colors.grey),
      title: const Text('الجنس'),
      subtitle: _isEditing
          ? DropdownButtonFormField<String>(
        value: _selectedGender,
        items: ['ذكر', 'أنثى', 'أفضل عدم التحديد'].map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(gender),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue!;
          });
        },
      )
          : Text(_selectedGender),
    );
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updates = {
          'fName': _fNameController.text.trim(),
          'mName': _mNameController.text.trim(),
          'lName': _lNameController.text.trim(),
          'gender': _selectedGender,
          'age': int.parse(_ageController.text),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        };

        final authService = AuthService();
        await authService.updateUserProfile(_userData!.uid, updates);

        setState(() {
          _isEditing = false;
        });

        // إعادة تحميل البيانات
        await _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في التحديث: $e')),
        );
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text('هل أنت متأكد من حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final authService = AuthService();
      await authService.deleteAccount(_userData!.uid);

      // استخدام AuthCubit لتسجيل الخروج
      context.read<AuthCubit>().logout();
      Navigator.pushReplacementNamed(context, '/login');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الحساب بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في حذف الحساب: $e')),
      );
    }
  }

  @override
  void dispose() {
    _fNameController.dispose();
    _mNameController.dispose();
    _lNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}