import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/api_config.dart';

/// Thin HTTP wrapper around the Spring Boot `handyhire-backend`.
///
/// Keeps all network knowledge in one place so screens don't litter `http.post`
/// calls. Every method returns a decoded JSON map (or list) and throws an
/// [ApiException] on HTTP / network failure so callers can show a snackbar.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final _client = http.Client();

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  // ─── AUTH ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) =>
      _postJson(ApiConfig.login, {'email': email, 'password': password});

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role, // "CUSTOMER" | "PROVIDER" | "ADMIN"
  }) =>
      _postJson(ApiConfig.register, {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });

  Future<Map<String, dynamic>> sendAdminOtp({
    required String email,
    required String password,
  }) =>
      _postJson(ApiConfig.adminSendOtp, {'email': email, 'password': password});

  Future<Map<String, dynamic>> verifyAdminOtp({
    required String email,
    required int otp,
  }) =>
      _postJson(ApiConfig.adminVerifyOtp, {'email': email, 'otp': otp});

  // ─── JOBS ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createJob({
    required int customerId,
    required Map<String, dynamic> jobDto,
  }) =>
      _postJson(ApiConfig.createJob(customerId), jobDto);

  Future<Map<String, dynamic>> getOpenJobs({String? category}) {
    final path = category != null
        ? '${ApiConfig.openJobs}?category=$category'
        : ApiConfig.openJobs;
    return _getJson(path);
  }

  Future<Map<String, dynamic>> getJobsByCustomer(int customerId) =>
      _getJson(ApiConfig.jobsByCustomer(customerId));

  Future<Map<String, dynamic>> getJobsByProvider(int providerId) =>
      _getJson(ApiConfig.jobsByProvider(providerId));

  // ─── BIDS ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> placeBid({
    required int jobId,
    required Map<String, dynamic> bidDto,
  }) =>
      _postJson(ApiConfig.bidsForJob(jobId), bidDto);

  Future<Map<String, dynamic>> acceptBid(int jobId, int bidId) =>
      _putJson(ApiConfig.acceptBid(jobId, bidId), const {});

  Future<Map<String, dynamic>> rejectBid(int jobId, int bidId) =>
      _putJson(ApiConfig.rejectBid(jobId, bidId), const {});

  Future<Map<String, dynamic>> sendCounterOffer({
    required int jobId,
    required int bidId,
    required double counterPrice,
    String? note,
  }) =>
      _postJson(ApiConfig.counterOffer(jobId, bidId), {
        'counterPrice': counterPrice,
        'note': note,
      });

  // ─── BOOKINGS ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createBooking(int jobId, int bidId) =>
      _postJson(ApiConfig.createBooking(jobId, bidId), const {});

  Future<Map<String, dynamic>> startJourney({
    required int bookingId,
    required double lat,
    required double lng,
  }) =>
      _putJson(ApiConfig.startJourney(bookingId), {'lat': lat, 'lng': lng});

  Future<Map<String, dynamic>> markArrived(int bookingId) =>
      _putJson(ApiConfig.arrived(bookingId), const {});

  Future<Map<String, dynamic>> completeBooking(int bookingId) =>
      _putJson(ApiConfig.completeBooking(bookingId), const {});

  // ─── INTERNALS ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _getJson(String path) async {
    try {
      final res = await _client
          .get(_uri(path), headers: _headers())
          .timeout(ApiConfig.timeout);
      return _decode(res);
    } on TimeoutException {
      throw ApiException('Request timed out. Is the backend running?');
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> _postJson(
      String path, Map<String, dynamic> body) async {
    try {
      final res = await _client
          .post(_uri(path), headers: _headers(), body: jsonEncode(body))
          .timeout(ApiConfig.timeout);
      return _decode(res);
    } on TimeoutException {
      throw ApiException('Request timed out. Is the backend running?');
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> _putJson(
      String path, Map<String, dynamic> body) async {
    try {
      final res = await _client
          .put(_uri(path), headers: _headers(), body: jsonEncode(body))
          .timeout(ApiConfig.timeout);
      return _decode(res);
    } on TimeoutException {
      throw ApiException('Request timed out. Is the backend running?');
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, dynamic> _decode(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(
          'Server returned ${res.statusCode}: ${res.body}');
    }
    if (res.body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    // Some endpoints return a raw list — wrap it.
    return {'data': decoded};
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
