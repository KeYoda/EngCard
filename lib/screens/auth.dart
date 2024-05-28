// import 'dart:io';

// import 'package:eng_card/widgets/user_image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_fonts/google_fonts.dart';

// final _firebase = FirebaseAuth.instance;

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});
//   @override
//   State<AuthScreen> createState() {
//     return _AuthScreenState();
//   }
// }

// class _AuthScreenState extends State<AuthScreen> {
//   final _form = GlobalKey<FormState>();

//   var _isLogin = true;
//   var _enteredEmail = '';
//   var _enteredPassword = '';
//   File? _selectedImage;
//   var _isAuthenticating = false;

//   void _submit() async {
//     final isValid = _form.currentState!.validate();

//     if (!isValid || !_isLogin && _selectedImage == null) {
//       return;
//     }

//     _form.currentState!.save();

//     try {
//       setState(() {
//         _isAuthenticating = true;
//       });
//       if (_isLogin) {
//         final userCredentials = await _firebase.signInWithEmailAndPassword(
//             email: _enteredEmail, password: _enteredPassword);
//       } else {
//         final userCredentials = await _firebase.createUserWithEmailAndPassword(
//             email: _enteredEmail, password: _enteredPassword);

//         final storageRef = FirebaseStorage.instance
//             .ref()
//             .child('user_images')
//             .child('${userCredentials.user!.uid}.jpg');
//         await storageRef.putFile(_selectedImage!);
//         final imageUrl = await storageRef.getDownloadURL();
//         print(imageUrl);
//       }
//     } on FirebaseAuthException catch (error) {
//       if (error.code == 'email-already-in-use') {
//         //
//       }

//       setState(() {
//         ScaffoldMessenger.of(context).clearSnackBars();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(error.message ?? 'Authentication failed.'),
//           ),
//         );
//         _isAuthenticating = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 53, 104, 89),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Container(
//                 margin: EdgeInsets.only(
//                   top: screenHeight * 0.05,
//                   bottom: screenHeight * 0.033,
//                   left: screenWidth * 0.04,
//                   right: screenWidth * 0.04,
//                 ),
//                 width: screenWidth * 0.4,
//                 child: Image.asset(
//                   'assets/keyoda.png',
//                   color: const Color.fromARGB(255, 255, 251, 230),
//                 ),
//               ),
//               SizedBox(
//                 height: screenHeight * 0.75,
//                 width: screenWidth * 1.0,
//                 child: Card(
//                   color: const Color.fromARGB(255, 255, 251, 230),
//                   margin: const EdgeInsets.all(20),
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Form(
//                         key: _form,
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             if (!_isLogin)
//                               UserImagePicker(
//                                 onPickImage: (pickedImage) {
//                                   _selectedImage = pickedImage;
//                                 },
//                               ),
//                             TextFormField(
//                               cursorColor: Colors.orange,
//                               decoration: InputDecoration(
//                                 focusedBorder: const OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(30)),
//                                     borderSide:
//                                         BorderSide(color: Colors.orange)),
//                                 border: const OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.white),
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(30)),
//                                 ),
//                                 labelStyle: GoogleFonts.inconsolata(
//                                     color:
//                                         const Color.fromARGB(255, 253, 85, 35)),
//                                 labelText: '   Email Address',
//                               ),
//                               keyboardType: TextInputType.emailAddress,
//                               autocorrect: false,
//                               textCapitalization: TextCapitalization.none,
//                               validator: (value) {
//                                 if (value == null ||
//                                     value.trim().isEmpty ||
//                                     !value.contains('@')) {
//                                   return 'Please enter a valid email address.';
//                                 }
//                                 return null;
//                               },
//                               onSaved: (newValue) {
//                                 _enteredEmail = newValue!;
//                               },
//                             ),
//                             const SizedBox(height: 15),
//                             TextFormField(
//                               decoration: InputDecoration(
//                                 focusedBorder: const OutlineInputBorder(
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(30)),
//                                     borderSide:
//                                         BorderSide(color: Colors.orange)),
//                                 border: const OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.white),
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(30)),
//                                 ),
//                                 labelStyle: GoogleFonts.inconsolata(
//                                     color:
//                                         const Color.fromARGB(255, 253, 85, 35)),
//                                 labelText: '   Password',
//                               ),
//                               obscureText: true,
//                               validator: (value) {
//                                 if (value == null || value.trim().length < 6) {
//                                   return 'Password must be at least 6 characters long.';
//                                 }
//                                 return null;
//                               },
//                               onSaved: (newValue) {
//                                 _enteredPassword = newValue!;
//                               },
//                             ),
//                             const SizedBox(height: 260),
//                             if (_isAuthenticating)
//                               const CircularProgressIndicator(),
//                             if (!_isAuthenticating)
//                               ElevatedButton(
//                                 onPressed: _submit,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor:
//                                       const Color.fromARGB(255, 253, 85, 35),
//                                 ),
//                                 child: Text(
//                                   _isLogin ? 'Login' : 'Sİgnup',
//                                   style: const TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             if (!_isAuthenticating)
//                               TextButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     _isLogin = !_isLogin;
//                                   });
//                                 },
//                                 child: Text(
//                                   _isLogin
//                                       ? 'Create an account'
//                                       : 'I already have an account',
//                                   style: const TextStyle(
//                                       color: Color.fromARGB(255, 253, 85, 35)),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
