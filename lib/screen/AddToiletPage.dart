import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddToiletPage extends StatefulWidget {
  @override
  _AddToiletPageState createState() => _AddToiletPageState();
}

class _AddToiletPageState extends State<AddToiletPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _toiletNameController = TextEditingController();
  final TextEditingController _amenitiesController = TextEditingController();

  LatLng? _selectedLocation; // To store the selected location
  bool _isSubmitting = false; // To manage loading state

  @override
  void dispose() {
    _toiletNameController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  void _selectLocation(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Location selected: (${position.latitude}, ${position.longitude})',
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      setState(() {
        _isSubmitting = true;
      });

      final toiletName = _toiletNameController.text;
      final amenities = _amenitiesController.text;

      try {
        // Add toilet data to Firestore
        await FirebaseFirestore.instance.collection('toilets').add({
          'name': toiletName,
          'amenities': amenities,
          'location': {
            'latitude': _selectedLocation!.latitude,
            'longitude': _selectedLocation!.longitude,
          },
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Toilet "$toiletName" added successfully!',
            ),
          ),
        );

        // Optionally, clear the form fields
        _formKey.currentState!.reset();
        setState(() {
          _selectedLocation = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding toilet: $e'),
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Toilet'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // Default location (San Francisco)
                zoom: 12,
              ),
              onTap: _selectLocation,
              markers: _selectedLocation != null
                  ? {
                Marker(
                  markerId: const MarkerId('selected-location'),
                  position: _selectedLocation!,
                ),
              }
                  : {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _toiletNameController,
                    decoration: const InputDecoration(
                      labelText: 'Toilet Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the toilet name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amenitiesController,
                    decoration: const InputDecoration(
                      labelText: 'Amenities (e.g., soap, hand dryer, etc.)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the amenities';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                          : const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
