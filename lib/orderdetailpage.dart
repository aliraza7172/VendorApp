import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models/api_response.dart';
import 'models/user.dart';
import 'services/user_service.dart';

class OrderDetailPage extends StatefulWidget {
  final int order;
  final String orderStatus;
  final String totalAmount;
  final String date;
  final String qty;
  final String vendor_id;

  const OrderDetailPage({
    required this.order,
    required this.orderStatus,
    required this.totalAmount,
    required this.date,
    required this.qty,
    required this.vendor_id,
    required Quantity,
  });

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  List<dynamic> _orderDetails = [];
  bool _isLoading = true;
  User? _user;
  var v_id = 0;

  void fetchOrderDetails() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        _user = response.data as User?;
      });
      var vendorResponse = await http.get(
        Uri.parse(
          'http://dev.codesisland.com/api/vendorprofile/${_user?.id}',
        ),
      );
      var jsonResponse = jsonDecode(vendorResponse.body);
      v_id = jsonResponse['vendor']['id'];
    }

    var orderResponse = await http.get(
      Uri.parse(
        'http://dev.codesisland.com/api/vendororderdetali/${widget.order}/${v_id}',
      ),
    );

    if (orderResponse.statusCode == 200) {
      var orderJsonResponse = jsonDecode(orderResponse.body);
      var vendorDetail = orderJsonResponse['vendor_dteail'];

      if (vendorDetail is Map) {
        setState(() {
          _orderDetails = vendorDetail.values.toList();
          _isLoading = false;
        });
      } else if (vendorDetail is List) {
        setState(() {
          _orderDetails = vendorDetail;
          _isLoading = false;
        });
      }
    } else {
      // Handle error case when the API returns a non-200 status code
      print('Error fetching order details: ${orderResponse.statusCode}');
    }
  }

  Future<void> changeOrderStatus(
      String id, String orderId, String productId, String vendorId) async {
    String url =
        'http://dev.codesisland.com/api/changestatus/$id/$orderId/$productId/$vendorId';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
        body: {'status': 'Done From Vendor'},
      );

      print(response.body);
      if (response.statusCode == 200) {
        // Request successful
        print('Order status updated successfully');
      } else {
        // Request failed
        print('Failed to update order status. Error: ${response.statusCode}');
      }
    } catch (e) {
      // Exception occurred
      print('Exception occurred while updating order status: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _orderDetails.isNotEmpty
              ? ListView.builder(
                  itemCount: _orderDetails.length,
                  itemBuilder: (context, index) {
                    var orderDetail = _orderDetails[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          'Order ID: ${orderDetail['id']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              'Product Name: ${orderDetail['product_name']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Quantity: ${orderDetail['qty']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Status: ${orderDetail['status']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 16),
                            Divider(color: Colors.grey[300]),
                            ButtonBar(
                              children: [
                                Opacity(
                                  opacity:
                                      orderDetail['status'] == 'Order Received'
                                          ? 1.0
                                          : 0.0,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (orderDetail['status'] ==
                                          'Order Received') {
                                        String orderId =
                                            orderDetail['order_id'].toString();
                                        String vendorId =
                                            orderDetail['vendor_id'].toString();
                                        String productId =
                                            orderDetail['product_id']
                                                .toString();
                                        String id =
                                            orderDetail['id'].toString();
                                        await changeOrderStatus(
                                            id, orderId, productId, vendorId);
                                        setState(() {
                                          orderDetail['status'] =
                                              'Done From Vendor';
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      'Status: Done',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    'No order details to display',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
    );
  }
}
