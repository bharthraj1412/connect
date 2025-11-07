class AppConfig {
  static const String appName = 'ShareNet Earn';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // API Configuration
  static const String apiBaseUrl = 'https://firestore.googleapis.com/v1';
  static const int apiTimeoutSeconds = 30;
  static const int maxRetries = 3;

  // Commission Structure
  static const double directCommission = 0.15; // 15%
  static const double level1Commission = 0.08; // 8%
  static const double level2Commission = 0.05; // 5%
  static const double level3Commission = 0.02; // 2%
  static const double level4Commission = 0.01; // 1%
  static const double companyShare = 0.20; // 20%

  // User Earnings
  static const double userShare = 0.80; // 80%
  static const int maxReferralLevels = 5;

  // Payment Configuration
  static const double minWithdrawal = 100.0;
  static const double maxWithdrawal = 50000.0;
  static const double minHotspotEarning = 1.0;

  // Background Service
  static const int backgroundServiceIntervalMinutes = 5;
  static const int wifiMonitoringIntervalSeconds = 30;

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String referralsCollection = 'referrals';
  static const String transactionsCollection = 'transactions';
  static const String commissionsCollection = 'commissions';
  static const String ordersCollection = 'orders';
  static const String auditLogsCollection = 'audit_logs';

  // Cache Configuration
  static const int cacheExpiryMinutes = 60;
  static const int maxLocalCacheItems = 1000;

  // Feature Flags
  static const bool enableCrashlytics = true;
  static const bool enableAnalytics = true;
  static const bool debugLogging = false;
  static const bool enableOfflineMode = true;

  // Security
  static const int encryptionKeyLength = 256;
  static const String tlsVersion = 'TLSv1.3';
  static const int sessionTimeoutMinutes = 30;
}
