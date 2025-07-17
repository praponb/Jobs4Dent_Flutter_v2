import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
    debugPrint('Please make sure .env file exists in the project root with your API key');
  }
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
            debugPrint('📝 User needs profile setup - showing UserTypeSelectionScreen');
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
