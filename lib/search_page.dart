import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pets_app/petwalker_profile.dart';
import 'package:pets_app/profile_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? _profileImageUrl;
  String? _uid;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserUID();
  }

  Future<void> _loadUserUID() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uid = user.uid;
      _fetchProfileImage();
    } else {
      setState(() {
        _profileImageUrl = 'assets/images/user_profile.jpeg';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProfileImage() async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$_uid.jpeg');

      String imageUrl = await ref.getDownloadURL();
      setState(() {
        _profileImageUrl = imageUrl;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching profile image URL: $e');
      setState(() {
        _profileImageUrl = 'assets/images/user_profile.jpeg';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
              padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Search for Pet Walkers',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(_createRoute());
                    },
                    child: Hero(
                      tag: 'profile-pic',
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                            ? NetworkImage(_profileImageUrl!) as ImageProvider
                            : AssetImage('assets/images/user_profile.jpeg'),
                        child: _isLoading
                            ? CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 120),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.orange),
                    hintText: 'Enter city, pet type, etc.',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage('assets/images/petwalker.jpeg'),
                          ),
                          title: Text('Pet Walker ${index + 1}'),
                          subtitle: Text('Experience: ${index + 1} years'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PetWalkerProfilePage(
                                  profileImage: 'assets/images/petwalker.jpeg',
                                  name: 'Pet Walker ${index + 1}',
                                  bio: 'This is a bio of Pet Walker ${index + 1}.',
                                  rating: index % 2 == 0 ? 4.5 : null,
                                  experience: '${index + 1} years of experience',
                                  email: 'walker${index + 1}@example.com',
                                  phoneNumber: '123-456-789${index}',
                                  address: 'City, Country',
                                  reviews: index % 2 == 0
                                      ? ['Great walker!', 'Very punctual and caring.']
                                      : [],
                                  feePerHour: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
    );
  }
}
