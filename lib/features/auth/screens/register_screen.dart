import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../../../core/utils/colors.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      if (_nameController.text.trim().isEmpty) {
        throw Exception('Lütfen adınızı giriniz.');
      }
      if (!_emailController.text.contains('@')) {
        throw Exception('Geçerli bir mail adresi giriniz.');
      }
      if (_passwordController.text.length < 6) {
        throw Exception('Şifre en az 6 karakter olmalıdır.');
      }

      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (res.user != null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': res.user!.id, 
          'full_name': _nameController.text.trim(),
          'total_score': 0, 
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz.'), backgroundColor: Colors.green),
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        }
      }
    } catch (e) {
      if (mounted) {
        String mesaj = "Kayıt yapılamadı.";

        if (e.toString().contains("User already registered") || e.toString().contains("user_already_exists")) {
          mesaj = "Bu e-posta zaten kullanımda.";
        } else {
          mesaj = e.toString().replaceAll("AuthException:", "").replaceAll("Exception:", "").trim();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mesaj), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.purple700),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('🐰', style: TextStyle(fontSize: 60)),
                  Text(
                    'Aramıza Katıl',
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.purple700),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppColors.primaryPurple.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            labelText: 'Ad Soyad',
                            prefixIcon: const Icon(Icons.person_outline, color: AppColors.purple600),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: AppColors.purple50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            labelText: 'E-posta',
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.purple600),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: AppColors.purple50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          enabled: !_isLoading,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.purple600),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _isObscure = !_isObscure),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: AppColors.purple50,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.buttonGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: AppColors.purple600.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLoading ? null : _handleRegister,
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                    : Text('Kayıt Ol', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                      ],
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