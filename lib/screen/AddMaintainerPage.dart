import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMaintainerPage extends StatefulWidget {
  @override
  _AddMaintainerPageState createState() => _AddMaintainerPageState();
}

class _AddMaintainerPageState extends State<AddMaintainerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _maintainerNameController = TextEditingController();
  final TextEditingController _maintainerContactController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _maintainerNameController.dispose();
    _maintainerContactController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final maintainerName = _maintainerNameController.text;
      final maintainerContact = _maintainerContactController.text;

      try {
        // Add maintainer to Firestore
        await FirebaseFirestore.instance.collection('maintainers').add({
          'name': maintainerName,
          'contact': maintainerContact,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maintainer added successfully!')),
        );

        // Optionally, clear the form
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding maintainer: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Maintainer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _maintainerNameController,
                decoration: const InputDecoration(
                  labelText: 'Maintainer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the maintainer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maintainerContactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Info',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the contact information';
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
    );
  }
}
