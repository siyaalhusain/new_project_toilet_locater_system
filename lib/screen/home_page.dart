import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart'; // Import the location package
import 'package:project_x/screen/profile_page.dart';
import 'explore_page.dart';
import 'notifications_page.dart';
import 'search_page.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String loggedInUserRole;

  HomePage({required this.loggedInUserRole});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {}; // Set to store the polylines
  late GoogleMapController _mapController;

  // Firestore reference to the toilets collection
  final CollectionReference toiletsCollection =
  FirebaseFirestore.instance.collection('toilets');

  // User's current location
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _getUserLocation(); // Get user location on init
  }

  // Get the current location of the user
  void _getUserLocation() async {
    Location location = Location();

    bool _serviceEnabled = await location.serviceEnabled();
    PermissionStatus _permissionGranted = await location.hasPermission();

    if (!_serviceEnabled) {
      await location.requestService();
    }

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }

    if (_permissionGranted == PermissionStatus.granted) {
      var currentLocation = await location.getLocation();
      setState(() {
        _userLocation =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });

      // Move the camera to the user's location
      if (_mapController != null && _userLocation != null) {
        _mapController.animateCamera(
          CameraUpdate.newLatLng(_userLocation!),
        );
      }
    }
  }

  // Fetch and load markers from Firestore
  void _loadMarkers() async {
    QuerySnapshot querySnapshot = await toiletsCollection.get();
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      double latitude = data['location']['latitude'];
      double longitude = data['location']['longitude'];
      String amenities = data['amenities'] ?? 'No amenities listed';
      String name = data['name'] ?? 'Unnamed Toilet';
      Timestamp timestamp = data['timestamp'];
      DateTime time = timestamp.toDate();

      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(
              title: name,
              snippet: 'Amenities: $amenities\nLast updated: ${time.toLocal()}',
            ),
            onTap: () async {
              if (_userLocation != null) {
                String duration = await _getDirections(
                  _userLocation!,
                  LatLng(latitude, longitude),
                );
                _showRouteDialog(name, duration);
              }
            },
          ),
        );
      });
    }
  }

  // Method to calculate the shortest path using the Google Maps Directions API
  Future<String> _getDirections(LatLng origin, LatLng destination) async {
    String googleAPIKey = 'AIzaSyC3AXw-RcPsAR5s9Cgr84chOLDYT575ZM4';
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$googleAPIKey';

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'OK') {
          var route = jsonData['routes'][0]['legs'][0];
          var steps = route['steps'];

          List<LatLng> polylinePoints = [];
          for (var step in steps) {
            polylinePoints.add(LatLng(step['end_location']['lat'], step['end_location']['lng']));
          }

          // Create a polyline and add it to the map
          setState(() {
            _polylines.clear(); // Clear previous routes
            _polylines.add(Polyline(
              polylineId: PolylineId('route'),
              points: polylinePoints,
              color: Colors.blue,
              width: 5,
            ));
          });

          return route['duration']['text']; // Return the duration of the route
        } else {
          return 'Error calculating route: ${jsonData['status']}';
        }
      } else {
        return 'HTTP Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error calculating route';
    }
  }

  // Show the route dialog with the duration
  void _showRouteDialog(String toiletName, String duration) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Route to $toiletName'),
          content: Text('Estimated time: $duration'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ExplorePage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationPage()),
      );
    } else if (index == 3) {
      _navigateToProfilePage();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _navigateToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(role: widget.loggedInUserRole),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _userLocation != null
                ? CameraPosition(
              target: _userLocation!, // Set the camera position to the user's location
              zoom: 12,
            )
                : CameraPosition(
              target: LatLng(37.7749, -122.4194), // Default location (San Francisco)
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines, // Add the polylines to the map
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true, // Show the user location on the map
          ),
          if (_selectedIndex == 0)
            Center(
              child: Text(
                'Welcome, ${widget.loggedInUserRole}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
