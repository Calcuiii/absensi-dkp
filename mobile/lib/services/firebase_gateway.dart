import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class FirebaseConfig {
  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const senderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const region = 'asia-southeast2';

  static bool get configured =>
      projectId.isNotEmpty &&
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      senderId.isNotEmpty;

  static FirebaseOptions get options => FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: senderId,
    projectId: projectId,
    authDomain: '$projectId.firebaseapp.com',
  );
}

class ServiceFailure implements Exception {
  const ServiceFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class FirebaseGateway {
  Future<void>? _googleReady;

  Future<Map<String, dynamic>> signIn() async {
    try {
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      } else {
        if (FirebaseConfig.webClientId.isEmpty) {
          throw const ServiceFailure(
            'Konfigurasi login Google belum lengkap. Hubungi pengelola.',
          );
        }
        _googleReady ??= GoogleSignIn.instance.initialize(
          serverClientId: FirebaseConfig.webClientId,
        );
        await _googleReady;
        final account = await GoogleSignIn.instance.authenticate();
        final token = account.authentication.idToken;
        if (token == null) {
          throw const ServiceFailure('Google belum memberikan bukti login.');
        }
        await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(idToken: token),
        );
      }
      return await call('verifyAccess');
    } catch (_) {
      await FirebaseAuth.instance.signOut();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!kIsWeb && _googleReady != null) await GoogleSignIn.instance.signOut();
  }

  Future<Map<String, dynamic>> call(
    String name, [
    Map<String, dynamic> data = const {},
  ]) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw const ServiceFailure('Silakan masuk kembali.');
    final url = Uri.https(
      '${FirebaseConfig.region}-${FirebaseConfig.projectId}.cloudfunctions.net',
      '/$name',
    );
    try {
      // Standard Firebase HTTPS callable protocol; the server validates the ID token.
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'data': data}),
          )
          .timeout(const Duration(seconds: 35));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['error'] case final Map<String, dynamic> error) {
        throw ServiceFailure(
          error['message'] as String? ?? 'Permintaan belum berhasil.',
        );
      }
      if (response.statusCode != 200 || body['result'] is! Map) {
        throw const ServiceFailure('Respons server tidak valid. Coba kembali.');
      }
      return Map<String, dynamic>.from(body['result'] as Map);
    } on ServiceFailure {
      rethrow;
    } on TimeoutException {
      throw const ServiceFailure(
        'Respons belum diterima. Muat ulang riwayat sebelum mencoba lagi.',
      );
    } catch (_) {
      throw const ServiceFailure(
        'Server belum dapat dihubungi. Periksa koneksi dan coba kembali.',
      );
    }
  }
}
