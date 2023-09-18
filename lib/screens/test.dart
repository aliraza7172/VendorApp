// import 'package:flutter/material.dart';

// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import '../models/api_response.dart';
// import '../models/user.dart';
// import '../services/user_service.dart';

// class Order_detail extends StatefulWidget {
//   const Order_detail({Key? key}) : super(key: key);

//   @override
//   State<Order_detail> createState() => _Order_detailState();
// }

// class _Order_detailState extends State<Order_detail> {
//   late int v_p_id;
//   User? _user;
//   List<dynamic> _orders = [];

//   //fetching orders
//   void fetchVendorOrders() async {
//     ApiResponse response = await getUserDetail();
//     if (response.error == null) {
//       setState(() {
//         _user = response.data as User?;
//       });

//       var vendorResponse = await http.get(
//         Uri.parse(
//             'http://dev.codesisland.com/api/vendorprofile/${_user?.id}'),
//       );
//       var jsonResponse = jsonDecode(vendorResponse.body);
//       v_p_id = jsonResponse['vendor']['id'];

//       var orderResponse = await http.get(
//         Uri.parse(
//             'http://dev.codesisland.com/api/vendororder/${v_p_id}'),
//       );
//       var orderJsonResponse = jsonDecode(orderResponse.body);

//       List<dynamic> orders = orderJsonResponse['v_order'].values.toList();
//       setState(() {
//         _orders = orders;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchVendorOrders();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Orders'),
//       ),
//       body: ListView.builder(
//         itemCount: _orders.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text('Order#${_orders[index]['id']}'),
//             subtitle: Text(
//                 'Order Status: ${_orders[index]['status']}, Total Price: ${_orders[index]['total_amount']}'),
//           );
//         },
//       ),
//     );
//   }
// }
