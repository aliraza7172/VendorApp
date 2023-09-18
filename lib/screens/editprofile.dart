import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'profile.dart';

class EditProfileScreen extends StatefulWidget {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String shop;

  const EditProfileScreen({
    Key? key,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.shop,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _shopController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text field values with the existing user data
    _nameController.text = widget.name;
    _emailController.text = widget.email;
    _phoneController.text = widget.phone;
    _addressController.text = widget.address;
    _idController.text = widget.id;
    _shopController.text = widget.shop;
  }

  Future<void> updateUserProfile(
      String id, String name, String address, String phone, String shop) async {
    // Your API endpoint URL
    var url = 'http://dev.codesisland.com/api/updatevendorprofile/$id';
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'name': name,
        'address': address,
        'id': id,
        'phone': phone,
        'shop_name': shop,
      }),
    );
    if (response.statusCode == 200) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
        (route) => false,
      );
      Fluttertoast.showToast(
        msg: 'Your profile has been updated',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green, // Change to your desired color
        textColor: Colors.white, // Change to your desired color
      );
    } else {
      // Handle error here (if necessary)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true, // This centers the title horizontally.
        title: Row(
          children: <Widget>[
            Image.asset(
              'images/vendorlogo.png', // Replace 'assets/logo.png' with the path to your logo image.
              width: 140, // Adjust the width as needed.
              height: 140, // Adjust the height as needed.
              // You can use other properties like 'fit' to control how the image is displayed.
            ),
            const SizedBox(
                width: 8), // Add some spacing between the logo and the title.
            Spacer(), // This will push the text to the right.

            const Text(
              'Edit Profile',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.yellow),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        // Add SingleChildScrollView here
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone, // Set keyboard type to phone
              // Enable phone dialer
              decoration: const InputDecoration(
                labelText: 'Phone',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _shopController,
              decoration: const InputDecoration(
                labelText: 'Shop Name',
              ),
            ),
            const SizedBox(height: 16.0),
            // TextField(
            //   controller: _idController,
            //   enabled: false,
            //   decoration: const InputDecoration(
            //     labelText: 'ID',
            //   ),
            // ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                String newName = _nameController.text;
                String newAddress = _addressController.text;
                String id = widget.id;
                String phone = _phoneController.text;
                String shop = _shopController.text;

                // Call the API function to update the profile
                updateUserProfile(id, newName, newAddress, phone, shop);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
