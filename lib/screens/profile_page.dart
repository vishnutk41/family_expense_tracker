import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/constants.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/services.dart';
import '../providers/firebase_providers.dart';

@RoutePage()
class ProfilePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authViewModelProvider).value;
      if (user != null) {
        ref.read(profileViewModelProvider.notifier).loadUserProfile(user.uid);
      }
      ref.read(firebaseMessagingProvider).getToken().then((t) {
        if (mounted) setState(() => _fcmToken = t);
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final user = ref.read(authViewModelProvider).value;
    if (user == null) return;
    final profileViewModel = ref.read(profileViewModelProvider.notifier);
    try {
      // Show dialog to choose source
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Image Source'),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.photo_camera),
              label: Text('Camera'),
              onPressed: () => Navigator.pop(context, ImageSource.camera),
            ),
            TextButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text('Gallery'),
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      );
      if (source == null) return;
      final imageFile = await profileViewModel.pickImage(source);
      if (imageFile != null) {
        await profileViewModel.uploadProfileImage(user.uid, imageFile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image updated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile image: $e')),
      );
    }
  }

  Future<void> _updateName() async {
    final user = ref.read(authViewModelProvider).value;
    if (user == null) return;
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }
    final profileViewModel = ref.read(profileViewModelProvider.notifier);
    try {
      await profileViewModel.updateUserName(user.uid, newName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update name: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final user = ref.watch(authViewModelProvider).value;
    final profileViewModel = ref.read(profileViewModelProvider.notifier);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: Text('Not authenticated')),
      );
    }

    if (profileState.error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: Text('Error: ${profileState.error}')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.logout, color: Colors.white),
            label: Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              try {
                final authViewModel = ref.read(authViewModelProvider.notifier);
                await authViewModel.signOut();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
          ),
        ],
      ),
      body: profileState.isLoading
          ? Center(child: CircularProgressIndicator())
          : profileState.user == null
              ? Center(child: Text('Failed to load profile'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Image Section
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: profileState.user!.profileImageUrl != null
                                          ? NetworkImage(profileState.user!.profileImageUrl!)
                                          : null,
                                      child: profileState.user!.profileImageUrl == null
                                          ? Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.grey[400],
                                            )
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.teal,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.camera_alt, color: Colors.white),
                                          onPressed: _pickAndUploadImage,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                // Remove the instruction text for changing profile picture
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Profile Details Section
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                                SizedBox(height: 20),

                                // Name Field
                                Row(
                                  children: [
                                    Expanded(
                                      child: profileState.isEditingName
                                          ? TextField(
                                              controller: _nameController,
                                              decoration: InputDecoration(
                                                labelText: 'Full Name',
                                                border: OutlineInputBorder(),
                                                prefixIcon: Icon(Icons.person),
                                              ),
                                            )
                                          : ListTile(
                                              leading: Icon(Icons.person, color: Colors.teal),
                                              title: Text('Full Name'),
                                              subtitle: Text(
                                                profileState.user!.name,
                                                style: TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                    ),
                                    if (!profileState.isEditingName)
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.teal),
                                        onPressed: () => profileViewModel.setEditingName(true),
                                      ),
                                  ],
                                ),
                                if (profileState.isEditingName) ...[
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _updateName,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text('Save'),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            profileViewModel.setEditingName(false);
                                            _nameController.text = profileState.user!.name;
                                          },
                                          child: Text('Cancel'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                SizedBox(height: 16),

                                // Email Field
                                ListTile(
                                  leading: Icon(Icons.email, color: Colors.teal),
                                  title: Text('Email'),
                                  subtitle: Text(
                                    profileState.user!.email,
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(height: 16),

                                // Family ID Field
                                ListTile(
                                  leading: Icon(Icons.family_restroom, color: Colors.teal),
                                  title: Text('Family ID'),
                                  subtitle: Text(
                                    profileState.user!.familyId ?? 'Not joined to any family',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(height: 16),

                                ListTile(
                                  leading: Icon(Icons.notifications, color: Colors.teal),
                                  title: Text('FCM Token'),
                                  subtitle: Text(
                                    _fcmToken ?? 'Fetching...',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.copy, color: Colors.teal),
                                    onPressed: _fcmToken == null
                                        ? null
                                        : () async {
                                            await Clipboard.setData(ClipboardData(text: _fcmToken!));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Copied to clipboard')),
                                            );
                                          },
                                  ),
                                ),
                                SizedBox(height: 16),

                                // Created Date Field
                                if (profileState.user!.createdAt != null)
                                  ListTile(
                                    leading: Icon(Icons.calendar_today, color: Colors.teal),
                                    title: Text('Member Since'),
                                    subtitle: Text(
                                      '${profileState.user!.createdAt!.day}/${profileState.user!.createdAt!.month}/${profileState.user!.createdAt!.year}',
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
