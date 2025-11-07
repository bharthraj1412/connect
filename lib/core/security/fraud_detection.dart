import 'package:device_info_plus/device_info_plus.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';

class FraudDetectionService {
  static final FraudDetectionService _instance =
      FraudDetectionService._internal();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  late String _deviceFingerprint;

  factory FraudDetectionService() {
    return _instance;
  }

  FraudDetectionService._internal();

  /// Generate device fingerprint
  Future<String> generateDeviceFingerprint() async {
    try {
      String fingerprint;
      // For Android
      final androidInfo = await _deviceInfo.androidInfo;
      fingerprint = md5
          .convert(utf8.encode(
              '${androidInfo.device}${androidInfo.manufacturer}${androidInfo.serialNumber}${androidInfo.id}'))
          .toString();
      _deviceFingerprint = fingerprint;
      return fingerprint;
    } catch (e) {
      throw Exception('Failed to generate device fingerprint: $e');
    }
  }

  /// Get stored device fingerprint
  String getDeviceFingerprint() {
    return _deviceFingerprint;
  }

  /// Detect suspicious activity
  bool detectSuspiciousActivity({
    required int transactionCount,
    required double totalAmount,
    required int timeFrameHours,
    required List<String> ipAddresses,
  }) {
    // Rule 1: Multiple large transactions in short time
    if (transactionCount > 5 && totalAmount > 50000 && timeFrameHours < 24) {
      return true;
    }
    // Rule 2: Multiple IP addresses in same session
    if (ipAddresses.toSet().length > 3) {
      return true;
    }
    // Rule 3: Unusual transaction pattern
    if (totalAmount > 100000 && transactionCount == 1) {
      return true;
    }
    return false;
  }

  /// Validate referral chain integrity
  bool validateReferralChain(List<String> referralChain) {
    // Check for circular references
    final uniqueIds = referralChain.toSet();
    if (uniqueIds.length != referralChain.length) {
      return false; // Circular reference detected
    }
    // Check chain doesn't exceed max depth
    if (referralChain.length > 5) {
      return false;
    }
    return true;
  }

  /// Detect velocity abuse (too many accounts from same device)
  bool detectVelocityAbuse({
    required int accountsFromDevice,
    required int maxAllowed,
  }) {
    return accountsFromDevice > maxAllowed;
  }

  /// Check for impossible geography (sudden location changes)
  bool detectImpossibleGeography({
    required double lastLatitude,
    required double lastLongitude,
    required double currentLatitude,
    required double currentLongitude,
    required int timeElapsedSeconds,
  }) {
    // Calculate distance using Haversine formula
    const earthRadiusKm = 6371;
    final dLat = _toRad(currentLatitude - lastLatitude);
    final dLon = _toRad(currentLongitude - lastLongitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lastLatitude)) *
            cos(_toRad(currentLatitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadiusKm * c;
    // Calculate max possible speed (900 km/h = jet speed)
    final maxPossibleDistance = (timeElapsedSeconds / 3600) * 900;
    return distance > maxPossibleDistance;
  }

  double _toRad(double degrees) {
    return degrees * (pi / 180);
  }

  /// Validate UPI transaction
  bool validateUpiTransaction({
    required String upiId,
    required double amount,
    required String transactionId,
  }) {
    // Check UPI format
    if (!RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z]+$').hasMatch(upiId)) {
      return false;
    }
    // Check amount is positive
    if (amount <= 0) {
      return false;
    }
    // Check amount is within limits
    if (amount < 100 || amount > 50000) {
      return false;
    }
    // Check transaction ID format (UUID)
    if (!RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
            caseSensitive: false)
        .hasMatch(transactionId)) {
      return false;
    }
    return true;
  }

  /// Calculate risk score (0-100)
  int calculateRiskScore({
    required int newAccountAge,
    required int transactionCount,
    required double totalTransactionAmount,
    required bool isDeviceVerified,
    required bool isLocationConsistent,
    required bool isPhoneVerified,
  }) {
    int riskScore = 0;
    // New account risk (0-30)
    if (newAccountAge < 1) {
      riskScore += 30; // Brand new account
    } else if (newAccountAge < 7) {
      riskScore += 15; // Less than a week
    } else if (newAccountAge < 30) {
      riskScore += 5; // Less than a month
    }
    // Transaction pattern risk (0-25)
    if (transactionCount > 10) {
      riskScore += 25;
    } else if (transactionCount > 5) {
      riskScore += 15;
    }
    // High amount risk (0-20)
    if (totalTransactionAmount > 100000) {
      riskScore += 20;
    } else if (totalTransactionAmount > 50000) {
      riskScore += 10;
    }
    // Device verification (0-15)
    if (!isDeviceVerified) {
      riskScore += 15;
    }
    // Location consistency (0-10)
    if (!isLocationConsistent) {
      riskScore += 10;
    }
    // Phone verification (0-10)
    if (!isPhoneVerified) {
      riskScore += 10;
    }
    return riskScore.clamp(0, 100);
  }

  /// Check if risk score requires additional verification
  bool requiresAdditionalVerification(int riskScore) {
    return riskScore > 50;
  }
}
