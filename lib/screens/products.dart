import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vendor/screens/vendorproduct.dart';

import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class Product {
  final int id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['p_name'],
      price: double.parse(json['p_price']),
    );
  }
}

class InventoryScreen extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<InventoryScreen> {
  List products = [];
  User? _user;

  // ignore: non_constant_identifier_names
  var p_id = '';
  // ignore: non_constant_identifier_names
  var v_id = 0;
  // ignore: non_constant_identifier_names
  var v_price = 0;
  var qty = 0;
  // ignore: non_constant_identifier_names
  var v_p_id = 0;
  var url = 'http://dev.codesisland.com/api/vendor/creatproduct';
  void updatePrice(String input) {
    setState(() {
      v_price = int.parse(input);
    });
  }

  void updateQty(String input) {
    setState(() {
      qty = int.parse(input);
    });
  }

  void _getUserInfo() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        _user = response.data as User?;
      });
      var vendorResponse = await http.get(
        Uri.parse('http://dev.codesisland.com/api/vendorprofile/${_user?.id}'),
      );
      var jsonResponse = jsonDecode(vendorResponse.body);
      v_p_id = jsonResponse['vendor']['id'];
      var vendorproductResponse = await http.get(
        Uri.parse('http://dev.codesisland.com/api/showvendorproduct/${v_p_id}'),
      );
      // print(vendorproductResponse.body);
      setState(() {
        vendorJsonResponse = jsonResponse;
      });
    } else {
      // Handle error here
    }
  }

  productCreate(String p_id, int v_id, int v_price, int qty) async {
    v_id = vendorJsonResponse['vendor']['id'];
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'v_id': v_id,
        'p_id': p_id,
        'price': v_price,
        'qty': qty,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 422) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Product already been added"),
          duration: Duration(seconds: 2), // Adjust the duration as needed
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
    } else {
      await ProductsList.getVendorProducts();
    }
    // print(response.body);
  }

  Future<void> getProducts() async {
    var response = await http.get(
      Uri.parse(
        'http://dev.codesisland.com/api/admin/ajaxgetproduct',
      ),
    );
    var data = jsonDecode(response.body);
    setState(() {
      products = data['product'];
    });
  }

  @override
  void initState() {
    super.initState();
    getProducts();
    _getUserInfo();
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
              'Inventory',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.yellow),
            ),
          ],
        ),
      ),
      body: const ProductsList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // Create a separate BuildContext for the dialog
              BuildContext dialogContext = context;
              String productName = '';
              return AlertDialog(
                title: const Text('Add Product'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField(
                      items: products.map((product) {
                        return DropdownMenuItem(
                          value: product['id'],
                          child: Text(product['p_name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          p_id = value.toString();
                        });
                      },
                      value: productName.isEmpty ? null : productName,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      onChanged: (input) => updateQty(input),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      onChanged: (input) => updatePrice(input),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: () {
                      // ignore: todo
                      // TODO: Save product to inventory
                      Navigator.of(context).pop();
                      productCreate(p_id, v_id, v_price, qty);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

dynamic vendorJsonResponse;
