import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _kvkkApproved = false;
  bool _ageApproved = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Lütfen tüm alanları doldurun.');
      return;
    }

    if (!email.contains('.edu.tr')) {
      _showError('Lütfen geçerli bir .edu.tr uzantılı üniversite e-postası girin.');
      return;
    }

    if (!_kvkkApproved) {
      _showError('Lütfen KVKK ve Gizlilik Sözleşmesini onaylayın.');
      return;
    }

    if (!_ageApproved) {
      _showError('Kayıt olmak için 18 yaşından büyük olmalısınız.');
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await auth.register(fullName, email, password);
      if (mounted && auth.isAuthenticated) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OtpScreen(email: email)),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Hesap Oluştur',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Üniversite e-postan ile hemen kayıt ol ve kampüs yolculuğuna başla.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8892B0),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _fullNameController,
                labelText: 'Ad Soyad',
                hintText: 'Ahmet Yılmaz',
                prefixIcon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _emailController,
                labelText: 'Üniversite E-postası',
                hintText: 'ogrenci@edu.tr',
                prefixIcon: Icons.school_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  '* Sadece .edu.tr uzantılı üniversite e-postaları kabul edilmektedir.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Şifre',
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: const Color(0xFF8892B0),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => setState(() => _kvkkApproved = !_kvkkApproved),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _kvkkApproved,
                        activeColor: const Color(0xFF00B4D8),
                        checkColor: const Color(0xFF0A192F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: const BorderSide(color: Color(0xFF334155), width: 1.5),
                        onChanged: (val) {
                          if (val != null) setState(() => _kvkkApproved = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'KVKK ve Gizlilik Sözleşmesini okudum, onaylıyorum.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF8892B0), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => setState(() => _ageApproved = !_ageApproved),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _ageApproved,
                        activeColor: const Color(0xFF00B4D8),
                        checkColor: const Color(0xFF0A192F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: const BorderSide(color: Color(0xFF334155), width: 1.5),
                        onChanged: (val) {
                          if (val != null) setState(() => _ageApproved = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        '18 yaşından büyük olduğumu onaylıyorum.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF8892B0)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              auth.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8)))
                  : CustomButton.primary(
                      text: 'Kayıt Ol',
                      onPressed: _handleRegister,
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
