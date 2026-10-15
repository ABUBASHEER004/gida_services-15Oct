import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gida_services/services/notification_service.dart';
import 'package:image_picker/image_picker.dart';

import 'home_screen.dart';
import 'provider_dashboard.dart';
import 'provider_login.dart';
import 'admin_dashboard.dart';
import '../services/profile_image_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

Future<void> saveFCMToken(String uid) async {
  final token = await FirebaseMessaging.instance.getToken();

  if (token == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .set({
    'fcmToken': token,
  }, SetOptions(merge: true));
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  // Registration fields
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final locationController = TextEditingController();

  bool loading = false;
  bool isRegister = false;
  bool acceptedTerms = false;
  bool acceptedPrivacy = false;

  // =========================
  // PROFILE PICTURE
  // =========================
  XFile? selectedImage;

  // =========================
  // PICK PROFILE PICTURE
  // =========================
  Future<void> pickProfilePicture() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(context);

                  final image =
                      await ProfileImageService.pickFromCamera();

                  if (image != null && mounted) {
                    setState(() {
                      selectedImage = image;
                    });
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);

                  final image =
                      await ProfileImageService.pickFromGallery();

                  if (image != null && mounted) {
                    setState(() {
                      selectedImage = image;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // SET USER ONLINE
  // =========================
  Future<void> setOnline(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // =========================
  // TERMS & CONDITIONS
  // =========================
  void showTerms() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text('''
GIDA SERVICES — TERMS & CONDITIONS
Effective date: 13 October 2026

1. About the service
Gida Services helps customers discover local service providers, send service requests, and communicate about requested work. Listings and communication tools do not automatically guarantee a provider's identity, qualifications, availability, workmanship, or conduct.

2. Account information
Provide accurate information and keep your login credentials confidential. You are responsible for activity through your account. Tell us promptly if you suspect unauthorised access.

3. Requests and agreements
A service request is an enquiry, not a confirmed booking or a guarantee that a provider will accept the job. Agree on scope, timing, price, materials, and cancellation terms directly before work begins.

4. Providers and safety
Use reasonable care when selecting a provider. Never share passwords, bank PINs, card PINs, or one-time passwords. Report suspected fraud, harassment, unsafe conduct, or misleading listings through in-app support.

5. Payments and disputes
Unless a payment feature explicitly says otherwise, Gida Services does not hold funds or guarantee refunds. Confirm the recipient and terms before paying. Disputes may require direct resolution and, where appropriate, referral to relevant Nigerian authorities.

6. Acceptable use
Do not submit fake requests, impersonate others, harass users, upload unlawful or harmful content, bypass security, or use the service for fraud or other unlawful activity.

7. Messages, photos and content
You are responsible for content you submit and must have permission to share photos or personal information. Do not publish another person's private information without a lawful basis.

8. Restriction and termination
We may restrict or suspend access where reasonably necessary to investigate abuse, protect users, comply with law, or enforce these terms. You may stop using the service and request account assistance through support.

9. Availability and liability
We aim to keep the service available and secure but cannot promise uninterrupted operation or error-free user-submitted details. Nothing here excludes rights or obligations that cannot lawfully be excluded under Nigerian law.

10. Changes and contact
We may update these terms as the service evolves and communicate material changes through the app or another reasonable channel. Contact Gida Services through in-app support.

By creating an account, you confirm that you have read and agree to these Terms & Conditions and the Privacy Policy.
''', style: TextStyle(height: 1.45)),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
      ),
    );
  }

  void showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text('''
GIDA SERVICES — PRIVACY POLICY
Effective date: 13 October 2026

1. Who we are and scope
Gida Services is a product of NobleBridge Global, registered with the Corporate Affairs Commission (CAC), Nigeria, under registration number 9728771. This policy explains how Gida Services handles personal information when you register, browse providers, request services, chat, or use app features. We aim to handle personal data in accordance with applicable Nigerian law, including the Nigeria Data Protection Act 2023 (NDPA), and applicable guidance issued by the Nigeria Data Protection Commission (NDPC).

Privacy and enquiries contact
Email: gidaservicess@gmail.com
Please use the subject line “Gida Services Privacy Request” for requests to access, correct, or delete personal data, or to raise a privacy concern. Do not email passwords, PINs, or one-time passwords.

2. Information we may process
Depending on features used, this may include your name, email, phone number, address or service location, profile photo, account role, service requests, provider details, messages and media you send, support conversations, account status, device notification token, and basic technical/security records. Do not send passwords, bank PINs, card PINs, or one-time passwords in chats.

3. Purposes
We use information to create and secure accounts; connect customers and providers; manage requests; support chats and notifications; prevent fraud and abuse; respond to complaints; improve reliability; and meet legal obligations. We seek consent where consent is the appropriate lawful basis and explain optional permissions when requested.

4. Legal basis and choices
Information is processed where an applicable lawful basis permits it, such as providing a requested service, complying with law, pursuing legitimate interests that do not override your rights, or consent where required. Some features may not work without details needed to provide them.

5. Sharing
Relevant request details and contact information may be shared with the provider you select so they can respond. Information may also be processed by infrastructure providers supporting authentication, databases, file storage, notifications and app operations, or disclosed to regulators/law-enforcement where legally required. We do not intend to sell personal information. Sharing may occur for legitimate service, safety and legal purposes.

6. Location, photos and messages
Address/location details help providers understand where a service is needed. Camera, photo or location permissions may be requested by your device; you can deny optional permissions, though related features may be limited. Messages and media may be visible to conversation participants and authorised support/administrators when reasonably necessary for safety, moderation or support.

7. Security and storage
Information may be stored using Firebase or other infrastructure configured for the app. We use reasonable technical and organisational measures, but no internet transmission or storage system can be guaranteed completely secure. Access should be limited to authorised people with a legitimate need.

8. Retention
We retain information for as long as reasonably necessary to operate the service, maintain security and request records, resolve disputes, and meet legal requirements. Periods may vary by data type. When information is no longer needed, we will take reasonable steps to delete it or remove identifying details, subject to legal and operational requirements.

9. Cross-border processing
Some technology providers may process or store information outside Nigeria. Where this occurs, we will take steps required by applicable Nigerian data-protection law, including appropriate safeguards where required.

10. Your rights
Subject to applicable law and lawful exceptions, you may request access to personal data, correction, deletion, restriction or objection to certain processing, portability where applicable, or withdrawal of consent where processing relies on consent. You may complain to Gida Services and, where appropriate, the Nigeria Data Protection Commission (NDPC). We may need to verify your identity before responding.

11. Children
The service is not intended for children to create accounts independently. Contact support if you believe a child has submitted personal information without appropriate authorisation.

12. Third-party services
The app may rely on third-party services or contain links we do not control. Their own privacy terms may apply.

13. Updates, complaints and contact
We may update this policy when features, legal requirements or data practices change. The current version will be made available in the app. For privacy questions, access/correction/deletion requests, or complaints, email gidaservicess@gmail.com and include “Gida Services Privacy Request” in the subject. We may need to verify your identity before acting on a request. If you are not satisfied with our response, you may seek guidance from or lodge a complaint with the Nigeria Data Protection Commission (NDPC), subject to its procedures.

14. Compliance and review status
This policy is prepared with reference to the Nigeria Data Protection Act 2023 and is intended to explain Gida Services’ data-handling practices transparently. 
''', style: TextStyle(height: 1.45)),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
      ),
    );
  }

  // =========================
  // LOGIN
  // =========================
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter email and password")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      await setOnline(uid);
      await saveFCMToken(uid);

      // Start notification listeners after login
      NotificationService.listenForChats(uid);

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final data = doc.data() ?? {};

      final role = (data['role'] ?? 'user')
          .toString()
          .toLowerCase();

      final name = data['name'] ?? 'User';

      final status = (data['status'] ?? 'active')
          .toString()
          .toLowerCase();

      if (status == 'blocked') {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        setState(() => loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Access Denied: Account blocked by admin",
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      if (status == 'inactive') {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        setState(() => loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Account deactivated. Contact admin.",
            ),
            backgroundColor: Colors.orange,
          ),
        );

        return;
      }

      if (!mounted) return;

      if (role == 'provider') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => ProviderDashboard(
              providerId: uid,
              providerName: name,
            ),
          ),
          (route) => false,
        );
      } else if (role == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboard(),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: $e"),
        ),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }
  // =========================
  Future<void> adminLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter admin email & password")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;

      await setOnline(uid);
      await saveFCMToken(uid);

      NotificationService.listenForChats(uid);
      NotificationService.listenForRequestUpdates(uid);

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final role = (doc.data()?['role'] ?? '').toString().toLowerCase();

      if (role != 'admin') {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Not an admin account"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Admin login failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  // =========================
  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final location = locationController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty ||
        address.isEmpty ||
        location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    // ✅ TERMS REQUIRED
    if (!acceptedTerms || !acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the Terms & Conditions and Privacy Policy")),
      );
      return;
    }
    if (selectedImage == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Please select a profile picture"),
    ),
  );
  return;
}

    setState(() => loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;
      final profileImageUrl =
    await ProfileImageService.uploadProfileImage(
  uid: uid,
  image: selectedImage!,
);
      await saveFCMToken(uid);
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
  'profileImage': profileImageUrl,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'location': location,
        'profileImage': profileImageUrl,
        'role': 'user',
        'status': 'active',
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  // =========================
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    locationController.dispose();
    super.dispose();
  }

  // =========================
  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF087A45);
    const navy = Color(0xFF102A43);
    final registering = isRegister;

    return Scaffold(
      backgroundColor: navy,
      body: Stack(fit: StackFit.expand, children: [
        Positioned.fill(
          child: Image.asset('assets/logo.png', fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => const ColoredBox(color: navy)),
        ),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [navy.withOpacity(.76), navy.withOpacity(.72), const Color(0xFF071A2A).withOpacity(.98)],
            stops: const [0, .35, 1])))),
        SafeArea(child: Column(children: [
          Align(alignment: Alignment.centerLeft, child: IconButton(
            tooltip: 'Go back', onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white))),
          Expanded(child: Center(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 25, 22, 22),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.97),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(.7)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.25), blurRadius: 35, offset: const Offset(0, 16))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Center(child: Container(width: 62, height: 62,
                    decoration: BoxDecoration(color: const Color(0xFFE8F6EE), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.home_repair_service_rounded, color: green, size: 32))),
                  const SizedBox(height: 16),
                  Text(registering ? 'Create your account' : 'Welcome back', textAlign: TextAlign.center,
                    style: const TextStyle(color: navy, fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -.7)),
                  const SizedBox(height: 7),
                  Text(registering
                    ? 'Join Gida Services and connect with trusted local professionals.'
                    : 'Sign in to request services, chat, and manage your requests.',
                    textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF667085), height: 1.45)),
                  const SizedBox(height: 23),
                  if (registering) ...[
                    Center(child: GestureDetector(onTap: pickProfilePicture,
                      child: CircleAvatar(radius: 42, backgroundColor: const Color(0xFFE8F6EE),
                        child: selectedImage == null
                          ? const Icon(Icons.add_a_photo_outlined, color: green, size: 28)
                          : FutureBuilder<List<int>>(future: selectedImage!.readAsBytes(), builder: (context, snapshot) {
                              if (!snapshot.hasData) return const CircularProgressIndicator();
                              return ClipOval(child: Image.memory(Uint8List.fromList(snapshot.data!), width: 84, height: 84, fit: BoxFit.cover));
                            })))),
                    const SizedBox(height: 8),
                    const Text('Add a profile photo', textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF667085), fontSize: 12)),
                    const SizedBox(height: 14),
                    _field(nameController, 'Full name', Icons.person_outline_rounded),
                  ],
                  _field(emailController, 'Email address', Icons.mail_outline_rounded, keyboard: TextInputType.emailAddress),
                  _field(passwordController, 'Password', Icons.lock_outline_rounded, obscure: true),
                  if (registering) ...[
                    _field(phoneController, 'Phone number', Icons.phone_outlined, keyboard: TextInputType.phone),
                    _field(addressController, 'Address', Icons.location_on_outlined),
                    _field(locationController, 'Area / city', Icons.place_outlined),
                    CheckboxListTile(value: acceptedTerms && acceptedPrivacy,
                      onChanged: (value) => setState(() { acceptedTerms = value ?? false; acceptedPrivacy = value ?? false; }),
                      contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading,
                      activeColor: green, title: const Text('I agree to the documents below.', style: TextStyle(fontSize: 13, color: navy))),
                    Padding(padding: const EdgeInsets.only(left: 8, bottom: 8),
                      child: Wrap(spacing: 4, runSpacing: 0, children: [
                        TextButton(onPressed: showTerms, child: const Text('Terms & Conditions', style: TextStyle(decoration: TextDecoration.underline))),
                        const Text('•', style: TextStyle(color: Color(0xFF98A2B3))),
                        TextButton(onPressed: showPrivacyPolicy, child: const Text('Privacy Policy', style: TextStyle(decoration: TextDecoration.underline))),
                      ])),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(height: 53, child: FilledButton(
                    onPressed: loading ? null : (registering ? register : login),
                    style: FilledButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(registering ? 'Create account' : 'Sign in', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
                  const SizedBox(height: 8),
                  if (!registering) OutlinedButton.icon(
                    onPressed: loading ? null : adminLogin, icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('Admin sign in'),
                    style: OutlinedButton.styleFrom(foregroundColor: navy, minimumSize: const Size.fromHeight(47),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
                  TextButton(onPressed: loading ? null : () => setState(() {
                    isRegister = !isRegister; acceptedTerms = false; acceptedPrivacy = false;
                  }), child: Text(registering ? 'Already have an account? Sign in' : 'New to Gida Services? Create account',
                    style: const TextStyle(color: green, fontWeight: FontWeight.w800))),
                  OutlinedButton.icon(onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProviderLogin())),
                    icon: const Icon(Icons.storefront_outlined), label: const Text('Continue as a service provider'),
                    style: OutlinedButton.styleFrom(foregroundColor: navy, minimumSize: const Size.fromHeight(47),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
                  const SizedBox(height: 12),
                  const Text('Your local services, made simpler.', textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF98A2B3), fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ))),
        ])),
      ]),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboard, bool obscure = false}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12),
      child: TextField(controller: controller, keyboardType: keyboard, obscureText: obscure,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: const Color(0xFF087A45)),
          filled: true, fillColor: const Color(0xFFF7F9F8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE3E8E5))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE3E8E5))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF087A45), width: 1.5)))));
  }
}
