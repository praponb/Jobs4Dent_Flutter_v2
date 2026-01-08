import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/job_provider.dart';
import 'providers/marketplace_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/verification_provider.dart';
import 'providers/branch_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/user_type_selection_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/local_notification_service.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// Comment add by Aek to make empty change in b_pbv_main
// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable Edge-to-Edge for Android 15+
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize Local Notification Service
  await LocalNotificationService.initialize();

  // Set up background message handler BEFORE Firebase initialization
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Load environment variables and Initialize Firebase in parallel
  // This prevents blocking the main thread for too long sequentially
  // Load environment variables first (in case Firebase options depend on them)
  // We must await this before Firebase.initializeApp
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
    debugPrint(
      'Please make sure .env file exists in the project root with your API key',
    );
  }

  // Initialize Firebase (blocked by dotenv)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("❌ Firebase Initialization Error: $e");
  }

  // Initialize App Check asynchronously (Fire and Forget)
  // Do NOT await this, as it can take time and block the UI from appearing.
  // The AuthWrapper handles the loading state naturally.
  FirebaseAppCheck.instance
      .activate(
        androidProvider: kReleaseMode
            ? AndroidProvider.playIntegrity
            : AndroidProvider.debug,
        appleProvider: kReleaseMode
            ? AppleProvider.deviceCheck
            : AppleProvider.debug,
      )
      .then((_) => debugPrint('✅ App Check Activated (Background)'));

  // Set up foreground message handlers AFTER Firebase initialization
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');

    // Check if notification is meant for the current user
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final data = message.data;
    final type = data['type'];
    final intendedRecipientId = type == 'job_application'
        ? data['clinicId']
        : (type == 'application_status_update' ? data['applicantId'] : null);

    if (intendedRecipientId != null && currentUser.uid != intendedRecipientId) {
      debugPrint(
        '🚫 Notification suppressed: intended for $intendedRecipientId, but current user is ${currentUser.uid}',
      );
      return;
    }

    if (message.notification != null) {
      debugPrint('🔔 Showing Local Notification');
      LocalNotificationService.showNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
        payload: message.data.toString(), // Pass data payload
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('A new onMessageOpenedApp event was published!');
    // Navigate to relevant screen based on notification data
  });

  runApp(const Jobs4DentApp());
}

class Jobs4DentApp extends StatelessWidget {
  const Jobs4DentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => VerificationProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
      ],
      child: MaterialApp(
        title: 'Jobs4Dent',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF2196F3),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          debugPrint('⏳ Showing SplashScreen - loading...');
          return const SplashScreen();
        }

        if (authProvider.user != null) {
          debugPrint('👤 User is authenticated: ${authProvider.user!.email}');
          // Check if user needs to complete profile setup
          if (authProvider.needsProfileSetup) {
            debugPrint(
              '📝 User needs profile setup - showing UserTypeSelectionScreen',
            );
            return const UserTypeSelectionScreen();
          } else {
            debugPrint('✅ User profile complete - showing HomeScreen');
            return const HomeScreen();
          }
        } else {
          debugPrint('🔐 No user authenticated - showing LoginScreen');
          return const LoginScreen();
        }
      },
    );
  }
}
