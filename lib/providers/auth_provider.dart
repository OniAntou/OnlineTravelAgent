import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../utils/api_exception.dart';
import 'api_provider.dart';
import 'profile_provider.dart';

class AuthState {
  final bool isLoggedIn;
  final String? token;
  final UserProfile? user;

  const AuthState({this.isLoggedIn = false, this.token, this.user});

  AuthState copyWith({bool? isLoggedIn, String? token, UserProfile? user}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restoreSession();
    return const AuthState();
  }

  Future<void> _restoreSession() async {
    try {
      final api = ref.read(apiProvider);
      await api.loadTokenFuture;
      if (api.token != null && api.token!.isNotEmpty) {
        final user = UserProfile(
          name: api.userName ?? 'User',
          email: api.userEmail ?? '',
        );
        state = AuthState(isLoggedIn: true, token: api.token, user: user);
        ref
            .read(profileProvider.notifier)
            .updateFromAuth(name: user.name, email: user.email);
      }
    } catch (e) {
      debugPrint('Session restore failed: $e');
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final api = ref.read(apiProvider);
      final data = await api.login(email: email, password: password);
      final user = UserProfile.fromJson(
        data['user'] as Map<String, dynamic>? ??
            {'name': email, 'email': email},
      );
      final token = data['token']?.toString();

      state = AuthState(isLoggedIn: true, token: token, user: user);
      ref
          .read(profileProvider.notifier)
          .updateFromAuth(name: user.name, email: user.email);

      return null;
    } on AuthException catch (e) {
      return e.message;
    } on ValidationException catch (e) {
      return e.message;
    } on NetworkException catch (e) {
      return e.message;
    } on TimeoutApiException catch (e) {
      return e.message;
    } catch (e) {
      return getErrorMessage(e);
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final api = ref.read(apiProvider);
      final data = await api.register(
        name: name,
        email: email,
        password: password,
      );
      final user = UserProfile.fromJson(
        data['user'] as Map<String, dynamic>? ?? {'name': name, 'email': email},
      );
      final token = data['token']?.toString();

      state = AuthState(isLoggedIn: true, token: token, user: user);
      ref
          .read(profileProvider.notifier)
          .updateFromAuth(name: user.name, email: user.email);

      return null;
    } on AuthException catch (e) {
      return e.message;
    } on ValidationException catch (e) {
      return e.message;
    } on NetworkException catch (e) {
      return e.message;
    } on TimeoutApiException catch (e) {
      return e.message;
    } catch (e) {
      return getErrorMessage(e);
    }
  }

  void logout() {
    ref.read(apiProvider).logout();
    state = const AuthState();
  }

  void updateToken(String newToken) {
    ref.read(apiProvider).token = newToken;
    state = state.copyWith(token: newToken);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
