import 'package:expenser/split_amount.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'logic/get_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/unpaid_widget.dart';
import 'widgets/paid_widget.dart';
import 'widgets/splitByMeWidget.dart';
import 'expenses.dart';
import 'user_dashboard.dart';
import 'constants/app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
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
      print('Creating NetworkImage for: $profilePicture');
      return NetworkImage(profilePicture);
    }
    
    // If it's a local asset path
    if (profilePicture.startsWith('assets/')) {
      print('Creating AssetImage for: $profilePicture');
      return AssetImage(profilePicture);
    }
    
    print('Profile picture format not recognized: $profilePicture');
    return null;
  }

  List<Map<String, dynamic>> _allData = [];
  Map<String, dynamic> _userProfile = {};
  Map<String, double> _totalAmounts = {'owedToMe': 0.0, 'owedByMe': 0.0};
  bool _isLoading = true;
  String? _currentUserMobile;
  late FocusNode _focusNode;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      // Get current user's mobile number
      final user = FirebaseAuth.instance.currentUser;
      _currentUserMobile = user?.phoneNumber;
      if (_currentUserMobile != null) {
        // Load all data
        final userProfile = await GetData.getUserProfile(_currentUserMobile!);
        final allData = await GetData.getAllUserData(_currentUserMobile!);
        setState(() {
          _allData = allData;
          _userProfile = userProfile;
          _totalAmounts = {
                            'owedToMe': userProfile['to_get'],
                            'owedByMe': userProfile['to_pay'],
                          };
          _isLoading = false;
        });
        
        // Scroll to bottom after data is loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
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

  // Method to refresh data (can be called from anywhere)
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(      
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserDashboard()));
                  },
                  child: Builder(
                    builder: (context) {
                      final imageProvider = _getProfileImageProvider(_userProfile["profile_picture"]);
                      return CircleAvatar(
                        radius: 25,
                        backgroundImage: imageProvider,
                        child: imageProvider == null ? const Icon(Icons.person) : null,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userProfile['full_name'] ?? AppConstants.DEFAULT_USER_NAME,
                        style: const TextStyle(
                          fontSize: AppConstants.FONT_XLARGE,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.add_circle, color: Colors.green[600], size: 16),
                          const SizedBox(width: 4),
                          const Text(
                            AppConstants.LABEL_OWED_TO_ME,
                            style: TextStyle(fontSize: AppConstants.FONT_MEDIUM, color: Colors.black54),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            GetData.formatAmount(_totalAmounts['owedToMe'] ?? 0.0),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.remove_circle, color: Colors.red[600], size: 16),
                          const SizedBox(width: 4),
                          const Text(
                            AppConstants.LABEL_OWED_BY_ME,
                            style: TextStyle(fontSize: AppConstants.FONT_MEDIUM, color: Colors.black54),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            GetData.formatAmount(_totalAmounts['owedByMe'] ?? 0.0),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpensesPage()));
                    },
                    child: Image.asset(
                      AppConstants.ASSET_BILL_LOGO,
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
                
              ],
            ),
          ),

          // Date separator
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Divider(color: Colors.grey[300]),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //         child: Text(
          //           "1 July, 2025",
          //           style: TextStyle(
          //             color: Colors.grey[600],
          //             fontSize: 14,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ),
          //       Expanded(
          //         child: Divider(color: Colors.grey[300]),
          //       ),
          //     ],
          //   ),
          // ),

          // Widgets list
          SizedBox(height: 5),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allData.isEmpty 
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView(
                          controller: _scrollController,
                          children: [
                            // Generate widgets from real data
                            ..._allData.map((data) {
                              if (data["type"] == 1) {
                                return SplitByMeWidget(data: data);
                              } else if (data["type"] == 0) {
                                if(data["status"] == "Paid") {
                                  return PaidWidget(data: data);
                                } else {
                                  return UnpaidWidget(data: data);
                                }
                              } 

                              return UnpaidWidget(data: data);
                            }),
                          ],
                        ),
                      ),
          ),

          // Bottom button
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6 , 12, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF29B6F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => SplitAmountPage(
                        onDataSaved: _refreshData,
                      ),
                    ),
                  );
                  // Handle split expense button press
                },
                child: const Text(
                  AppConstants.BUTTON_SPLIT_EXPENSE,
                  style: TextStyle(
                    fontSize: AppConstants.FONT_XXLARGE,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppConstants.ASSET_NULL_IMAGE,
            height: 200,
            width: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            AppConstants.LABEL_NO_SPLIT_EXPENSES,
            style: TextStyle(
              fontSize: AppConstants.FONT_XLARGE,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppConstants.LABEL_CREATE_FIRST_SPLIT,
            style: TextStyle(
              fontSize: AppConstants.FONT_MEDIUM,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


}
