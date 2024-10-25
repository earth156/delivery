import 'dart:developer';
import 'dart:io';
import 'package:delivery/model/ShowUser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class CreateSendPage extends StatefulWidget {
  final String userId;

  const CreateSendPage({super.key, required this.userId});

  @override
  State<CreateSendPage> createState() => _CreateSendPageState();
}

class _CreateSendPageState extends State<CreateSendPage> {
  final TextEditingController _recipientIdController = TextEditingController();
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _recipientAddressController = TextEditingController();
  final TextEditingController _recipientPhoneController = TextEditingController();
  final TextEditingController _productDetailsController = TextEditingController();

  List<ShowUser> _contactList = [];
  List<ShowUser> _filteredContacts = [];
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    try {
      final response = await http.get(Uri.parse('https://appdeli.onrender.com/showUser'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('users')) {
          List<dynamic> data = jsonResponse['users'];
          setState(() {
            _contactList = data
                .map<ShowUser>((json) => ShowUser.fromJson(json))
                .where((user) => user.userId.toString() != widget.userId)
                .toList();
            _filteredContacts = _contactList;
          });
        } else {
          throw Exception('ไม่พบคีย์ "users" ในการตอบกลับ');
        }
      } else {
        throw Exception('ไม่สามารถโหลดข้อมูลผู้ติดต่อได้ รหัสสถานะ: ${response.statusCode}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการดึงข้อมูลผู้ติดต่อ: $error')),
      );
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = query.isEmpty
          ? _contactList
          : _contactList.where((contact) {
              return contact.name.contains(query) || contact.phone.contains(query);
            }).toList();
    });
  }

  Future<void> _pickImage() async {
    _image = await _picker.pickImage(source: ImageSource.gallery);
    if (_image != null) {
      log('Selected image: ${_image!.path}');
      setState(() {});
    }
  }

  Future<void> _takePhoto() async {
    _image = await _picker.pickImage(source: ImageSource.camera);
    if (_image != null) {
      log('Captured image: ${_image!.path}');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้างรายการส่งสินค้า', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 56, 238, 15),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            const Text(
              'สร้างการส่งสินค้า',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
            ),
            const SizedBox(height: 20.0),
            _buildInputField(
              controller: _recipientPhoneController,
              label: 'ค้นหาผู้รับ (ชื่อ/เบอร์โทร)',
              onChanged: (value) => _filterContacts(value),
              icon: Icons.search,
            ),
            const SizedBox(height: 20.0),
            _buildContactList(),
            const SizedBox(height: 20.0),
            _buildInputField(controller: _recipientNameController, label: 'ชื่อผู้รับ', icon: Icons.person),
            const SizedBox(height: 20.0),
            _buildInputField(controller: _recipientAddressController, label: 'ที่อยู่ผู้รับ', icon: Icons.location_on),
            const SizedBox(height: 20.0),
            _buildInputField(controller: _productDetailsController, label: 'รายละเอียดสินค้า', icon: Icons.description),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerButton(onPressed: _pickImage, icon: Icons.photo_library, color: Colors.purple, tooltip: 'เลือกภาพจากแกลเลอรี่'),
                _buildImagePickerButton(onPressed: _takePhoto, icon: Icons.camera_alt, color: Colors.blue, tooltip: 'ถ่ายภาพ'),
              ],
            ),
            const SizedBox(height: 20.0),
            if (_image != null) _buildImagePreview(),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: const Text(
                'ยืนยันการสร้าง',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        filled: true,
        fillColor: Colors.purple.shade50,
      ),
      onChanged: onChanged,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildContactList() {
    return ListView.builder(
      itemCount: _filteredContacts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.purple),
            title: Text('${contact.name} - ${contact.phone}'),
            subtitle: Text(contact.address),
            onTap: () {
              _recipientIdController.text = contact.userId.toString();
              _recipientNameController.text = contact.name;
              _recipientAddressController.text = contact.address;
              _recipientPhoneController.text = contact.phone;
            },
          ),
        );
      },
    );
  }

  Widget _buildImagePickerButton({required void Function() onPressed, required IconData icon, required Color color, required String tooltip}) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 36.0),
      tooltip: tooltip,
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Image.file(
          File(_image!.path),
          width: 200,
          height: 200,
        ),
        const SizedBox(height: 10),
        Text('Path: ${_image!.path}'),
      ],
    );
  }

  Future<void> _onSubmit() async {
    String recipientId = _recipientIdController.text;
    String recipientName = _recipientNameController.text;
    String recipientAddress = _recipientAddressController.text;
    String recipientPhone = _recipientPhoneController.text;
    String productDetails = _productDetailsController.text;

    try {
      final response = await http.post(
        Uri.parse('https://appdeli.onrender.com/insertProduct/${widget.userId}/$recipientId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'details': productDetails,
          'imagePath': _image?.path,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('สร้างรายการส่งสินค้าสำเร็จ: $recipientName')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการสร้างรายการ: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการส่งข้อมูล: $error')),
      );
    }
  }
}
