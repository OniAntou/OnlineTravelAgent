import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:online_travel_agent/services/travel_api_service.dart';
import 'package:online_travel_agent/models/destination.dart';
import 'package:online_travel_agent/models/document_item.dart';
import 'package:online_travel_agent/models/trip.dart';
import 'package:online_travel_agent/models/trip_schedule.dart';

class FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> data = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return data[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      data[key] = value;
    } else {
      data.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    data.remove(key);
  }
}

class FakeTravelApiService extends TravelApiService {
  final Map<String, dynamic> loginResponse;
  final Map<String, dynamic> registerResponse;
  final BootstrapData? bootstrapData;
  final Map<String, TripSchedule> tripSchedules;
  String? loginError;
  String? registerError;

  FakeTravelApiService({
    required super.secureStorage,
    this.loginResponse = const {
      'token': 'fake_token',
      'user': {'name': 'Test', 'email': 'test@test.com'},
    },
    this.registerResponse = const {
      'token': 'fake_token',
      'user': {'name': 'NewUser', 'email': 'new@test.com'},
    },
    this.bootstrapData,
    Map<String, TripSchedule>? tripSchedules,
    this.loginError,
    this.registerError,
  })  : tripSchedules = tripSchedules ?? {},
        super(baseUrl: 'http://localhost:3000');

  @override
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    await loadTokenFuture;
    if (loginError != null) throw Exception(loginError);
    final tokenValue = loginResponse['token']?.toString();
    if (tokenValue != null) {
      token = tokenValue;
      userName = loginResponse['user']?['name']?.toString();
      userEmail = loginResponse['user']?['email']?.toString();
      try {
        await secureStorage.write(key: 'auth_token', value: tokenValue);
        await secureStorage.write(key: 'auth_user_name', value: userName);
        await secureStorage.write(key: 'auth_user_email', value: userEmail);
      } catch (_) {}
    }
    return loginResponse;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await loadTokenFuture;
    if (registerError != null) throw Exception(registerError);
    final tokenValue = registerResponse['token']?.toString();
    if (tokenValue != null) {
      token = tokenValue;
      userName = registerResponse['user']?['name']?.toString();
      userEmail = registerResponse['user']?['email']?.toString();
      try {
        await secureStorage.write(key: 'auth_token', value: tokenValue);
        await secureStorage.write(key: 'auth_user_name', value: userName);
        await secureStorage.write(key: 'auth_user_email', value: userEmail);
      } catch (_) {}
    }
    return registerResponse;
  }

  @override
  Future<BootstrapData> fetchBootstrap() async {
    return bootstrapData ?? BootstrapData(
      categories: [],
      destinations: [],
      recommended: [],
      trips: [],
      documents: [],
      hotels: [],
      tourPackages: [],
    );
  }

  @override
  Future<TripSchedule> fetchTripSchedule(String tripId) async {
    return tripSchedules[tripId] ??
        TripSchedule(tripId: tripId, days: [], updates: []);
  }

  @override
  Future<Destination> setFavorite(String destinationId, bool isFavorite) async {
    return Destination(
      id: destinationId, name: 'Test', location: 'Test',
      rating: '4.0', duration: '1 ngày', imagePath: '',
      isFavorite: isFavorite,
    );
  }

  @override
  Future<Trip> bookTrip({required String destinationId, String? date, String? guests, double? totalPrice}) async {
    return Trip(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      destination: destinationId,
      location: 'Test Location',
      date: date ?? '',
      guests: guests ?? '',
      status: 'Upcoming',
      imagePath: '',
      totalPrice: totalPrice,
    );
  }

  @override
  Future<DocumentItem> addDocument({
    required String title,
    required String description,
    String icon = 'description',
    String color = '#176FF2',
  }) async {
    return DocumentItem(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      icon: Icons.description,
      color: Colors.blue,
      iconName: icon,
      colorHex: color,
    );
  }

  @override
  Future<bool> deleteDocument(String documentId) async {
    return true;
  }
}
