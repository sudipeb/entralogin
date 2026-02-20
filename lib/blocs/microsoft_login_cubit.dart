import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:dio/dio.dart';
import 'package:entralogin/api.dart';
import 'package:entralogin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';
import 'microsoft_login_state.dart';

class AuthCubit extends Cubit<AuthState> {
  late AadOAuth oauth;

  AuthCubit() : super(AuthInitial()) {
    final Config config = Config(
      tenant: dotenv.env['TENANT'] ?? '',
      clientId: dotenv.env['CLIENT_ID'] ?? '',
      scope: "openid profile offline_access User.Read",
      redirectUri: dotenv.env['REDIRECT_URL'] ?? '',
      navigatorKey: navigatorKey,
    );
    oauth = AadOAuth(config);
  }

  Future<void> login() async {
    emit(AuthLoading());
    try {
      await oauth.login();
      final accessToken = await oauth.getAccessToken();

      if (accessToken == null) {
        emit(AuthError("Access token is null. Login failed."));
        return;
      }

      debugPrint("Access Token: $accessToken");

      // 1. Fetch user details first
      Response jsonResponse = await API().getUserDetails(token: accessToken);
      final Map<String, dynamic> userData = jsonResponse.data;

      // Fallback to userPrincipalName if 'mail' is null
      final String name = userData['displayName'] ?? 'Name Not Available';
      final String email = userData['mail'] ?? userData['userPrincipalName'] ?? 'Email Not Available';

      Uint8List? photo;

      // 2. Fetch profile photo in a separate TRY block
      try {
        Response photoResponse = await API().getProfileImage(token: accessToken);
        if (photoResponse.data != null && photoResponse.data is List<int>) {
          photo = Uint8List.fromList(photoResponse.data);
        }
      } catch (photoError) {
        // If photo fails (404), we don't care! Just log it and keep 'photo' as null
        debugPrint("User has no profile photo (404). Using default avatar.");
      }

      // 3. Always emit success if we got at least the name and email
      emit(AuthSuccess(photo, name, email));
    } catch (e) {
      debugPrint("Login/API Error: $e");
      // If we are here, it means either login failed or getUserDetails failed
      emit(AuthError("Login failed. Please check your connection."));
    }
  }

  Future<void> logout() async {
    try {
      await oauth.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError("Logout failed. Please try again."));
    }
  }
}
