import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  XFile? _image;
  String? _imageUrl;
  bool _isLoading = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchUserId(); // Fetch the user ID and load the image from Firebase
  }

  Future<void> _fetchUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      _loadProfileImage(); // Load the profile image once we have the user ID
    }
  }

  // Function to load the profile image
  Future<void> _loadProfileImage() async {
    setState(() {
      _isLoading = true; // Show loading indicator during fetching
    });

    try {
      if (userId != null) {
        // First, try to load the image URL from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        // If a profile image URL exists in Firestore, use that
        if (userDoc.exists && userDoc['profileImage'] != null) {
          setState(() {
            _imageUrl = userDoc['profileImage'];
          });
        } else {
          // Fallback: Load image from Firebase Storage if not found in Firestore
          String imageUrl = await FirebaseStorage.instance
              .ref('profile_pictures/$userId.jpg')
              .getDownloadURL();

          setState(() {
            _imageUrl = imageUrl;
          });

          // Optionally, save the URL in Firestore for future use
          await _saveImageUrl(imageUrl);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load profile image: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Save the image URL to Firestore
  Future<void> _saveImageUrl(String url) async {
    try {
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'profileImage': url});
        print('Image URL updated in Firestore: $url');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save image URL: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Upload image to Firebase Storage and update Firestore
  Future<void> _uploadImage(XFile image) async {
    setState(() {
      _isLoading = true; // Show loading indicator during upload
    });

    try {
      if (userId != null) {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child('profile_pictures/$userId.jpg');

        UploadTask uploadTask = ref.putFile(File(image.path));
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Save the download URL to Firestore
        await _saveImageUrl(downloadUrl);

        // Update the UI with the new image URL
        setState(() {
          _imageUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Image uploaded successfully!'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error uploading image: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false; // Hide the loading indicator
      });
    }
  }

  // Picking image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _image = image;
        });
        await _uploadImage(image); // Upload the selected image
      } else {
        print('No image selected.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error picking image: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 80),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      Hero(
                        tag: 'profile-pic',
                        child: CircleAvatar(
                          radius: 60,
                          key: ValueKey(_imageUrl),
                          backgroundImage: _imageUrl != null
                              ? CachedNetworkImageProvider(_imageUrl!)
                              : AssetImage('assets/images/user_profile.jpeg')
                          as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => _imagePickerOptions(),
                            );
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ),
                      if (_isLoading)
                        Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Rest of the UI
          Padding(
            padding: const EdgeInsets.only(top: 220.0, left: 16.0, right: 16.0),
            child: ListView(
              children: [
                _buildProfileButton('Address', Icons.location_on),
                _buildProfileButton('Your Pets', Icons.pets),
                _buildProfileButton('Rating', Icons.star),
                _buildProfileButton('Bookings', Icons.book),
                _buildProfileButton('About', Icons.info),
                _buildProfileButton('FAQs', Icons.help),
                _buildProfileButton('Logout', Icons.logout),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: title == 'Logout' ? _showLogoutDialog : () {},
        icon: Icon(icon, color: Colors.white),
        label: Text(title, style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: title == 'Logout' ? Colors.red : Colors.orange,
          padding: EdgeInsets.symmetric(vertical: 18.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _imagePickerOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.photo_library),
          title: Text('Choose from Gallery'),
          onTap: () {
            Navigator.pop(context);
            _pickImage(ImageSource.gallery);
          },
        ),
        ListTile(
          leading: Icon(Icons.camera_alt),
          title: Text('Take a Photo'),
          onTap: () {
            Navigator.pop(context);
            _pickImage(ImageSource.camera);
          },
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
