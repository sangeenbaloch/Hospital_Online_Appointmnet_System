import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  // Profile fields
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController(text: "Dr. Sangeen Murad");
  final TextEditingController _emailController = TextEditingController(text: "doctor@example.com");
  final TextEditingController _phoneController = TextEditingController(text: "+92 300 1234567");
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _specialityController = TextEditingController();

  // For search filter of degree (optional)
  String _searchDegreeTerm = "";
  final List<String> _degrees = [];

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _degreeController.dispose();
    _specialityController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
    }

  Future<void> _loadDoctorProfile() async {
  // Simulate fetching from backend (you’ll replace this later)
    await Future.delayed(const Duration(milliseconds: 500));
    
    const previousBio =
      "Experienced Cardiologist with over 10 years in patient care, research, and teaching.";
      
      setState(() {
        _bioController.text = previousBio;
        });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC2ECE4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile picture + edit
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF00897B),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form fields in white card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(2, 3))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  const Text(
                    'Name',
                    style: TextStyle(
                      fontFamily: 'PT Sans',
                      color: Color(0xFF333333),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontFamily: 'PT Sans',
                      color: Color(0xFF333333),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Phone
                  const Text(
                    'Phone Number',
                    style: TextStyle(
                      fontFamily: 'PT Sans',
                      color: Color(0xFF333333),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  //Bio
                  const Text(
                    'Bio',
                    style: TextStyle(
                      fontFamily: 'PT Sans',
                      color: Color(0xFF333333),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Write a short professional bio',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Speciality
                  const Text(
                    'Speciality / Department',
                    style: TextStyle(
                      fontFamily: 'PT Sans',
                      color: Color(0xFF333333),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _specialityController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Cardiology',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Degrees + add
                  const Text(
                    'Degrees / Certifications',
                    style: TextStyle(
                      fontFamily: 'PT Sans',
                      color: Color(0xFF333333),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _degreeController,
                    decoration: InputDecoration(
                      hintText: 'Add a degree, e.g. MBBS, MD',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF00897B)),
                        onPressed: () {
                          final deg = _degreeController.text.trim();
                          if (deg.isNotEmpty) {
                            setState(() {
                              _degrees.add(deg);
                              _degreeController.clear();
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Search among degrees
                  if (_degrees.isNotEmpty) ...[
                    TextFormField(
                      onChanged: (val) {
                        setState(() {
                          _searchDegreeTerm = val.trim().toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search degrees',
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Show filtered list
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _degrees.where((deg) {
                        if (_searchDegreeTerm.isEmpty) return true;
                        return deg.toLowerCase().contains(_searchDegreeTerm);
                      }).map((deg) {
                        return ListTile(
                          title: Text(deg),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                _degrees.remove(deg);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Save / Update button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final bio = _bioController.text.trim();
                        // TODO: send `bio` and other updated fields to backend later

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profile updated\nBio: $bio'),
                            backgroundColor: const Color(0xFF00897B),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontFamily: 'PT Sans',
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}