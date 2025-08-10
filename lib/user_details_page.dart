import 'package:expenser/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'user_service.dart';

class UserDetailsPage extends StatefulWidget {
  final String mobileNumber;

  const UserDetailsPage({super.key, required this.mobileNumber});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _upiIdFocusNode = FocusNode();

  Uint8List? _image;
  void selectProfilePic() async{
    Uint8List img = await pickProfilePic(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill the mobile number from OTP verification
    // The mobile number will be displayed but not editable
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _upiIdController.dispose();
    _fullNameFocusNode.dispose();
    _upiIdFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xDF0439A4), Color(0xDF0439A4)],
          ),
        ),
        child: Column(
          children: [
            // Top Section - Illustration (40% of screen)
            Expanded(flex: 2, child: _buildTopSection()),

            // Bottom Section - User Details Form (60% of screen)
            Expanded(flex: 8, child: _buildBottomSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        child: Image.asset(
          'assets/image 4.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -8),
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeaderSection(),
              const SizedBox(height: 20),
              _buildProfilePictureSection(),
              const SizedBox(height: 20),
              _buildFormFields(),
              const SizedBox(height: 40),
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return const Center(
      child: Text(
        'Create Account',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: _image != null
                ? ClipOval(
                    child: Image.memory(
                      _image!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey,
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                onPressed: selectProfilePic,
                icon: const Icon(Icons.add_a_photo),
                color: Colors.white,
                iconSize: 18,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildFloatingLabelInputField(
          controller: _fullNameController,
          focusNode: _fullNameFocusNode,
          label: 'Full Name',
          hintText: 'Enter your full name',
          keyboardType: TextInputType.name,
        ),
        _buildMobileNumberField(),
        _buildUpiIdField(),
      ],
    );
  }
  

  Widget _buildFloatingLabelInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    required TextInputType keyboardType,
  }) {
    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildInputFieldContainer(focusNode),
          _buildFloatingLabel(label),
          _buildTextField(controller, focusNode, hintText, keyboardType),
        ],
      ),
    );
  }

  Widget _buildInputFieldContainer(FocusNode focusNode) {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF2196F3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingLabel(String label) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      top: 30,
      left: 12,
      child: Material(
        borderRadius: BorderRadius.circular(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 0,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2196F3),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    FocusNode focusNode,
    String hintText,
    TextInputType keyboardType,
  ) {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 8,
            ),
          ),
          keyboardType: keyboardType,
          enableInteractiveSelection: true,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          style: const TextStyle(fontSize: 14),
          onChanged: (value) {
            setState(() {
              // Trigger rebuild to update button state
            });
          },
        ),
      ),
    );
  }

  Widget _buildMobileNumberField() {
    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildMobileInputFieldContainer(),
          _buildMobileFloatingLabel(),
          _buildMobileNumberDisplay(),
        ],
      ),
    );
  }

  Widget _buildUpiIdField() {
    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildUpiInputFieldContainer(),
          _buildUpiFloatingLabel(),
          _buildUpiIdContent(),
        ],
      ),
    );
  }

  Widget _buildMobileInputFieldContainer() {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(
            color: const Color(0xFF2196F3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileFloatingLabel() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      top: 30,
      left: 12,
      child: Material(
        borderRadius: BorderRadius.circular(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 0,
          ),
          child: const Text(
            'Mobile Number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2196F3),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

Widget _buildCountryCodeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 12,
      ),
      child: Row(
        children: [
          const Text(
            '🇮🇳',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 6),
          const Text(
            '+91',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 2),
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildMobileNumberDisplay() {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Row(
          children: [
            _buildCountryCodeSelector(),
            _buildSeparator(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.mobileNumber,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiInputFieldContainer() {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF2196F3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpiFloatingLabel() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      top: 30,
      left: 12,
      child: Material(
        borderRadius: BorderRadius.circular(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 0,
          ),
          child: const Text(
            'UPI ID',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2196F3),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpiIdContent() {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 5, 0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _upiIdController,
                focusNode: _upiIdFocusNode,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter UPI ID (e.g., user@upi)',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _scanQrCode,
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: Color(0xFF2196F3),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanQrCode() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        _showSnack("No image selected", Colors.orange);
        return;
      }

      // Show loading with processing message
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Processing QR Code...",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );

      // Decode QR from image file using qr_code_tools
      final String? qrData = await QrCodeToolsPlugin.decodeFrom(image.path);

      Navigator.pop(context); // Close loading

      if (qrData != null && qrData.isNotEmpty) {
        debugPrint("QR Code decoded: $qrData");
        _extractUpiId(qrData);
      } else {
        _showSnack("No QR code found in this image.", Colors.orange);
      }
    } catch (e) {
      Navigator.pop(context);
      _showSnack("Error processing image: $e", Colors.red);
    }
  }

  void _extractUpiId(String qrData) {
    String upiId = '';

    if (qrData.startsWith('upi://pay')) {
      try {
        final uri = Uri.parse(qrData);
        upiId = uri.queryParameters['pa'] ?? '';
        debugPrint("Extracted UPI ID from URI: $upiId");
      } catch (e) {
        debugPrint("Error parsing UPI URI: $e");
      }
    } else if (qrData.contains('@')) {
      upiId = qrData;
      debugPrint("Using simple UPI ID: $upiId");
    } else {
      final match = RegExp(r'[\w.-]+@[\w.-]+').firstMatch(qrData);
      upiId = match?.group(0) ?? '';
      debugPrint("Extracted UPI ID from pattern: $upiId");
    }

    if (upiId.isNotEmpty) {
      setState(() => _upiIdController.text = upiId);
      _showSnack("UPI ID successfully extracted: $upiId", Colors.green);
      
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("UPI ID Extracted"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("The following UPI ID was extracted from the QR code:"),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  upiId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Is this correct?"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnack("Please try a different QR code", Colors.orange);
              },
              child: const Text("No, try again"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Yes, confirm"),
            ),
          ],
        ),
      );
    } else {
      _showSnack("QR code detected but no UPI ID found. Please try another QR code.", Colors.orange);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: color, 
        duration: const Duration(seconds: 3)
      ),
    );
  }

  Widget _buildSubmitButton() {
    bool isFormValid = _fullNameController.text.isNotEmpty && 
                      _upiIdController.text.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isFormValid ? () => _handleSubmit() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid
              ? const Color(0xFF2196F3)
              : Colors.grey.shade300,
          foregroundColor: isFormValid
              ? Colors.white
              : Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Submit',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  final UserService userService = UserService();

  void _handleSubmit() async{
    String fullName = _fullNameController.text.trim();
    String upiId = _upiIdController.text.trim();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    String? profilePicUrl;
    
    // Only upload if user selected an image
    if (_image != null) {
      profilePicUrl = await userService.uploadProfilePicture(_image!);
    } else {
      profilePicUrl = 'default';
    }

    // Always save user data regardless of profile picture status
    await userService.saveUserDetails(
      fullName: fullName,
      mobileNumber: '+91${widget.mobileNumber}',
      upi_id: upiId, // Using UPI ID instead of recovery email
      profilePicUrl: profilePicUrl ?? 'default',
    );

    Navigator.pop(context); // Close the loading dialog

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_image != null 
          ? 'Account created successfully with profile picture!' 
          : 'Account created successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    print('Account created successfully');
    // TODO: Navigate to home/dashboard screen
  }
}

