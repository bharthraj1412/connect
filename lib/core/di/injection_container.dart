import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';

// Local imports and project modules:
import '../config/firebase_config.dart';
import '../encryption/encryption_service.dart';
import '../encryption/secure_storage.dart';
import '../security/fraud_detection.dart';
import '../security/api_interceptor.dart';
import '../../data/datasources/firebase_datasource.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/referral_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/payment_service.dart';
import '../../data/services/background_service.dart';
import '../../domain/repositories/auth_repository_interface.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../domain/usecases/login_user_usecase.dart';
import '../../domain/usecases/get_referral_tree_usecase.dart';
import '../../domain/usecases/process_payment_usecase.dart';
import '../../presentation/bloc/auth_bloc/auth_bloc.dart';
import '../../presentation/bloc/referral_bloc/referral_bloc.dart';
import '../../presentation/bloc/payment_bloc/payment_bloc.dart';
import '../../presentation/bloc/stats_bloc/stats_bloc.dart';

final getIt = GetIt.instance;

// Setup all dependencies for the application
Future<void> setupDependencies() async {
  // EXTERNAL Firebase Services
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  getIt.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  getIt.registerSingleton<FirebaseFunctions>(FirebaseFunctions.instance);

  // CORE CONFIG: Encryption & Security
  await EncryptionService.initialize();
  getIt.registerSingleton<EncryptionService>(EncryptionService());
  getIt.registerSingleton<SecureStorageService>(SecureStorageService());
  getIt.registerSingleton<FraudDetectionService>(FraudDetectionService());
  getIt.registerSingleton<ApiInterceptor>(
      ApiInterceptor(getIt<SecureStorageService>()));

  // DATA SOURCES
  getIt.registerSingleton<FirebaseDataSource>(FirebaseDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
      storage: getIt<FirebaseStorage>()));
  getIt.registerSingleton<LocalDataSource>(LocalDataSourceImpl());

  // SERVICES
  getIt.registerSingleton<FirebaseService>(FirebaseService(
      firestore: getIt<FirebaseFirestore>(), auth: getIt<FirebaseAuth>()));
  getIt.registerSingleton<PaymentService>(PaymentService(
      encryption: getIt<EncryptionService>(),
      firebaseDataSource: getIt<FirebaseDataSource>()));
  getIt.registerSingleton<BackgroundServiceManager>(BackgroundServiceManager());

  // REPOSITORIES
  getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl(
      firebaseDataSource: getIt<FirebaseDataSource>(),
      localDataSource: getIt<LocalDataSource>(),
      encryption: getIt<EncryptionService>()));
  getIt.registerSingleton<ReferralRepository>(
      ReferralRepositoryImpl(firebaseDataSource: getIt<FirebaseDataSource>()));
  getIt.registerSingleton<PaymentRepository>(PaymentRepositoryImpl(
      firebaseDataSource: getIt<FirebaseDataSource>(),
      paymentService: getIt<PaymentService>()));

  // USE CASES
  getIt.registerSingleton<RegisterUserUseCase>(
      RegisterUserUseCase(getIt<AuthRepository>()));
  getIt.registerSingleton<LoginUserUseCase>(
      LoginUserUseCase(getIt<AuthRepository>()));
  getIt.registerSingleton<GetReferralTreeUseCase>(
      GetReferralTreeUseCase(getIt<ReferralRepository>()));
  getIt.registerSingleton<ProcessPaymentUseCase>(
      ProcessPaymentUseCase(getIt<PaymentRepository>()));

  // BLoCs
  getIt.registerSingleton<AuthBloc>(AuthBloc(
    registerUserUseCase: getIt<RegisterUserUseCase>(),
    loginUserUseCase: getIt<LoginUserUseCase>(),
  ));
  getIt.registerSingleton<ReferralBloc>(
      ReferralBloc(getReferralTreeUseCase: getIt<GetReferralTreeUseCase>()));
  getIt.registerSingleton<PaymentBloc>(
      PaymentBloc(processPaymentUseCase: getIt<ProcessPaymentUseCase>()));
  getIt.registerSingleton<StatsBloc>(
      StatsBloc(firebaseDataSource: getIt<FirebaseDataSource>()));
}
