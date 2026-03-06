import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);
  
  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _codeSent = false;
  String _verificationId = '';
  
  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
  
  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    
    // Add country code if not present
    String formattedPhone = phone;
    if (!phone.startsWith('+')) {
      formattedPhone = '+222$phone'; // Mauritania country code
    }
    
    final authProvider = context.read<AuthProvider>();
    await authProvider.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      onCodeSent: (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
        });
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
  }
  
  Future<void> _verifyCode() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) return;
    
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOTP(otp);
    
    if (success) {
      if (authProvider.currentUser?.selectedYearId != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/select-year');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Verification failed')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.phoneAuthTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 48),
            Icon(
              Icons.phone_android,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.welcome,
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            if (!_codeSent) ...[
              Text(
                l10n.enterPhone,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: l10n.phoneHint,
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _sendCode,
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(l10n.sendCode),
              ),
            ] else ...[
              Text(
                l10n.enterOtp,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 45,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  activeColor: Theme.of(context).primaryColor,
                  inactiveColor: Colors.grey,
                  selectedColor: Theme.of(context).primaryColor,
                ),
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                onCompleted: (_) => _verifyCode(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _verifyCode,
                child: authProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(l10n.verify),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _codeSent = false;
                    _otpController.clear();
                  });
                },
                child: Text(l10n.resendCode),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
