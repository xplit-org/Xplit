import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logic/get_data.dart';
import 'constants/app_constants.dart';


class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  // Helper function to create ImageProvider for profile pictures
  ImageProvider? _getProfileImageProvider(String? profilePicture) {    
    if (profilePicture == null || profilePicture.isEmpty) {
      print('Profile picture is null or empty');
      return null;
    }
    
    // Check if it's a base64 image
    if (profilePicture.startsWith('data:image/')) {
      try {
        // Extract base64 data from the data URL
        final base64Data = profilePicture.split(',')[1];
        final bytes = base64Decode(base64Data);
        print('Successfully created MemoryImage from base64');
        return MemoryImage(bytes);
      } catch (e) {
        print('Error decoding base64 image: $e');
        return null;
      }
    }
    
    // Check if it's a network URL
    if (profilePicture.startsWith('http://') || profilePicture.startsWith('https://')) {
      return NetworkImage(profilePicture);
    }
    
    // If it's a local asset path
    if (profilePicture.startsWith('assets/')) {
      return AssetImage(profilePicture);
    }
    return null;
  }

  Map<String, dynamic> _userData = {};
  bool _isLoading = true;
  String? _currentUserMobile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Get current user's mobile number
      final user = FirebaseAuth.instance.currentUser;
      _currentUserMobile = user?.phoneNumber;
      if (_currentUserMobile != null) {
        // Load all data
        final userProfile = await GetData.getUserProfile(_currentUserMobile!);

        setState(() {
          _userData = userProfile;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String formatPhoneNumber(String number) {
    // Remove spaces, dashes, and brackets
    String cleaned = number.replaceAll(RegExp(r'\D'), '');

    // If it already starts with country code (+91)
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      return '+$cleaned';
    }

    // If it starts with 0, remove it
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    // If it's a 10-digit Indian number, add +91
    if (cleaned.length == 10) {
      return '+91$cleaned';
    }

    // Fallback (just return as-is with +)
    return '+$cleaned';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "";
    List<String> parts = name.trim().split(" ");
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }


  void _showInviteFriendsDialog() {
    final String shareLink =
        'https://expenser.app/invite/${_userData?['mobile_number'] ?? 'N/A'}';
    final String shareText =
        'Check out this awesome expense sharing app! Join me using this link: $shareLink';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                AppConstants.DIALOG_INVITE_FRIENDS_TITLE,
                style: TextStyle(
                  fontSize: AppConstants.FONT_XXLARGE,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Share link container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          shareLink,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Copy Link Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: shareLink));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppConstants.SUCCESS_LINK_COPIED),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, color: Colors.white),
                    label: const Text(
                      AppConstants.BUTTON_COPY_LINK,
                      style: TextStyle(
                        fontSize: AppConstants.FONT_LARGE,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Share Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Add share functionality here
                    },
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text(
                      AppConstants.BUTTON_SHARE,
                      style: TextStyle(
                        fontSize: AppConstants.FONT_LARGE,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  void _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to copy link'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAddFriendDialog() async {
    try {
      // Request permission (flutter_contacts handles both Android/iOS)
      bool hasPermission = await FlutterContacts.requestPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contacts permission is required to add friends'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Get contacts with phone numbers
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      print('Contacts: ${contacts}');

      if (contacts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No contacts found'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      List<Contact> filteredContacts = List.from(contacts);
      final TextEditingController searchController = TextEditingController();
      final FocusNode searchFocusNode = FocusNode();

      print('Contacts: $contacts');

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            searchFocusNode.requestFocus();
          });

          return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.92,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          const Text(
                            'Add friends from your contacts',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 28),
                          ),
                        ],
                      ),
                    ),

                    // Search Box
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: searchController,
                          focusNode: searchFocusNode,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            hintText: 'Search in contacts',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setModalState(() {
                              filteredContacts = contacts.where((contact) {
                                final name = contact.displayName.toLowerCase();
                                final phone = contact.phones.isNotEmpty
                                    ? formatPhoneNumber(
                                        contact.phones.first.number,
                                      )
                                    : '';
                                return name.contains(value.toLowerCase()) ||
                                    phone.contains(value);
                              }).toList();
                            });
                          },
                        ),
                      ),
                    ),

                    // Contacts List
                    Expanded(
                      child: filteredContacts.isEmpty
                          ? const Center(child: Text("No contacts found"))
                          : ListView.builder(
                              itemCount: filteredContacts.length,
                              itemBuilder: (context, index) {
                                final contact = filteredContacts[index];
                                final phone = contact.phones.isNotEmpty
                                    ? formatPhoneNumber(contact.phones.first.number)
                                    : 'No number';
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    backgroundImage: contact.photo != null && contact.photo!.isNotEmpty
                                        ? MemoryImage(contact.photo!)
                                        : null,
                                    child: contact.photo == null || contact.photo!.isEmpty
                                        ? Text(
                                            _getInitials(contact.displayName),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    contact.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    phone,
                                  ), // now always with +91 if applicable
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Friend request sent to $phone',
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text("Add"),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      print('Error in _showAddFriendDialog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _logout() async {
    // Show confirmation dialog
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    // If user confirms logout, proceed
    if (shouldLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } catch (e) {
        print('Error logging out: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Header with Back Button
                      _buildHeader(),

                      // Profile Section
                      _buildProfileSection(),

                      const SizedBox(height: 40),

                      // Friend Management Section
                      _buildFriendManagementSection(),
                    ],
                  ),
            
            // Transparent Logout Button at Bottom Right
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.black87,
                    size: 24,
                  ),
                  tooltip: 'Logout',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          const Text(
            AppConstants.PROFILE_TITLE,
            style: TextStyle(fontSize: AppConstants.FONT_XXLARGE, color: Colors.black87),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black87),
            onPressed: () {
              // TODO: Implement notification logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Profile Picture (Left)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Builder(
                builder: (context) {
                  final imageProvider = _getProfileImageProvider(_userData["profile_picture"]);
                  return imageProvider != null
                      ? Image(image: imageProvider, fit: BoxFit.cover)
                      : Image.asset(AppConstants.ASSET_PROFILE_PIC, fit: BoxFit.cover);
                },
              ),
            ),
          ),

          const SizedBox(width: 20),

          // User Details (Right)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  _userData?['full_name'] ?? AppConstants.DEFAULT_USER_NAME,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                // UPI ID
                Row(
                  children: [
                    const SizedBox(width: 8),
                    const Text(
                      'UPI: ',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Expanded(
                      child: Text(
                        _userData?['upi_id'] ?? AppConstants.DEFAULT_UPI_ID,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Mobile Number
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '+91 ${_userData?['mobile_number'] ?? AppConstants.DEFAULT_MOBILE}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendManagementSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Invite Friends Button
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showInviteFriendsDialog,
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text(
                AppConstants.PROFILE_INVITE_FRIENDS,
                style: TextStyle(
                  fontSize: AppConstants.FONT_LARGE,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Add Friends Button
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddFriendDialog,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                AppConstants.PROFILE_ADD_FRIENDS,
                style: TextStyle(
                  fontSize: AppConstants.FONT_LARGE,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildNoDataUI() {
    return Column(
      children: [
        // Header Section
        _buildHeader(),

        // No Data Section
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    AppConstants.LABEL_LOADING_PROFILE,
                    style: TextStyle(
                      fontSize: AppConstants.FONT_XXLARGE,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppConstants.LABEL_WAIT_LOADING_PROFILE,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: AppConstants.FONT_LARGE, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
