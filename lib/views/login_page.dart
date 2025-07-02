import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Consumer<AuthViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Single-column layout for smaller screens
                  return _buildSingleColumnLayout(viewModel);
                } else {
                  // Two-column layout for desktop
                  return Row(
                    children: [
                      _buildSidebar(),
                      Expanded(
                        child: _buildLoginForm(viewModel),
                      ),
                    ],
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSingleColumnLayout(AuthViewModel viewModel) {
    return Container(
      color: const Color(0xFFDDEAE0),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: const Color(0xFF82BECC),
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildFormContent(viewModel),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 300,
      color: const Color(0xFF007180),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png', height: 150),
          const SizedBox(height: 20),
          const Text(
            'OUTFITAURA ADMIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Welcome to the Admin Portal',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(AuthViewModel viewModel) {
    return Container(
      color: const Color(0xFFDDEAE0),
      child: Center(
        child: Card(
          color: const Color(0xFF82BECC),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildFormContent(viewModel),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(AuthViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Admin Login',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.white, fontSize: 16),
            filled: true,
            fillColor: Color(0xFFDDEAE0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(color: Colors.white, fontSize: 16),
            filled: true,
            fillColor: Color(0xFFDDEAE0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 30),
        if (viewModel.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              viewModel.errorMessage!,
              style: const TextStyle(color: Color(0xFFE15757), fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        viewModel.isLoading
            ? const CircularProgressIndicator(color: Color(0xFF4ACDEB))
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ACDEB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    await viewModel.login(_emailController.text, _passwordController.text);
                    if (viewModel.user != null) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                  child: const Text('Login', style: TextStyle(fontSize: 18)),
                ),
              ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}