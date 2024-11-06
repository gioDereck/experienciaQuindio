import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_hour/config/config.dart';
import 'package:http/http.dart' as http;
// import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class SignInBloc extends ChangeNotifier {
  SignInBloc() {
    checkSignIn();
    checkGuestUser();
    initPackageInfo();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googlSignIn = new GoogleSignIn();
  // final FacebookAuth _fbAuth = FacebookAuth.instance;
  final String defaultUserImageUrl =
      'https://www.seekpng.com/png/detail/115-1150053_avatar-png-transparent-png-royalty-free-default-user.png';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool _guestUser = false;
  bool get guestUser => _guestUser;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _name;
  String? get name => _name;

  String? _uid;
  String? get uid => _uid;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  String? _joiningDate;
  String? get joiningDate => _joiningDate;

  String? _signInProvider;
  String? get signInProvider => _signInProvider;

  String? timestamp;

  String _appVersion = '0.0';
  String get appVersion => _appVersion;

  String _packageName = '';
  String get packageName => _packageName;

  // Nuevos campos del usuario
  String? _phone = '';
  String? get phone => _phone;

  String? _department = '';
  String? get department => _department;

  String? _city = '';
  String? get city => _city;

  String? _address = '';
  String? get address => _address;

  String? _eps = '';
  String? get eps => _eps;

  String? _age = '';
  String? get age => _age;

  String? _gender = '';
  String? get gender => _gender;

  String? _occupation = '';
  String? get occupation => _occupation;

  String? _password = '';
  String? get password => _password;

  void initPackageInfo() async {
    if (!kIsWeb) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      _packageName = packageInfo.packageName;
    }
    notifyListeners();
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googlSignIn.signIn();
    if (googleUser != null) {
      try {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        User userDetails =
            (await _firebaseAuth.signInWithCredential(credential)).user!;

        this._name = userDetails.displayName;
        this._email = userDetails.email;
        this._imageUrl = userDetails.photoURL;
        this._uid = userDetails.uid;
        this._signInProvider = 'google';

        _hasError = false;
        notifyListeners();

        // Llamar al nuevo método para enviar el correo al endpoint
        if (_email != null) {
          //print("Url de la imagen $_imageUrl");
          await registerToEndpoint(_name!, _email!, _imageUrl!);
        }
      } catch (e) {
        _hasError = true;
        _errorCode = e.toString();
        notifyListeners();
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  Future signInwithFacebook() async {
    // User currentUser;
    // final LoginResult facebookLoginResult = await FacebookAuth.instance
    //     .login(permissions: ['email', 'public_profile']);
    // debugPrint('fb login result: ${facebookLoginResult.message}');
    // if (facebookLoginResult.status == LoginStatus.success) {
    //   final _accessToken = await FacebookAuth.instance.accessToken;
    //   debugPrint('access token: $_accessToken');
    //   if (_accessToken != null) {
    //     try {
    //       final AuthCredential credential =
    //           FacebookAuthProvider.credential(_accessToken.tokenString);
    //       final User user =
    //           (await _firebaseAuth.signInWithCredential(credential)).user!;
    //       // assert(user.email != null);
    //       // assert(user.displayName != null);
    //       // assert(!user.isAnonymous);
    //       await user.getIdToken();
    //       currentUser = _firebaseAuth.currentUser!;
    //       assert(user.uid == currentUser.uid);

    //       this._name = user.displayName;
    //       this._email = user.email;
    //       this._imageUrl = user.photoURL;
    //       this._uid = user.uid;
    //       this._signInProvider = 'facebook';

    //       _hasError = false;
    //       notifyListeners();
    //     } catch (e) {
    //       _hasError = true;
    //       _errorCode = e.toString();
    //       notifyListeners();
    //     }
    //   }
    // } else {
    //   _hasError = true;
    //   _errorCode = 'cancel or error';
    //   notifyListeners();
    // }
  }

  Future signInWithApple() async {
    // final _firebaseAuth = FirebaseAuth.instance;
    // final result = await TheAppleSignIn.performRequests([
    //   AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    // ]);

    // if (result.status == AuthorizationStatus.authorized) {
    //   try {
    //     final appleIdCredential = result.credential!;
    //     final oAuthProvider = OAuthProvider('apple.com');
    //     final credential = oAuthProvider.credential(
    //       idToken: String.fromCharCodes(appleIdCredential.identityToken!),
    //       accessToken:
    //           String.fromCharCodes(appleIdCredential.authorizationCode!),
    //     );
    //     final authResult = await _firebaseAuth.signInWithCredential(credential);
    //     final firebaseUser = authResult.user!;

    //     this._uid = firebaseUser.uid;
    //     this._name =
    //         '${appleIdCredential.fullName!.givenName} ${appleIdCredential.fullName!.familyName}';
    //     this._email = appleIdCredential.email;
    //     this._imageUrl = firebaseUser.photoURL ?? defaultUserImageUrl;
    //     this._signInProvider = 'apple';

    //     debugPrint(firebaseUser.toString());
    //     _hasError = false;
    //     notifyListeners();
    //   } catch (e) {
    //     _hasError = true;
    //     _errorCode = e.toString();
    //     notifyListeners();
    //   }
    // } else if (result.status == AuthorizationStatus.error) {
    //   _hasError = true;
    //   _errorCode = 'Appple Sign In Error! Please try again';
    //   notifyListeners();
    // } else if (result.status == AuthorizationStatus.cancelled) {
    //   _hasError = true;
    //   _errorCode = 'Sign In Cancelled!';
    //   notifyListeners();
    // }
  }

  Future<bool> checkUserExists() async {
    DocumentSnapshot snap = await firestore.collection('users').doc(_uid).get();
    if (snap.exists) {
      debugPrint('User Exists');
      return true;
    } else {
      debugPrint('new user');
      return false;
    }
  }

  Future saveToFirebase() async {
    final DocumentReference ref =
        FirebaseFirestore.instance.collection('users').doc(_uid);
    var userData = {
      'name': _name,
      'email': _email,
      'uid': _uid,
      'image url': _imageUrl,
      'joining date': _joiningDate,
      'loved blogs': [],
      'loved places': [],
      'bookmarked blogs': [],
      'bookmarked places': []
    };
    await ref.set(userData);
  }

  Future getJoiningDate() async {
    DateTime now = DateTime.now();
    String _date = DateFormat('dd-MM-yyyy').format(now);
    _joiningDate = _date;
    notifyListeners();
  }

  Future saveDataToSP() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    await sp.setString('name', _name!);
    await sp.setString('email', _email!);
    await sp.setString('image_url', _imageUrl!);
    await sp.setString('uid', _uid!);
    await sp.setString('joining_date', _joiningDate!);
    await sp.setString('sign_in_provider', _signInProvider!);
  }

  Future getDataFromSp() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _name = sp.getString('name');
    _email = sp.getString('email');
    _imageUrl = sp.getString('image_url');
    _uid = sp.getString('uid');
    _joiningDate = sp.getString('joining_date');
    _signInProvider = sp.getString('sign_in_provider');
    // Nuevos campos usuario
    _phone = sp.getString('phone');
    _department = sp.getString('department');
    _city = sp.getString('city');
    _address = sp.getString('address');
    _eps = sp.getString('eps');
    _age = sp.getString('age');
    _gender = sp.getString('gender');
    _occupation = sp.getString('occupation');
    _password = sp.getString('password');
    notifyListeners();
  }

  Future getUserDatafromFirebase(uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snap) {
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;

        // Campos existentes
        this._uid = data['uid'] ?? '';
        this._name = data['name'] ?? '';
        this._email = data['email'] ?? '';
        this._imageUrl = data['image url'] ?? '';
        this._joiningDate = data['joining date'] ?? '';

        // Nuevos Campos - Verificación de existencia
        this._phone = data.containsKey('phone') ? data['phone'] : null;
        this._department =
            data.containsKey('department') ? data['department'] : null;
        this._city = data.containsKey('city') ? data['city'] : null;
        this._address = data.containsKey('address') ? data['address'] : null;
        this._eps = data.containsKey('eps') ? data['eps'] : null;
        this._age = data.containsKey('age') ? data['age'] : null;
        this._gender = data.containsKey('gender') ? data['gender'] : null;
        this._occupation =
            data.containsKey('occupation') ? data['occupation'] : null;
        this._password = data.containsKey('password') ? data['password'] : null;

        // debugPrint(_name);
      } else {
        // El documento no existe
        //print('El documento no existe para el UID: $uid');
      }
    }).catchError((e) {
      //print('Error al obtener datos del usuario: $e');
    });

    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('signed_in', true);
    _isSignedIn = true;
    notifyListeners();
  }

  void checkSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool('signed_in') ?? false;
    notifyListeners();
  }

  Future userSignout() async {
    if (_signInProvider == 'apple') {
      await _firebaseAuth.signOut();
    }
    // else if (_signInProvider == 'facebook') {
    //   await _firebaseAuth.signOut().then((_) async => await _fbAuth.logOut());
    // }
    else {
      await _firebaseAuth.signOut().then((_) async => _googlSignIn.signOut());
    }
  }

  Future afterUserSignOut() async {
    await clearAllData();
    _isSignedIn = false;
    _guestUser = false;
    _uid = null;
    notifyListeners();
  }

  Future setGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest_user', true);
    _guestUser = true;
    notifyListeners();
  }

  void checkGuestUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _guestUser = sp.getBool('guest_user') ?? false;
    notifyListeners();
  }

  Future clearAllData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }

  Future guestSignout() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool('guest_user', false);
    _guestUser = false;
    notifyListeners();
  }

  Future updateUserProfile(
      String newName,
      String newImageUrl,
      String phone,
      String department,
      String city,
      String address,
      String eps,
      String age,
      String gender,
      String occupation,
      String password) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    FirebaseFirestore.instance.collection('users').doc(_uid).update({
      'name': newName,
      'image url': newImageUrl,
      'phone': phone,
      'department': department,
      'city': city,
      'address': address,
      'eps': eps,
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'password': password
    });

    sp.setString('name', newName);
    sp.setString('image_url', newImageUrl);
    // Nuevos campos del ususario
    sp.setString('phone', phone);
    sp.setString('department', department);
    sp.setString('city', city);
    sp.setString('address', address);
    sp.setString('eps', eps);
    sp.setString('age', age);
    sp.setString('gender', gender);
    sp.setString('occupation', occupation);
    sp.setString('password', password);

    _name = newName;
    _imageUrl = newImageUrl;
    // Nuevos Campos del usuario
    _phone = phone;
    _department = department;
    _city = city;
    _address = address;
    _eps = eps;
    _age = age;
    _gender = gender;
    _occupation = occupation;
    _password = password;

    notifyListeners();
  }

  Future<int> getTotalUsersCount() async {
    final String fieldName = 'count';
    final DocumentReference ref =
        firestore.collection('item_count').doc('users_count');
    DocumentSnapshot snap = await ref.get();
    if (snap.exists == true) {
      int itemCount = snap[fieldName] ?? 0;
      return itemCount;
    } else {
      await ref.set({fieldName: 0});
      return 0;
    }
  }

  Future increaseUserCount() async {
    await getTotalUsersCount().then((int documentCount) async {
      await firestore
          .collection('item_count')
          .doc('users_count')
          .update({'count': documentCount + 1});
    });
  }

  Future deleteUserDatafromDatabase() async {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    await _db.collection('users').doc(uid).delete();
  }

  Future<void> registerToEndpoint(
      String name, String email, String image) async {
    final url = Uri.parse(Config().gmdvitaRegisterUrl);
    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + Config().token
        },
        body: json.encode({
          'name': name,
          'email': email,
          'image': image,
        }),
      );

      // print('Respuesta del servidor: ${response.body}');
    } catch (e) {
      print('Excepción al enviar el correo: $e');
    }
  }
}
