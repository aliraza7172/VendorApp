import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class ProductsList extends StatefulWidget {
  const ProductsList({Key? key}) : super(key: key);

  @override
  State<ProductsList> createState() => _ProductsListState();

  static getVendorProducts() {}
}

class _ProductsListState extends State<ProductsList> {
  late int v_p_id;
  User? _user;
  late Future<List<dynamic>> _productListFuture;
  late List<dynamic> productList; // Declare productList here

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _pidController = TextEditingController();

  Future<List<dynamic>> getVendorProducts() async {
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
      var aresponse = await http.get(
        Uri.parse('http://dev.codesisland.com/api/showvendorproduct/${v_p_id}'),
      );
      Map<String, dynamic> data = jsonDecode(aresponse.body);
      return data['v_product'].values.toList();
    } else {
      // handle error
      return [];
    }
  }

  Future<void> updateProductDetails() async {
    int updatedQuantity = int.parse(_quantityController.text);
    double updatedPrice = double.parse(_priceController.text);
    int id = int.parse(_pidController.text);

    // print('object');

    var url = 'http://dev.codesisland.com/api/updatevendorproduct/$v_p_id';
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'qty': updatedQuantity,
        'price': updatedPrice,
        'v_id': v_p_id,
        'p_id': id,
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(builder: (context) => const ProductsList()),
      //     (route) => false);
      await getVendorProducts(); // Wait for the list to be updated
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to update Product'),
      ));
    }

    // Update the product data
  }

  // Function to show the details dialog
  void _showDetailsDialog(Map<String, dynamic> product, int index) {
    // Initialize text controllers with the product details
    _productNameController.text = product['product_name'];
    _quantityController.text = product['qty'].toString();
    _priceController.text = product['price'].toString();
    _pidController.text = product['id'].toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Edit Product',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _productNameController,
                readOnly: true, // Set the TextField to be readonly
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              Visibility(
                visible: false, // Set this to false to hide the TextField
                child: TextField(
                  controller: _pidController,
                  decoration: const InputDecoration(labelText: 'id'),
                  keyboardType: TextInputType.number,
                ),
              )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Call the function to update values
                updateProductDetails();

                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                primary:
                    Colors.green, // Set the button's background color to green.
              ),
              child: Text(
                'Update',
                style: TextStyle(
                  color: Colors.white, // Set the text color to white.
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _productListFuture = getVendorProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: _productListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green), // Change the color to green
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(' Add your Products'),
            );
          } else {
            List<dynamic> productList = snapshot.data ?? [];
            return ListView.builder(
              itemCount: productList.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  elevation: 4, // Add a shadow
                  child: ListTile(
                    title: Text(productList[index]['product_name']),
                    subtitle: Text('Quantity: ${productList[index]['qty']}'),
                    trailing: Text('PKR ${productList[index]['price']}'),
                    onTap: () {
                      // Do something when the tile is tapped
                      _showDetailsDialog(
                          productList[index], index); // Show the details dialog
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
