import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stockiteasy/pages/home_options/activity_page.dart';
import 'package:stockiteasy/pages/login_page.dart';

class AccountSettingsPage extends StatefulWidget {
  final Function(String) onNameChanged;

  const AccountSettingsPage({super.key, required this.onNameChanged});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final user = FirebaseAuth.instance.currentUser;
  String _name = "";
  String _storeNumber = "";
  final String _email = FirebaseAuth.instance.currentUser?.email ?? "";
  final _nameController = TextEditingController();
  final _storeNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _storeNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _name = userDoc['name'] ?? "";
          _storeNumber = userDoc['storeNumber'] ?? "";
          _nameController.text = _name;
          _storeNumberController.text = _storeNumber;
        });
      }
    }
  }

  Future<void> _saveUserData(String name, String storeNumber) async {
    if (user != null) {
      String userId = user!.uid;

      // Salva o nome e o storeNumber no documento do usuário
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(
        {
          'name': name,
          'storeNumber': storeNumber, // Atualiza o storeNumber
          'userId': userId,
          'userEmail': _email,
        },
        SetOptions(merge: true), // Preserva outros dados existentes
      );

      widget.onNameChanged(name); // Atualiza o nome na UI
    }
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showAlert('Password reset link sent to $email! Check your email.');
    } on FirebaseAuthException catch (e) {
      _showAlert(e.message.toString());
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
        backgroundColor: Color.fromRGBO(185, 30, 145, 800),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4"),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // User Profile
            _buildOptionButton(
              icon: Icons.person,
              title: 'User Profile',
              subtitle: 'Name: ${_name.isNotEmpty ? _name : "Not set"}\nEmail: $_email\nStore Number: ${_storeNumber.isNotEmpty ? _storeNumber : "Not set"}',
              onTap: () {
                _setUserDataDialog(context);
              },
            ),
            // Change Password
            _buildOptionButton(
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () {
                _confirmPasswordReset(context);
              },
            ),
            // Activity History
            _buildOptionButton(
              icon: Icons.history,
              title: 'Activity History',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LoginLogoutHistoryPage()),
                );
              },
            ),
            // Feedback and Support
            _buildOptionButton(
              icon: Icons.feedback,
              title: 'Feedback and Support',
              onTap: () {
                _showFeedbackDialog(context);
              },
            ),
            // Privacy Policy
            _buildOptionButton(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {
                _showPrivacyPolicyDialog(context);
              },
            ),
            // Remove Account
            _buildOptionButton(
              icon: Icons.delete,
              title: 'Remove Account',
              onTap: () {
                _confirmAccountDeletion(context);
              },
            ),
            // Sign Out
            _buildOptionButton(
              icon: Icons.logout,
              title: 'Sign Out',
              onTap: () {
                _confirmLogout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle,
                              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setUserDataDialog(BuildContext context) {
    _nameController.text = _name;
    _storeNumberController.text = _storeNumber;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Your Name and Store Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo de texto para nome
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Enter your name'),
              ),
              // Campo de texto para storeNumber
              TextField(
                controller: _storeNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Enter your store number'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // Verifica se pelo menos um dos campos foi alterado
                if ((_nameController.text.isNotEmpty && _nameController.text != _name) ||
                    (_storeNumberController.text.isNotEmpty && _storeNumberController.text != _storeNumber)) {
                  _saveUserData(
                    _nameController.text.isNotEmpty ? _nameController.text : _name,
                    _storeNumberController.text.isNotEmpty ? _storeNumberController.text : _storeNumber,
                  );
                  setState(() {
                    _name = _nameController.text.isNotEmpty ? _nameController.text : _name;
                    _storeNumber = _storeNumberController.text.isNotEmpty ? _storeNumberController.text : _storeNumber;
                  });
                  Navigator.of(context).pop(); // Fecha a tela
                } else {
                  // Exibe o pop-up se ambos os campos forem iguais aos anteriores ou vazios
                  _showAlert('Please fill in at least one field with a new value.');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmPasswordReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Password Reset'),
          content: Text(
            'Are you sure you want to send a password reset link to $_email?',
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Send Reset Email',
              style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                _sendPasswordResetEmail(_email);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Privacy Policy'),
          content: SingleChildScrollView(
            child: Text(
              'Privacy Policy\n'
              'Last updated: November 4, 2024\n\n'
              'This Privacy Policy describes Our policies and procedures on the collection, use, and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.\n'
              'We use Your Personal data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy.\n\n'
              'Additional Privacy Compliance and Regulations\n'
              'Our Privacy Policy also covers the following compliance regulations and considerations:\n\n'
              'Google Analytics and Tracking\n'
              'Yes, we use Google Analytics and other related tools to monitor and analyze our website traffic, understand user behavior, and improve our services.\n\n'
              'Email Communications\n'
              'Yes, we may send emails to users, and users can opt in to receive emails from us for updates, special offers, and other service-related information.\n\n'
              'CCPA + CPRA Compliance\n'
              'This Privacy Policy has been updated to include requirements from the California Consumer Privacy Act (CCPA), amended by the California Privacy Rights Act (CPRA), which apply to websites, apps, and businesses with users from California, USA. We comply with user rights for California residents, including access, deletion, and opting out of data sales.\n\n'
              'GDPR Compliance\n'
              'We comply with the General Data Protection Regulation (GDPR) for users from the European Union (EU) and European Economic Area (EEA). Our users have rights including access, correction, deletion, and data portability.\n\n'
              'CalOPPA Compliance\n'
              'We comply with the California Online Privacy Protection Act (CalOPPA), which applies to websites, apps, and businesses in the US or with users from California, USA. This policy includes disclosure about the types of personal information collected and how it is used, as required under CalOPPA.\n\n'
              'COPPA Compliance\n'
              'We comply with the Children’s Online Privacy Protection Act (COPPA) in the United States. Our services are not directed to children under the age of 13, and we do not knowingly collect personal information from them. If we become aware of any data collected from children, we take steps to delete it.\n\n'
              'Interpretation and Definitions\n'
              'Interpretation\n'
              'The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.\n\n'
              'Definitions\n'
              'For the purposes of this Privacy Policy:\n'
              '• Account means a unique account created for You to access our Service or parts of our Service.\n'
              '• Affiliate means an entity that controls, is controlled by or is under common control with a party, where "control" means ownership of 50% or more of the shares, equity interest, or other securities entitled to vote for election of directors or other managing authority.\n'
              '• Application refers to StockItEasy, the software program provided by the Company.\n'
              '• Company (referred to as either "the Company", "We", "Us" or "Our" in this Agreement) refers to StockItEasy.\n'
              '• Country refers to: Portugal\n'
              '• Device means any device that can access the Service such as a computer, a cellphone, or a digital tablet.\n'
              '• Personal Data is any information that relates to an identified or identifiable individual.\n'
              '• Service refers to the Application.\n'
              '• Service Provider means any natural or legal person who processes the data on behalf of the Company. It refers to third-party companies or individuals employed by the Company to facilitate the Service, to provide the Service on behalf of the Company, to perform services related to the Service, or to assist the Company in analyzing how the Service is used.\n'
              '• Usage Data refers to data collected automatically, either generated by the use of the Service or from the Service infrastructure itself (for example, the duration of a page visit).\n'
              '• You means the individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.\n\n'
              'Collecting and Using Your Personal Data\n'
              'Types of Data Collected\n'
              'Personal Data\n'
              'While using Our Service, We may ask You to provide Us with certain personally identifiable information that can be used to contact or identify You. Personally identifiable information may include, but is not limited to:\n'
              '• Email address\n'
              '• First name and last name\n'
              '• Address, State, Province, ZIP/Postal code, City\n'
              '• Usage Data\n\n'
              'Usage Data\n'
              'Usage Data is collected automatically when using the Service. Usage Data may include information such as Your Device\'s Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that You visit, the time and date of Your visit, the time spent on those pages, unique device identifiers and other diagnostic data.\n\n'
              'Information Collected while Using the Application\n'
              'While using Our Application, in order to provide features of Our Application, We may collect, with Your prior permission:\n'
              '• Pictures and other information from your Device\'s camera and photo library.\n'
              'We use this information to provide features of Our Service, to improve and customize Our Service. The information may be uploaded to the Company\'s servers and/or a Service Provider\'s server or it may be simply stored on Your device.\n'
              'You can enable or disable access to this information at any time, through Your Device settings.\n\n'
              'Use of Your Personal Data\n'
              'The Company may use Personal Data for the following purposes:\n'
              '• To provide and maintain our Service, including to monitor the usage of our Service.\n'
              '• To manage Your Account: to manage Your registration as a user of the Service. The Personal Data You provide can give You access to different functionalities of the Service that are available to You as a registered user.\n'
              '• For the performance of a contract: the development, compliance, and undertaking of the purchase contract for the products, items, or services You have purchased or of any other contract with Us through the Service.\n'
              '• To contact You: To contact You by email, telephone calls, SMS, or other equivalent forms of electronic communication, such as a mobile application\'s push notifications regarding updates or informative communications related to the functionalities, products, or contracted services, including security updates.\n'
              '• To provide You with news, special offers, and general information about other goods, services, and events which we offer that are similar to those that you have already purchased or enquired about unless You have opted not to receive such information.\n'
              '• To manage Your requests: To attend and manage Your requests to Us.\n'
              '• For business transfers: We may use Your information to evaluate or conduct a merger, divestiture, restructuring, reorganization, dissolution, or other sale or transfer of some or all of Our assets, where Personal Data held by Us about our Service users is among the assets transferred.\n'
              '• For other purposes: We may use Your information for other purposes, such as data analysis, identifying usage trends, determining the effectiveness of our promotional campaigns, and evaluating and improving our Service, products, services, marketing, and user experience.\n\n'
              'Retention of Your Personal Data\n'
              'The Company will retain Your Personal Data only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use Your Personal Data to comply with our legal obligations, resolve disputes, and enforce our agreements and policies.\n\n'
              'Transfer of Your Personal Data\n'
              'Your information, including Personal Data, may be transferred to and maintained on computers located outside of Your jurisdiction where data protection laws may differ. Your consent to this Privacy Policy followed by Your submission of such information represents Your agreement to that transfer.\n\n'
              'Delete Your Personal Data\n'
              'You have the right to delete or request deletion of Your Personal Data collected by Us. You can delete or update information through your Account settings or by contacting Us.\n\n'
              'Disclosure of Your Personal Data\n'
              'Business Transactions\n'
              'If the Company is involved in a merger, acquisition, or asset sale, Your Personal Data may be transferred.\n\n'
              'Law Enforcement\n'
              'We may disclose Your Personal Data if required by law or in response to valid requests by public authorities.\n\n'
              'Security of Your Personal Data\n'
              'We use commercially acceptable means to protect Your Personal Data, but no method is 100% secure.\n\n'
              'Children\'s Privacy\n'
              'Our Service does not address anyone under the age of 13, and we do not knowingly collect personal identifiable information from them.\n\n'
              'Changes to This Privacy Policy\n'
              'We may update Our Privacy Policy from time to time. You are advised to review this Privacy Policy periodically.\n\n'
              'Contact Us\n'
              'If you have any questions about this Privacy Policy, You can contact us at helpstockiteasy@gmail.com\n'
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Support Email'),
          content: Text('For assistance, please contact: helpstockiteasy@gmail.com'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

void _confirmAccountDeletion(BuildContext context) {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      bool isGoogleSignIn = user!.providerData.any((provider) => provider.providerId == "google.com");

      return AlertDialog(
        title: Text('Account Deletion Confirmation'),
        content: isGoogleSignIn
            ? Text('Since you are logged in with Google, simply confirm your account to delete it.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Are you sure you want to remove your account? This action cannot be undone.'),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Re-enter your email'),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Enter your password'),
                  ),
                ],
              ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Remove Account', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              if (isGoogleSignIn) {
                try {
                  // If the user is signed in with Google, reauthenticate using Google
                  GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                  if (googleUser != null) {
                    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
                    AuthCredential credential = GoogleAuthProvider.credential(
                      accessToken: googleAuth.accessToken,
                      idToken: googleAuth.idToken,
                    );

                    await user!.reauthenticateWithCredential(credential);
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .delete();
                    await user!.delete();

                    // Navigate to the login page after account deletion
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage(showRegisterPage: () {  },)), // Replace with your actual LoginPage widget
                    );

                    _showAlert('Account successfully deleted.');
                  }
                } catch (e) {
                  _showAlert('An error occurred while reauthenticating with Google. Please try again.');
                }
              } else {
                // For email/password authentication, validate inputs
                if (emailController.text != _email) {
                  _showAlert('Email does not match. Please try again.');
                } else if (passwordController.text.isEmpty) {
                  _showAlert('Password field cannot be empty.');
                } else {
                  try {
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: user!.email!,
                      password: passwordController.text,
                    );

                    await user!.reauthenticateWithCredential(credential);
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .delete();
                    await user!.delete();

                    // Navigate to the login page after account deletion
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage(showRegisterPage: () {  },)), // Replace with your actual LoginPage widget
                    );

                    _showAlert('Account successfully deleted.');
                  } on FirebaseAuthException catch (e) {
                    _showAlert(e.message ?? 'Password is incorrect.');
                  }
                }
              }
            },
          ),
        ],
      );
    },
  );
}

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logout Confirmation'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Sign Out',
              style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(showRegisterPage: () {  },),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}