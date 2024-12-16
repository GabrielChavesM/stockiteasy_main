import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Define the RegisterPage widget
class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage; // Alternate to login page
  const RegisterPage({
    super.key, // Unique widget identifier from the three
    required this.showLoginPage, // Callback to go to login page
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState(); // Create the state and update the register page
}

class _RegisterPageState extends State<RegisterPage> {
  // Text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variables to toggle password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Track if the user has accepted the policy
  bool _hasAcceptedPolicy = false;

  @override
  void initState() {
    super.initState();
    // Show the privacy policy dialog when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPrivacyPolicyDialog();
    });
  }

  // Liberate the data from memory, avoiding data leaks
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog by tapping outside
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
              onPressed: () {
                Navigator.of(context).pop(); // Closes the pop up window
                widget.showLoginPage(); // Redirects to the login page
              },
              child: Text('I do not agree.'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _hasAcceptedPolicy = true;
                });
                Navigator.of(context).pop(); // Closes the pop up window
              },
              child: Text('I read it and agree.'),
            ),
          ],
        );
      },
    );
  }

  bool isPasswordValid(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'\d').hasMatch(password)) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;
    return true;
  }
  
  // Register a new user on the database
  Future<void> signUp() async {
    if (!_hasAcceptedPolicy) {
      // Display message if user has not yet accepted the privacy policy
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please accept the Privacy Policy to continue.')),
      );
      return;
    }

    if (passwordConfirmed()) {
      if (!isPasswordValid(_passwordController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password must be at least 8 characters long, include at least one uppercase letter, one number, and one special character.')),
        );
        return;
      }

      try {
        // Put the new user in the database
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Verify if the user already verified the email, if verified it can login
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification email sent! Please check your email before logging in.')),
          );
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        // Catches and show specific errors to the user
        String errorMessage = 'An error occurred. Please check your connection and try again.';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'This email is already in use. Please use another email.';
              break;
            case 'invalid-email':
              errorMessage = 'The email address is not valid. Please enter a valid email.';
              break;
            case 'weak-password':
              errorMessage = 'The password is too weak. Please use a stronger password.';
              break;
            case 'operation-not-allowed':
              errorMessage = 'Signing up with email and password is disabled. Please contact support.';
              break;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The passwords do not match.')),
      );
    }
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() == _confirmPasswordController.text.trim();
  }

  hexStringToColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // Build the app visual
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/icon.png', width: 100, height: 100, fit: BoxFit.cover),
                  SizedBox(height: 75),
                  Text('New on the app?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36)),
                  SizedBox(height: 10),
                  Text('Register below!', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextField(controller: _emailController, decoration: InputDecoration(border: InputBorder.none, hintText: 'Email')),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Confirm Password',
                            suffixIcon: IconButton(
                              icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      'Password must contain at least: 8 characters, 1 uppercase letter, 1 number, and 1 special character (!@#\$%^&*).',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: signUp,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('I am a member!', style: TextStyle(fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: widget.showLoginPage,
                        child: Text(
                          ' Sign In now!',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}