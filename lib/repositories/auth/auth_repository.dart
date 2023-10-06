import 'dart:convert';
import 'dart:io';

import 'package:Medito/constants/constants.dart';
import 'package:Medito/models/models.dart';
import 'package:Medito/services/network/dio_api_service.dart';
import 'package:Medito/services/network/dio_client_provider.dart';
import 'package:Medito/services/shared_preference/shared_preferences_service.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

abstract class AuthRepository {
  Future<UserTokenModel> generateUserToken();
  Future<String> sendOTP(String email);
  Future<String> verifyOTP(String email, String OTP);
  Future<void> addUserInSharedPreference(UserTokenModel user);
  Future<UserTokenModel?> getUserFromSharedPreference();
}

class AuthRepositoryImpl extends AuthRepository {
  final DioApiService client;

  AuthRepositoryImpl({required this.client});

  @override
  Future<UserTokenModel> generateUserToken() async {
    try {
      var res = await client.postRequest(
        HTTPConstants.USERS,
        options: Options(headers: {
          HttpHeaders.authorizationHeader: HTTPConstants.INIT_TOKEN,
        }),
      );

      return UserTokenModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> sendOTP(String email) async {
    try {
      var res = await client
          .postRequest('${HTTPConstants.OTP}', data: {'email': email});
      print(res);

      return res['success'];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> verifyOTP(String email, String OTP) async {
    try {
      var res = await client
          .postRequest('${HTTPConstants.OTP}/$OTP', data: {'email': email});
      print(res);

      return res['success'];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addUserInSharedPreference(UserTokenModel user) async {
    await SharedPreferencesService.addStringInSharedPref(
      SharedPreferenceConstants.userToken,
      json.encode(user.toJson()),
    );
  }

  @override
  Future<UserTokenModel?> getUserFromSharedPreference() async {
    var user = await SharedPreferencesService.getStringFromSharedPref(
      SharedPreferenceConstants.userToken,
    );

    return user != null ? UserTokenModel.fromJson(json.decode(user)) : null;
  }
}

@riverpod
AuthRepository authRepository(ref) {
  return AuthRepositoryImpl(client: ref.watch(dioClientProvider));
}