import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class todayOrderHistory extends StatefulWidget {
  const todayOrderHistory({Key? key}) : super(key: key);

  @override
  State<todayOrderHistory> createState() => todayOrderHistoryState();
}

class todayOrderHistoryState extends State<todayOrderHistory> {
  late int v_p_id;
  User? _user;
  List<dynamic> _orders = [];
  bool _isLoading = true;

  //fetching orders
  void fetchVendorOrders() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        _user = response.data as User?;
      });

      var vendorResponse = await http.get(
        Uri.parse('http://dev.codesisland.com/api/vendorprofile/${_user?.id}'),
      );
      var jsonResponse = jsonDecode(vendorResponse.body);
      // print(jsonResponse);
      v_p_id = jsonResponse['vendor']['id'];
      // print(v_p_id);
      var orderResponse = await http.get(
        Uri.parse('http://dev.codesisland.com/api/todayvendororder/${v_p_id}'),
      );
      var orderJsonResponse = jsonDecode(orderResponse.body);
      if (orderJsonResponse['v_order'] != null) {
        List<dynamic> orders = orderJsonResponse['v_order'].toList();
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      } else {
        setState(() {
          _orders = [];
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVendorOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
              'Today History',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.yellow),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green), // Change the color to green
              ),
            )
          : _orders.isNotEmpty
              ? ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => OrderDetailPage(
                        //             order: _orders[index]['id'],
                        //             orderStatus: _orders[index]['status'],

                        //             date: _orders[index]['date'],
                        //             totalAmount: _orders[index]['total_amount'],
                        //             // address: _orders[index]['address'],
                        //             vendor_id: _orders[index]['vendor_id'],
                        //             Quantity: _orders[index]['qty'],
                        //             qty: '',
                        //           )),
                        // );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.shopping_cart),
                              title: Text(
                                'Order#${_orders[index]['id']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10.0),
                                  Text(
                                    'Order Status: ${_orders[index]['status']}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),

                                  Text(
                                    'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(_orders[index]['date']).toLocal())}',
                                    // 'Date: ${DateFormat('dd/MM/yyyy').DateTime.parse(_orders[index]['date'])}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Total Price:  ${_orders[index]['total_amount']} PKR',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  // Text(
                                  //   'Address: ${_orders[index]['address']}',
                                  //   style: const TextStyle(
                                  //     fontSize: 16.0,
                                  //   ),
                                  // ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    'No Orders History Found',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
    );
  }
}
