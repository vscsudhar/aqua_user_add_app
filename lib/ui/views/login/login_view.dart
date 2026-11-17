import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import 'login_viewmodel.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, LoginViewModel viewModel, Widget? child) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: Stack(
        children: [
          // Background ambient gradient circles
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kcPrimaryColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kcIndigoColor.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : 32,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 24 : 36),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF334155).withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 35,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: kcPrimaryColor.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with Brand Logo
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kcPrimaryColor, kcIndigoColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kcPrimaryColor.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'AQUA USER',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Super Administrator Portal',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kcPrimaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: kcPrimaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'CENTRAL TENANT & PLAN MANAGEMENT',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: kcPrimaryLight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      if (viewModel.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kcDanger.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kcDanger.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: kcDanger, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFFFCA5A5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Email / Username Input
                      Text(
                        'Email or Username',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        key: const ValueKey('super_admin_email_input'),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                        controller: TextEditingController(text: viewModel.login)
                          ..selection = TextSelection.fromPosition(
                            TextPosition(offset: viewModel.login.length),
                          ),
                        decoration: InputDecoration(
                          hintText: 'superadmin@aquasystem.com',
                          hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF94A3B8), size: 20),
                          filled: true,
                          fillColor: const Color(0xFF1E293B),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF334155)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF334155)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: kcPrimaryColor, width: 1.8),
                          ),
                        ),
                        onChanged: viewModel.setLogin,
                      ),
                      const SizedBox(height: 18),

                      // Password Input
                      Text(
                        'Master Password',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        key: const ValueKey('super_admin_password_input'),
                        obscureText: !viewModel.isPasswordVisible,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                        controller: TextEditingController(text: viewModel.password)
                          ..selection = TextSelection.fromPosition(
                            TextPosition(offset: viewModel.password.length),
                          ),
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              viewModel.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF94A3B8),
                              size: 20,
                            ),
                            onPressed: viewModel.togglePasswordVisibility,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1E293B),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF334155)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF334155)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: kcPrimaryColor, width: 1.8),
                          ),
                        ),
                        onChanged: viewModel.setPassword,
                        onSubmitted: (_) => viewModel.submitLogin(),
                      ),
                      const SizedBox(height: 8),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          key: const ValueKey('forgot_password_button'),
                          onPressed: () => _openForgotPasswordDialog(context, viewModel),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.inter(
                              color: kcPrimaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Sign In Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          key: const ValueKey('super_admin_login_button'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kcPrimaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: viewModel.isBusy ? null : viewModel.submitLogin,
                          child: viewModel.isBusy
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.login_rounded, size: 20),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Access Main Admin Panel',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quick Demo Credentials Fill (Helper for reviewers/testing)
                      Center(
                        child: TextButton.icon(
                          onPressed: viewModel.fillDemoCredentials,
                          icon: const Icon(Icons.flash_on_rounded, size: 16, color: kcPrimaryLight),
                          label: Text(
                            'Quick Fill Super Admin Credentials',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kcPrimaryLight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Server IP / Base URL indicator & network configurator
                      Center(
                        child: InkWell(
                          key: const ValueKey('server_config_button'),
                          onTap: () => _showServerConfigDialog(context, viewModel),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.wifi_tethering_rounded, size: 14, color: Color(0xFF10B981)),
                                const SizedBox(width: 6),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 240),
                                  child: Text(
                                    viewModel.currentBaseUrl,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 11,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.edit, size: 12, color: Color(0xFF94A3B8)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showServerConfigDialog(BuildContext context, LoginViewModel viewModel) {
    final controller = TextEditingController(text: viewModel.currentBaseUrl);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.dns_rounded, color: kcPrimaryColor, size: 22),
              const SizedBox(width: 10),
              Text(
                'Server Base URL / IP',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configure the backend API server URL based on your current network / Wi-Fi IP.',
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Base URL',
                  labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                  hintText: 'https://aqua-api.ethiodeploy.app/api/v1',
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Quick Network Presets:',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  ActionChip(
                    backgroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: kcPrimaryColor),
                    avatar: const Icon(Icons.cloud_done_rounded, size: 14, color: kcPrimaryLight),
                    label: Text('Marina Aqua Cloud', style: GoogleFonts.inter(fontSize: 11, color: kcPrimaryLight, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      controller.text = 'https://aqua-api.ethiodeploy.app/api/v1';
                    },
                  ),
                  ActionChip(
                    backgroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFF334155)),
                    label: Text('Wi-Fi (192.168.0.174)', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                    onPressed: () {
                      controller.text = 'http://192.168.0.174:8000/api/v1';
                    },
                  ),
                  ActionChip(
                    backgroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFF334155)),
                    label: Text('Localhost (127.0.0.1)', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                    onPressed: () {
                      controller.text = 'http://127.0.0.1:8000/api/v1';
                    },
                  ),
                  ActionChip(
                    backgroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFF334155)),
                    label: Text('Emulator (10.0.2.2)', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                    onPressed: () {
                      controller.text = 'http://10.0.2.2:8000/api/v1';
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kcPrimaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  await viewModel.updateBaseUrl(text);
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text('Save', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _openForgotPasswordDialog(BuildContext context, LoginViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) => _ForgotPasswordDialog(viewModel: viewModel),
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();
}

class _ForgotPasswordDialog extends StatefulWidget {
  final LoginViewModel viewModel;
  const _ForgotPasswordDialog({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  int _step = 1;
  late final TextEditingController _emailCtrl;
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;
  String? _dialogError;
  String? _dialogSuccess;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.viewModel.login);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _dialogError = 'Please enter your email or username.');
      return;
    }

    setState(() {
      _isLoading = true;
      _dialogError = null;
      _dialogSuccess = null;
    });

    try {
      final res = await widget.viewModel.sendForgotPasswordCode(email);
      final generatedCode = res['reset_code']?.toString() ?? res['code']?.toString();
      final resolvedEmail = res['email']?.toString() ?? email;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _step = 2;
          if (generatedCode != null && generatedCode.isNotEmpty) {
            _codeCtrl.text = generatedCode;
          }
          _emailCtrl.text = resolvedEmail;
          _dialogSuccess = 'Verification code generated! Please enter the code and your new password.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _dialogError = e.toString();
        });
      }
    }
  }

  Future<void> _handleResetPassword() async {
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final newPass = _newPassCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    if (code.isEmpty) {
      setState(() => _dialogError = 'Please enter the 6-digit verification code.');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _dialogError = 'Password must be at least 6 characters long.');
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _dialogError = 'Passwords do not match. Please verify.');
      return;
    }

    setState(() {
      _isLoading = true;
      _dialogError = null;
      _dialogSuccess = null;
    });

    try {
      final msg = await widget.viewModel.submitPasswordReset(
        email: email,
        code: code,
        newPassword: newPass,
        confirmPassword: confirmPass,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _dialogSuccess = msg;
        });

        Future.delayed(const Duration(milliseconds: 1400), () {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: kcSuccess,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _dialogError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF334155)),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kcPrimaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_reset, color: kcPrimaryLight, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            _step == 1 ? 'Forgot Password' : 'Reset Password',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _step == 1
                    ? 'Enter your registered email address or username. A verification code will be generated to reset your password.'
                    : 'Enter the verification code and choose a secure new password for your administrator account.',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),

              if (_dialogSuccess != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: kcSuccess.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kcSuccess.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: kcSuccess, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _dialogSuccess!,
                          style: GoogleFonts.inter(color: kcSuccess, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_dialogError != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: kcDanger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kcDanger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: kcDanger, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _dialogError!,
                          style: GoogleFonts.inter(color: kcDanger, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_step == 1) ...[
                Text('Email or Username', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailCtrl,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'admin@example.com',
                    hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 13),
                    prefixIcon: const Icon(Icons.email_outlined, color: kcPrimaryLight, size: 18),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ] else ...[
                Text('Registered Email', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailCtrl,
                  readOnly: true,
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.white38, size: 18),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                Text('Verification Code', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: _codeCtrl,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 2),
                  decoration: InputDecoration(
                    hintText: '6-digit code',
                    hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 13, letterSpacing: 0),
                    prefixIcon: const Icon(Icons.security, color: kcPrimaryLight, size: 18),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                Text('New Password (min 6 chars)', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: _newPassCtrl,
                  obscureText: _obscureNewPass,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Enter new password',
                    hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 13),
                    prefixIcon: const Icon(Icons.lock_outline, color: kcPrimaryLight, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNewPass ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 18),
                      onPressed: () => setState(() => _obscureNewPass = !_obscureNewPass),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),

                Text('Confirm New Password', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: _confirmPassCtrl,
                  obscureText: _obscureConfirmPass,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Re-enter new password',
                    hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 13),
                    prefixIcon: const Icon(Icons.lock_outline, color: kcPrimaryLight, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPass ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 18),
                      onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kcPrimaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _isLoading ? null : (_step == 1 ? _handleSendCode : _handleResetPassword),
          child: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_step == 1 ? 'Send Code' : 'Reset Password', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
