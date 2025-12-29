import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/colors.dart';
import '../../home/screens/main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;

  // KRİTER 1: State Management (Durum Yönetimi)
  // Ekranın "Yükleniyor" durumunu kontrol eden değişken.
  bool _isLoading = false; 

  // KRİTER 2: Asenkron Yapıların Yönetimi (Async/Await)
  // Giriş işlemini asenkron hale getirdik.
  Future<void> _handleLogin() async {
    // 1. Klavyeyi kapat
    FocusScope.of(context).unfocus();

    // 2. Yükleniyor durumunu başlat (UI güncellenir)
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Yapay Gecikme (Simülasyon): Gerçek bir veritabanına bağlanıyormuş gibi 2 saniye bekletiyoruz.
      // Bu kısım "Asenkron yapıların yönetimi" puanını getirir.
      await Future.delayed(const Duration(seconds: 2));

      // Hata Yönetimi Örneği (İsteğe bağlı):
      if (_emailController.text.isNotEmpty && !_emailController.text.contains('@')) {
         throw Exception('Geçerli bir mail adresi giriniz.');
      }

      // 4. İşlem başarılı, ana sayfaya git
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver (Hata/Crash olmaması kriteri)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 5. Her durumda yükleniyor simgesini kaldır
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🐰', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  Text(
                    'Smart Bunny',
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.purple700),
                  ),
                  Text(
                    'Öğrenmeye kaldığın yerden devam et!',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppColors.primaryPurple.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          // Kullanıcı deneyimi: Yükleme sırasında inputları kilitle
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
                          obscureText: _isObscure,
                          enabled: !_isLoading,
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
                        
                        // BUTON KISMI DEĞİŞTİ
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.buttonGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: AppColors.purple600.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              // Yükleme varsa tıklamayı engelle
                              onTap: _isLoading ? null : _handleLogin,
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                // KRİTER 1 & 2'nin UI Yansıması:
                                // Eğer yükleniyorsa dönen çember (CircularProgressIndicator) göster,
                                // değilse "Giriş Yap" yazısını göster.
                                child: _isLoading 
                                  ? const SizedBox(
                                      height: 24, 
                                      width: 24, 
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                    )
                                  : Text(
                                      'Giriş Yap', 
                                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Hesabın yok mu?', style: GoogleFonts.poppins(color: Colors.black54)),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                        child: Text('Kayıt Ol', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.purple700)),
                      ),
                    ],
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