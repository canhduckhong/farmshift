import 'package:flutter/material.dart';
import 'package:farmshift_mobile/theme/app_theme.dart';
import 'package:farmshift_mobile/screens/home_screen.dart';
import 'package:farmshift_mobile/services/mock_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if employee exists in mock data
      final employeeId = _employeeIdController.text.trim();
      final employee = MockDataService().getEmployeeById(employeeId);

      setState(() {
        _isLoading = false;
      });

      if (employee != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(employeeId: employeeId),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Employee ID not found. Please try again.';
        });
      }
    }
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryVeryLightColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.agriculture,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // App title
                Text(
                  'FarmShift',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // App subtitle
                Text(
                  'Employee Schedule App',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textMediumColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _employeeIdController,
                        decoration: const InputDecoration(
                          labelText: 'Employee ID',
                          hintText: 'Enter your employee ID',
                          prefixIcon: Icon(Icons.badge),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your employee ID';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _handleLogin(),
                      ),
                      
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Login'),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Demo login helper
                      Text(
                        'Hint: Try employee IDs 1-6 for demo',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
