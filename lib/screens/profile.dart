import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:vendor/screens/editprofile.dart';
import 'package:vendor/screens/login.dart';
import 'package:vendor/screens/paymenthistory.dart';
import 'package:vendor/screens/profileupdatemap.dart';
import 'package:vendor/screens/viewFeedback.dart';

import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'Vendordb .dart';
import 'aboutus.dart';
import 'orderhistory.dart';
import 'passwordchange.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  LocationData? _currentLocation;
  var ven_id = 0;
  bool _locationUpdated = false; // Track the location update status
  var v_p_id = 0;

  @override
  void initState() {
    _getUserInfo();
    getStars();
    super.initState();
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

      ven_id = jsonResponse['vendor']['id'];

      setState(() {
        vendorJsonResponse = jsonResponse;
      });

      // Check if the location is already updated
      if (vendorJsonResponse != null &&
          (vendorJsonResponse["vendor"]["latitude"].isNotEmpty ||
              vendorJsonResponse["vendor"]["longitude"].isNotEmpty)) {
        // Location already updated, hide the button
        setState(() {
          _locationUpdated = true;
        });
      }
    } else {
      // Handle error here
    }
  }

  void getStars() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        _user = response.data as User?;
      });

      var rsp = await http.get(
        Uri.parse('http://dev.codesisland.com/api/vendorprofile/${_user?.id}'),
      );
      var jsonResponse = jsonDecode(rsp.body);
      v_p_id = jsonResponse['vendor']['id'];

      print("object");
      print(v_p_id);
      var riderResponse = await http.get(
        Uri.parse('http://dev.codesisland.com/api/vendorFeedback/$v_p_id'),
      );
      var jstar = jsonDecode(riderResponse.body);

      setState(() {
        riderjr = jstar;
      });
    } else {
      // Handle error here
    }
  }

  Future<void> _updateVendorLocation(
      double latitude, double longitude, LocationData locationData) async {
    print(ven_id);
    String url = 'http://dev.codesisland.com/api/updatevendorlocation/$ven_id';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
        body: {
          "latitude": latitude.toString(),
          "longitude": longitude.toString()
        },
      );
      if (response.statusCode == 200) {
        print('Location update request sent successfully.');
        Fluttertoast.showToast(
          msg: 'Location Successfully updated',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green, // Change to your desired color
          textColor: Colors.white, // Change to your desired color
        );
      } else {
        print(
            'Location update request failed with status code ${response.statusCode}');
        Fluttertoast.showToast(
          msg: 'Location do not update',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green, // Change to your desired color
          textColor: Colors.white, // Change to your desired color
        );
      }
      // Update the _currentLocation and set locationUpdated to true
      setState(() {
        _currentLocation = locationData;
        _locationUpdated = true;
      });
    } catch (e) {
      // Exception occurred
      print('Exception occurred while updating order status: $e');
      Fluttertoast.showToast(
        msg: 'Error occurred while sending the request',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red, // Change to your desired color
        textColor: Colors.white, // Change to your desired color
      );
    }
  }

  Future<void> requestUpdateLocation() async {
    String url =
        'http://dev.codesisland.com/api/appvendorRequestLocation/$ven_id';

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
        body: {},
      );

      print(response.statusCode);
      if (response.statusCode == 422) {
        Fluttertoast.showToast(
          msg: 'Location update request already sended.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red, // Change to your desired color
          textColor: Colors.white, // Change to your desired color
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Location update request send successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green, // Change to your desired color
          textColor: Colors.white, // Change to your desired color
        );
      }
      // Update the _currentLocation and set locationUpdated to true
    } catch (e) {
      // Exception occurred
      print('Exception occurred while updating order status: $e');
      Fluttertoast.showToast(
        msg: 'Error occurred while sending the request',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red, // Change to your desired color
        textColor: Colors.white, // Change to your desired color
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white, // Set the background color to white
          elevation: 0, // Remove the elevation shadow
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios, // iOS-style back button
              color: Colors.black, // Back button color
            ),
            onPressed: () {
              // Navigate back when the back button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const VendorDashboard()),
              );
            },
          ),
        ),
        body: FutureBuilder(
            future: getUserDetail(), // Replace with your data-loading method
            builder:
                (BuildContext context, AsyncSnapshot<ApiResponse> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a CircularProgressIndicator while data is loading
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green), // Change the color to green
                  ),
                );
              } else if (snapshot.hasError) {
                // Handle error state
                return Center(
                    child: Text('Error: ${snapshot.error.toString()}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                // Handle no data available
                return const Center(child: Text('No data available'));
              } else {
                // Data
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 70,
                        child: Image.asset('images/profilepic.jpg'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Display the star icon and rating number below the name
                          Text(
                            ' ${vendorJsonResponse != null ? vendorJsonResponse["vendor"]["name"] : " "}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' ${vendorJsonResponse != null ? vendorJsonResponse["vendor"]["shop_name"] : " "}',
                            style: const TextStyle(
                              fontSize: 22,
                              // fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Rating  ',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                // riderjr
                                '${riderjr != null ? riderjr["avg"] : " "}',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors
                                    .yellow, // You can customize the star color
                                size:
                                    28, // You can adjust the size of the star icon
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              id: vendorJsonResponse != null &&
                                      vendorJsonResponse["vendor"]["id"] != null
                                  ? vendorJsonResponse["vendor"]["id"]
                                      .toString()
                                  : '',
                              name: vendorJsonResponse != null &&
                                      vendorJsonResponse["vendor"]["name"] !=
                                          null
                                  ? vendorJsonResponse["vendor"]["name"]
                                  : '',
                              email: vendorJsonResponse != null &&
                                      vendorJsonResponse["vendor"]["email"] !=
                                          null
                                  ? vendorJsonResponse["vendor"]["email"]
                                  : '',
                              phone: vendorJsonResponse != null &&
                                      vendorJsonResponse["vendor"]["phone"] !=
                                          null
                                  ? vendorJsonResponse["vendor"]["phone"]
                                  : '',
                              address: vendorJsonResponse != null &&
                                      vendorJsonResponse["vendor"]["address"] !=
                                          null
                                  ? vendorJsonResponse["vendor"]["address"]
                                  : '',
                              shop: vendorJsonResponse != null &&
                                      vendorJsonResponse["vendor"]
                                              ["shop_name"] !=
                                          null
                                  ? vendorJsonResponse["vendor"]["shop_name"]
                                  : '',
                            ),
                          ),
                        );
                      },
                      child: const Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: ListTile(
                          leading: Icon(Icons.person_outline),
                          title: Text('Edit Profile'),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Visibility(
                          visible:
                              !_locationUpdated, // Hide the button if location is updated
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: InkWell(
                              onTap: () async {
                                var locationData =
                                    await Navigator.push<LocationData>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UpdateLocationScreen(),
                                  ),
                                );
                                if (locationData != null) {
                                  double latitude = locationData.latitude!;
                                  double longitude = locationData.longitude!;

                                  print(
                                      "Latitude: $latitude, Longitude: $longitude");

                                  // Call the API to update the vendor's location
                                  _updateVendorLocation(
                                      latitude, longitude, locationData);
                                }
                              },
                              child: ListTile(
                                leading: const Icon(Icons.location_on),
                                title: const Text('Update Location'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _currentLocation != null
                                        ? Text(
                                            "Lat: ${_currentLocation!.latitude}, Lng: ${_currentLocation!.longitude}",
                                          )
                                        : const Text("Tap to update location"),
                                    _currentLocation != null
                                        ? const Text("Location Updated")
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              _locationUpdated, // Show the button if location is updated
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: InkWell(
                              onTap: () {
                                // Your code for handling request location update here
                                requestUpdateLocation();
                              },
                              child: const ListTile(
                                leading: Icon(Icons.request_page_outlined),
                                title: Text('Request Update Location'),
                                // trailing: Icon(Icons.arrow_forward_ios),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OrderHistory()),
                          );
                        },
                        child: const ListTile(
                          leading: Icon(Icons.history),
                          title: Text('View Order History'),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PaymentHistory()),
                          );
                        },
                        child: const ListTile(
                          leading: Icon(Icons.payment_outlined),
                          title: Text('Pending Payments'),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewFeedbackPage(
                                id: vendorJsonResponse != null &&
                                        vendorJsonResponse["vendor"]["id"] !=
                                            null
                                    ? vendorJsonResponse["vendor"]["id"]
                                        .toString()
                                    : '',
                              ),
                            ),
                          );
                        },
                        child: const ListTile(
                          leading: Icon(Icons.feedback_outlined),
                          title: Text('View Feedback'),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AboutUsScreen()),
                          );
                        },
                        child: const ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('About Us'),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PasswordChangeScreen(
                                id: vendorJsonResponse != null &&
                                        vendorJsonResponse["vendor"]["id"] !=
                                            null
                                    ? vendorJsonResponse["vendor"]["id"]
                                        .toString()
                                    : '',
                              ),
                            ),
                          );
                        },
                        child: const ListTile(
                          leading: Icon(Icons.lock_outline),
                          title: Text('Change Password'),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: InkWell(
                        onTap: () {
                          logout().then((value) => {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => const Login()),
                                    (route) => false)
                              });
                        },
                        child: const ListTile(
                          leading: Icon(Icons.logout),
                          title: Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            }));
  }
}

dynamic vendorJsonResponse;
dynamic riderjr;
