import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmshift_mobile/screens/login_screen.dart';
import 'package:farmshift_mobile/screens/home_screen.dart';
import 'package:farmshift_mobile/theme/app_theme.dart';
import 'package:farmshift_mobile/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the authentication service
  final authService = AuthService();
  await authService.init();
  
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  
  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>.value(
      value: authService,
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'FarmShift Mobile',
            theme: AppTheme.lightTheme,
            home: auth.isAuthenticated 
              ? const HomeScreen() 
              : const LoginScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}


