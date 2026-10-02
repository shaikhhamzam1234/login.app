import 'package:flutter/material.dart';

// Flutter Login & Registration App
// Mohammed Hamza Maheboobbhai Shaikh | Enrollment: 2504050200031
// SOCCA - IMSCIT Sem 3 | Flutter Framework Principles (1040245211)

void main() => runApp(const MyApp());

/// Simple in-memory user model + store
class AppUser {
  final String name, email, mobile, password;
  AppUser(this.name, this.email, this.mobile, this.password);
}

class UserStore {
  static final List<AppUser> users = [];

  static bool emailExists(String email) =>
      users.any((u) => u.email.toLowerCase() == email.toLowerCase());

  static AppUser? login(String id, String pass) {
    for (final u in users) {
      final match = u.email.toLowerCase() == id.toLowerCase() ||
          u.name.toLowerCase() == id.toLowerCase();
      if (match && u.password == pass) return u;
    }
    return null;
  }
}

/// Reusable validators
class Validators {
  static final _emailRx = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 3) return 'Name must be at least 3 characters';
    if (!RegExp(r"^[a-zA-Z ]+$").hasMatch(v.trim())) {
      return 'Name can contain letters only';
    }
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!_emailRx.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? mobile(String? v) {
    if (v == null || v.trim().isEmpty) return 'Mobile number is required';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Use letters and numbers';
    }
    return null;
  }
}

/// Root widget (Stateless)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login & Registration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

/// Stateless header with a gesture: long press / double tap
class AppHeader extends StatelessWidget {
  final String title, subtitle;
  const AppHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        GestureDetector(
          onLongPress: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('About'),
              content: const Text(
                  'Mohammed Hamza Maheboobbhai Shaikh\nEnrollment: 2504050200031\n\nSOCCA - IMSCIT, Semester 3'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ],
            ),
          ),
          onDoubleTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Double tap detected ðŸ‘‹'))),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.lock_outline, size: 40, color: cs.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text('(Long press the icon for About)',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }
}

/// Login Screen (Stateful)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    final user = UserStore.login(_idCtrl.text.trim(), _passCtrl.text);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid credentials or account not registered'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Login successful! âœ…'),
      backgroundColor: Colors.green,
    ));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => WelcomeScreen(user: user)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const AppHeader(
                      title: 'Welcome Back', subtitle: 'Login to continue'),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _idCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Email / Username',
                        prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) => Validators.required(v, 'Email/Username'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                        onPressed: _login, child: const Text('Login')),
                  ),
                  const SizedBox(height: 16),
                  // Gesture: tap to navigate
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen())),
                    child: Text(
                      'Create New Account',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Registration Screen (Stateful)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true, _obscure2 = true;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _emailCtrl,
      _mobileCtrl,
      _passCtrl,
      _confirmCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    if (UserStore.emailExists(_emailCtrl.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('This email is already registered'),
          backgroundColor: Colors.red));
      return;
    }
    UserStore.users.add(AppUser(_nameCtrl.text.trim(), _emailCtrl.text.trim(),
        _mobileCtrl.text.trim(), _passCtrl.text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Registration successful! Please login. âœ…'),
        backgroundColor: Colors.green));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Full Name', prefixIcon: Icon(Icons.badge)),
                  validator: Validators.name,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mobileCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: Icon(Icons.phone),
                      counterText: ''),
                  validator: Validators.mobile,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure1,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure1 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscure2,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_reset),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure2 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (v != _passCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                      onPressed: _register, child: const Text('Register')),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('Already have an account? Login',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Welcome Screen (Stateless)
class WelcomeScreen extends StatelessWidget {
  final AppUser user;
  const WelcomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 90),
              const SizedBox(height: 16),
              Text('Welcome, ${user.name}!',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(user.email),
              Text(user.mobile),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
