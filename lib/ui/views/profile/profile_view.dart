import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../common/app_colors.dart';
import 'profile_viewmodel.dart';

class ProfileView extends StackedView<ProfileViewModel> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  ProfileViewModel viewModelBuilder(BuildContext context) => ProfileViewModel();

  @override
  void onViewModelReady(ProfileViewModel viewModel) => viewModel.init();

  @override
  Widget builder(BuildContext context, ProfileViewModel viewModel, Widget? child) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Back',
          onPressed: viewModel.goBack,
        ),
        title: Text(
          'Administrator Profile',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          if (!viewModel.isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                icon: const Icon(Icons.edit_outlined, color: kcPrimaryLight, size: 16),
                label: Text(
                  'Edit',
                  style: GoogleFonts.inter(
                    color: kcPrimaryLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                onPressed: viewModel.startEditing,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 32,
          vertical: 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Avatar Card
                _buildHeaderCard(context, viewModel, isMobile),
                const SizedBox(height: 20),

                // Success Message Banner
                if (viewModel.successMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: kcSuccess.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kcSuccess.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: kcSuccess, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            viewModel.successMessage!,
                            style: GoogleFonts.inter(
                              color: kcSuccess,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Error Message Banner
                if (viewModel.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: kcDanger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kcDanger.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: kcDanger, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            viewModel.errorMessage!,
                            style: GoogleFonts.inter(
                              color: kcDanger,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Content View vs Edit Form
                if (viewModel.isEditing)
                  _buildEditForm(context, viewModel, isMobile)
                else ...[
                  _buildViewDetails(context, viewModel, isMobile),
                  const SizedBox(height: 20),
                  _buildChangePasswordCard(context, viewModel, isMobile),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ProfileViewModel viewModel, bool isMobile) {
    final user = viewModel.currentUser;
    final displayName = user?.name.isNotEmpty == true ? user!.name : 'Super Administrator';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';
    final role = user?.role.toUpperCase() ?? 'SUPER_ADMIN';

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar with Photo and Edit Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [kcPrimaryColor, kcIndigoColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kcPrimaryColor.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: (user?.profileImage != null && user!.profileImage!.isNotEmpty)
                      ? Image.network(
                          user.profileImage!,
                          width: 86,
                          height: 86,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              initial,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Material(
                  color: kcPrimaryColor,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _showProfileImageDialog(context, viewModel),
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User Name
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user?.email ?? '—',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: kcTextSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),

          // Badges Row
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                label: role,
                color: kcPrimaryColor,
                icon: Icons.shield_outlined,
              ),
              _buildBadge(
                label: user?.isActive == false ? 'INACTIVE' : 'ACTIVE',
                color: user?.isActive == false ? kcDanger : kcSuccess,
                icon: Icons.check_circle_outline,
              ),
              if (user?.companyName != null && user!.companyName!.isNotEmpty)
                _buildBadge(
                  label: user.companyName!,
                  color: kcTealColor,
                  icon: Icons.business_outlined,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewDetails(BuildContext context, ProfileViewModel viewModel, bool isMobile) {
    final user = viewModel.currentUser;
    final createdDateFormatted = _formatDate(user?.createdAt);

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal & Account Information',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: kcPrimaryLight, size: 18),
                tooltip: 'Edit Profile',
                onPressed: viewModel.startEditing,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF1E293B)),
          const SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Full Name',
            value: user?.name.isNotEmpty == true ? user!.name : '—',
          ),
          const SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email Address',
            value: user?.email.isNotEmpty == true ? user!.email : '—',
          ),
          const SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Mobile Number',
            value: user?.phone?.isNotEmpty == true ? user!.phone! : 'Not provided',
          ),
          const SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.alternate_email,
            label: 'Username',
            value: user?.username?.isNotEmpty == true ? user!.username! : '—',
          ),
          const SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.business_outlined,
            label: 'Company / Organization',
            value: user?.companyName?.isNotEmpty == true
                ? user!.companyName!
                : 'SS AquaFlow System Administration',
          ),
          const SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Account Created',
            value: createdDateFormatted,
          ),
          const SizedBox(height: 28),

          // Primary Edit Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(
                'Edit Profile',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kcPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: viewModel.startEditing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, ProfileViewModel viewModel, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kcPrimaryColor.withValues(alpha: 0.4),
        ),
      ),
      child: Form(
        key: viewModel.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note, color: kcPrimaryLight, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Edit Profile Details',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Update your account credentials and personal information.',
              style: GoogleFonts.inter(
                color: kcTextSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF1E293B)),
            const SizedBox(height: 16),

            // Name Field
            _buildFieldLabel('Full Name *'),
            TextFormField(
              controller: viewModel.nameController,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_outline,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Name is required';
                }
                if (val.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Email Field
            _buildFieldLabel('Email Address *'),
            TextFormField(
              controller: viewModel.emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: 'admin@example.com',
                prefixIcon: Icons.email_outlined,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Email is required';
                }
                final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
                if (!emailRegex.hasMatch(val.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Mobile Number Field
            _buildFieldLabel('Mobile / Phone Number'),
            TextFormField(
              controller: viewModel.phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: '+91 98765 43210',
                prefixIcon: Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 18),

            // Username Field
            _buildFieldLabel('Username (Optional)'),
            TextFormField(
              controller: viewModel.usernameController,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: 'super_admin',
                prefixIcon: Icons.alternate_email,
              ),
            ),
            const SizedBox(height: 18),

            // Profile Image URL Field
            _buildFieldLabel('Profile Image URL (Optional)'),
            TextFormField(
              controller: viewModel.profileImageController,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: 'https://example.com/avatar.jpg',
                prefixIcon: Icons.image_outlined,
              ),
            ),
            const SizedBox(height: 28),

            // Action Buttons Row (Save & Cancel)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Color(0xFF334155)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: viewModel.isSaving ? null : viewModel.cancelEditing,
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: viewModel.isSaving ? null : viewModel.saveProfile,
                      child: viewModel.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Save Changes',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: const Color(0xFFCBD5E1),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: kcPrimaryLight, size: 18),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        borderSide: const BorderSide(color: kcPrimaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kcDanger),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Icon(icon, color: kcPrimaryLight, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: kcTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('MMMM dd, yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  Widget _buildChangePasswordCard(BuildContext context, ProfileViewModel viewModel, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: 0.6),
        ),
      ),
      child: Form(
        key: viewModel.passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kcPrimaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kcPrimaryColor.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.lock_reset, color: kcPrimaryLight, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Password',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Ensure your super administrator account stays secure with a strong password.',
                        style: GoogleFonts.inter(
                          color: kcTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF1E293B)),
            const SizedBox(height: 16),

            // Current Password
            _buildFieldLabel('Current Password *'),
            TextFormField(
              controller: viewModel.currentPasswordController,
              obscureText: viewModel.obscureCurrentPass,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: 'Enter your current password',
                prefixIcon: Icons.lock_outline,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.obscureCurrentPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: kcTextSecondary,
                    size: 18,
                  ),
                  onPressed: viewModel.toggleObscureCurrentPass,
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Current password is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // New Password
            _buildFieldLabel('New Password *'),
            TextFormField(
              controller: viewModel.newPasswordController,
              obscureText: viewModel.obscureNewPass,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: 'At least 6 characters',
                prefixIcon: Icons.vpn_key_outlined,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.obscureNewPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: kcTextSecondary,
                    size: 18,
                  ),
                  onPressed: viewModel.toggleObscureNewPass,
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'New password is required';
                }
                if (val.trim().length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Confirm Password
            _buildFieldLabel('Confirm New Password *'),
            TextFormField(
              controller: viewModel.confirmPasswordController,
              obscureText: viewModel.obscureConfirmPass,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                hintText: 'Repeat new password',
                prefixIcon: Icons.lock_clock_outlined,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.obscureConfirmPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: kcTextSecondary,
                    size: 18,
                  ),
                  onPressed: viewModel.toggleObscureConfirmPass,
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please confirm your new password';
                }
                if (val != viewModel.newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: viewModel.isChangingPassword ? null : viewModel.changePassword,
                child: viewModel.isChangingPassword
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.security, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Update Password',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileImageDialog(BuildContext context, ProfileViewModel viewModel) {
    final textController = TextEditingController(text: viewModel.currentUser?.profileImage ?? '');

    final presetAvatars = [
      {
        'label': 'Avatar 1',
        'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop&crop=face',
      },
      {
        'label': 'Avatar 2',
        'url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
      },
      {
        'label': 'Avatar 3',
        'url': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&h=200&fit=crop&crop=face',
      },
      {
        'label': 'Avatar 4',
        'url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&crop=face',
      },
      {
        'label': 'UI Initials',
        'url':
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(viewModel.currentUser?.name ?? 'Admin')}&background=0D8ABC&color=fff&size=200',
      },
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: const Color(0xFF111827),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kcPrimaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.photo_camera_outlined, color: kcPrimaryLight, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Update Profile Photo',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Choose a preset avatar or paste an image URL:',
                      style: GoogleFonts.inter(
                        color: kcTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Preset Avatars
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: presetAvatars.map((preset) {
                          final isSelected = textController.text == preset['url'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                setDialogState(() {
                                  textController.text = preset['url']!;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? kcPrimaryColor : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(preset['url']!),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Custom URL Input
                    _buildFieldLabel('Photo URL'),
                    TextFormField(
                      controller: textController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                      decoration: _buildInputDecoration(
                        hintText: 'https://...',
                        prefixIcon: Icons.link,
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        if (viewModel.currentUser?.profileImage != null &&
                            viewModel.currentUser!.profileImage!.isNotEmpty)
                          TextButton.icon(
                            icon: const Icon(Icons.delete_outline, color: kcDanger, size: 16),
                            label: Text(
                              'Remove',
                              style: GoogleFonts.inter(color: kcDanger, fontSize: 13),
                            ),
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              await viewModel.removeProfileImage();
                            },
                          ),
                        const Spacer(),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Color(0xFF334155)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kcPrimaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            final url = textController.text.trim();
                            Navigator.of(ctx).pop();
                            if (url.isNotEmpty) {
                              await viewModel.updateProfileImage(url);
                            }
                          },
                          child: Text(
                            'Save Photo',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
