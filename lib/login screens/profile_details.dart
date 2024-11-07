import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pets_app/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CompleteProfilePage extends StatefulWidget {
  @override
  _CompleteProfilePageState createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _petNameController = TextEditingController();

  final List<String> _animals = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Fish'];
  String? _selectedAnimal;
  final List<String> _dogBreeds = ['Labrador', 'Poodle', 'Bulldog'];
  final List<String> _catBreeds = ['Persian', 'Maine Coon', 'Siamese'];
  final List<String> _birdBreeds = ['Parrot', 'Canary', 'Cockatiel'];
  List<String> _breeds = [];
  File? _imageFile;
  String? _profileImageUrl;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      final docSnapshot = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (docSnapshot.exists) {
        final userData = docSnapshot.data();
        if (userData != null && userData['firstName'] != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
        setState(() {
          _firstNameController.text = userData?['firstName'] ?? '';
          _lastNameController.text = userData?['lastName'] ?? '';
          _addressController.text = userData?['address'] ?? '';
          _phoneController.text = userData?['phone'] ?? '';
          _emailController.text = _currentUser?.email ?? '';
          _loadProfileImage(userData?['profileImage']);
        });
      } else {
        setState(() {
          _firstNameController.text = _currentUser?.displayName ?? '';
          _emailController.text = _currentUser?.email ?? '';
        });
      }
    }
  }

  Future<void> _loadProfileImage(String? imagePath) async {
    if (imagePath != null) {
      try {
        final downloadUrl = await _storage.refFromURL(imagePath).getDownloadURL();
        setState(() {
          _profileImageUrl = downloadUrl;
        });
      } catch (e) {
        print('Error loading profile image: $e');
      }
    } else {
      setState(() {
        _profileImageUrl = 'assets/images/user_profile.jpeg';
      });
    }
  }


  Future<void> _submitProfile() async {
    if (_currentUser != null) {
      try {
        if (_imageFile != null) {
          // Upload image first if the user selected one
          final storageRef = _storage.ref().child('profile_pictures/${_currentUser!.uid}.jpeg');
          await storageRef.putFile(_imageFile!);
          _profileImageUrl = await storageRef.getDownloadURL();
        }

        // Save profile data along with the image URL to Firestore
        await _firestore.collection('users').doc(_currentUser!.uid).set({
          'uid': _currentUser!.uid,
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'petName': _petNameController.text,
          'animal': _selectedAnimal,
          'breed': _breeds.isNotEmpty ? _breeds.first : null,
          'profileImage': _profileImageUrl, // Save the profile image URL
        });

        // Navigate to HomePage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile completed successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        print('Error submitting profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit profile. Please try again.')),
        );
      }
    }
  }




  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      try {
        final storageRef = _storage.ref().child('profile_pictures/${_currentUser!.uid}');
        await storageRef.putFile(_imageFile!);
        final url = await storageRef.getDownloadURL();
        setState(() {
          _profileImageUrl = url;
        });
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload profile picture. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        title: Text('Complete Your Profile'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: Text(
              'Skip',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : AssetImage('assets/images/user_profile.jpeg') as ImageProvider,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Enter Your Pet Details'),
                ),
                Expanded(child: Divider(thickness: 1)),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _petNameController,
              decoration: InputDecoration(
                labelText: 'Pet Name',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAnimal,
              hint: Text('Select Animal'),
              onChanged: _onAnimalSelected,
              items: _animals.map((animal) {
                return DropdownMenuItem<String>(
                  value: animal,
                  child: Text(animal),
                );
              }).toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_selectedAnimal != null)
              DropdownButtonFormField<String>(
                hint: Text('Select Breed'),
                value: _breeds.isNotEmpty ? _breeds.first : null,
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      _breeds = [value];
                    }
                  });
                },
                items: _breeds.map((breed) {
                  return DropdownMenuItem<String>(
                    value: breed,
                    child: Text(breed),
                  );
                }).toList(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitProfile,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.deepOrangeAccent,
              ),
              child: Center(
                child: Text(
                  'Complete Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAnimalSelected(String? newValue) {
    setState(() {
      _selectedAnimal = newValue;
      switch (_selectedAnimal) {
        case 'Dog':
          _breeds = _dogBreeds;
          break;
        case 'Cat':
          _breeds = _catBreeds;
          break;
        case 'Bird':
          _breeds = _birdBreeds;
          break;
        default:
          _breeds = [];
      }
    });
  }
}
