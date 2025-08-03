import 'package:expenser/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class UserDetailsPage extends StatefulWidget {
  final String mobileNumber;

  const UserDetailsPage({super.key, required this.mobileNumber});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _recoveryMailController = TextEditingController();
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _recoveryMailFocusNode = FocusNode();

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
    _recoveryMailController.dispose();
    _fullNameFocusNode.dispose();
    _recoveryMailFocusNode.dispose();
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
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
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
    return Center(
      child: Container(
        width: 200,
        height: 200,
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
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/image 4.png',
            fit: BoxFit.cover,
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildHeaderSection(),
          const SizedBox(height: 30),
          _buildProfilePictureSection(),
          const SizedBox(height: 30),
          _buildFormFields(),
          const SizedBox(height: 40),
          _buildSubmitButton(),
          const SizedBox(height: 20),
        ],
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
        _buildFloatingLabelInputField(
          controller: _recoveryMailController,
          focusNode: _recoveryMailFocusNode,
          label: 'Recovery Mail',
          hintText: 'Enter your email address',
          keyboardType: TextInputType.emailAddress,
        ),
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
    return Container(
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
    return Container(
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


  Widget _buildSubmitButton() {
    bool isFormValid = _fullNameController.text.isNotEmpty && 
                      _recoveryMailController.text.isNotEmpty;

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

  void _handleSubmit() {
    // TODO: Implement account creation logic with database
    String fullName = _fullNameController.text.trim();
    String recoveryMail = _recoveryMailController.text.trim();
    
    print('Creating account for: $fullName');
    print('Mobile: ${widget.mobileNumber}');
    print('Email: $recoveryMail');

    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // TODO: Navigate to dashboard or home page after successful account creation
  }
} 