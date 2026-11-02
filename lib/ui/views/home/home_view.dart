import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../../models/company_model.dart';
import '../../../models/credentials_model.dart';
import '../../../models/company_user_model.dart';
import '../../../models/plan_model.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  void onViewModelReady(HomeViewModel viewModel) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.init();
    });
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 700 && size.width < 1024;
    final isMobile = size.width < 700;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        if (viewModel.scaffoldKey.currentState?.isDrawerOpen == true) {
          viewModel.scaffoldKey.currentState?.closeDrawer();
          return;
        }

        final shouldClose = await _confirmCloseApp(context, viewModel);
        if (shouldClose == true) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        key: viewModel.scaffoldKey,
        backgroundColor: const Color(0xFF0F172A),
        drawer: !isDesktop ? _buildDrawer(context, viewModel) : null,
        appBar: _buildTopAppBar(context, viewModel, isDesktop, isMobile),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Desktop Persistent Sidebar
          if (isDesktop) _buildDesktopSidebar(context, viewModel),

          // Main Dynamic Content Area
          Expanded(
            child: Container(
              color: const Color(0xFF0F172A),
              child: viewModel.isBusy && viewModel.metrics == null
                  ? const Center(
                      child: CircularProgressIndicator(color: kcPrimaryColor),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await viewModel.refreshAll();
                      },
                      color: kcPrimaryColor,
                      backgroundColor: const Color(0xFF1E293B),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(isMobile ? 14 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (viewModel.errorMessage != null)
                              _buildGlobalErrorBanner(viewModel),

                            if (viewModel.activeTab == 'dashboard')
                              _buildDashboardTab(context, viewModel, isDesktop, isTablet, isMobile)
                            else if (viewModel.activeTab == 'companies')
                              _buildCompaniesTab(context, viewModel, isDesktop, isMobile)
                            else if (viewModel.activeTab == 'plans')
                              _buildPlansTab(context, viewModel, isDesktop, isTablet, isMobile),

                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // -------------------------------------------------------------
  // TOP APP BAR
  // -------------------------------------------------------------
  PreferredSizeWidget _buildTopAppBar(
    BuildContext context,
    HomeViewModel viewModel,
    bool isDesktop,
    bool isMobile,
  ) {
    return AppBar(
      backgroundColor: const Color(0xFF1E293B),
      elevation: 0,
      centerTitle: false,
      leading: !isDesktop
          ? Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Icon(
                viewModel.activeTab == 'dashboard'
                    ? Icons.dashboard_rounded
                    : viewModel.activeTab == 'companies'
                        ? Icons.domain_rounded
                        : Icons.layers_rounded,
                color: kcPrimaryLight,
                size: 26,
              ),
            ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMobile && viewModel.activeTab != 'dashboard') ...[
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => viewModel.setActiveTab('dashboard'),
              child: Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 16, color: kcPrimaryLight),
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  viewModel.activeTab == 'dashboard'
                      ? 'Super Admin Dashboard'
                      : viewModel.activeTab == 'companies'
                          ? 'Registered Companies'
                          : 'Subscription Plans',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (!isMobile)
                  Text(
                    'AQUA_USER Central Main Admin Panel • Marina Aqua Multi-Tenant Ecosystem',
                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // System Online Pulse Badge
        if (!isMobile)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kcSuccess.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kcSuccess.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kcSuccess,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Multi-Tenant API Live',
                  style: GoogleFonts.inter(
                    color: kcSuccess,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // Refresh Button
        IconButton(
          tooltip: 'Refresh Data',
          icon: viewModel.isBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: kcPrimaryLight),
                )
              : const Icon(Icons.refresh_rounded, color: Colors.white70),
          onPressed: viewModel.isBusy
              ? null
              : () async {
                  await viewModel.refreshAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dashboard and records refreshed successfully.'),
                        backgroundColor: kcSuccess,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
        ),

        // Super Admin Profile Chip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: kcPrimaryColor,
                child: Text(
                  viewModel.currentUser?.name.isNotEmpty == true
                      ? viewModel.currentUser!.name[0].toUpperCase()
                      : 'A',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      viewModel.currentUser?.name ?? 'Super Admin',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'super_admin',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: kcPrimaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Logout
        IconButton(
          tooltip: 'Logout',
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          onPressed: () => _confirmLogout(context, viewModel),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // -------------------------------------------------------------
  // DESKTOP SIDEBAR
  // -------------------------------------------------------------
  Widget _buildDesktopSidebar(BuildContext context, HomeViewModel viewModel) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1.2)),
      ),
      child: Column(
        children: [
          // Sidebar Logo Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kcPrimaryColor, kcIndigoColor]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AQUA USER',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'MAIN ADMIN PANEL',
                      style: GoogleFonts.inter(
                        color: kcPrimaryLight,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Nav Items
          _buildSidebarNavItem(
            icon: Icons.dashboard_rounded,
            title: 'Overview',
            tabKey: 'dashboard',
            isActive: viewModel.activeTab == 'dashboard',
            onTap: () => viewModel.setActiveTab('dashboard'),
          ),
          _buildSidebarNavItem(
            icon: Icons.domain_rounded,
            title: 'Companies',
            tabKey: 'companies',
            isActive: viewModel.activeTab == 'companies',
            badge: '${viewModel.metrics?.totalCompanies ?? viewModel.companies.length}',
            onTap: () => viewModel.setActiveTab('companies'),
          ),
          _buildSidebarNavItem(
            icon: Icons.layers_rounded,
            title: 'Subscription Plans',
            tabKey: 'plans',
            isActive: viewModel.activeTab == 'plans',
            badge: '${viewModel.metrics?.activePlans ?? viewModel.plans.length}',
            onTap: () => viewModel.setActiveTab('plans'),
          ),

          const Spacer(),

          // System Stats Footer
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security_rounded, size: 16, color: kcSuccess),
                    const SizedBox(width: 8),
                    Text(
                      'Tenant Isolation',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Multi-tenant authorization is active. Data is strictly separated by Company ID.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              tileColor: Colors.red.withValues(alpha: 0.08),
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
              title: const Text(
                'Logout Session',
                style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              onTap: () => _confirmLogout(context, viewModel),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              tileColor: Colors.white.withValues(alpha: 0.05),
              leading: const Icon(Icons.power_settings_new_rounded, color: Colors.white70, size: 20),
              title: const Text(
                'Exit Application',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              onTap: () async {
                Navigator.pop(context); // close drawer
                final shouldClose = await _confirmCloseApp(context, viewModel);
                if (shouldClose == true) {
                  await SystemNavigator.pop();
                }
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required IconData icon,
    required String title,
    required String tabKey,
    required bool isActive,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? kcPrimaryColor.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? kcPrimaryColor.withValues(alpha: 0.35) : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          dense: true,
          leading: Icon(
            icon,
            color: isActive ? kcPrimaryLight : const Color(0xFF94A3B8),
            size: 20,
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              color: isActive ? Colors.white : const Color(0xFF94A3B8),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          trailing: badge != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? kcPrimaryColor : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // MOBILE DRAWER
  // -------------------------------------------------------------
  Widget _buildDrawer(BuildContext context, HomeViewModel viewModel) {
    return Drawer(
      backgroundColor: const Color(0xFF111827),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kcPrimaryColor, kcIndigoColor]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AQUA USER',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1E293B)),
            _buildSidebarNavItem(
              icon: Icons.dashboard_rounded,
              title: 'Overview',
              tabKey: 'dashboard',
              isActive: viewModel.activeTab == 'dashboard',
              onTap: () {
                viewModel.setActiveTab('dashboard');
              },
            ),
            _buildSidebarNavItem(
              icon: Icons.domain_rounded,
              title: 'Companies',
              tabKey: 'companies',
              isActive: viewModel.activeTab == 'companies',
              badge: '${viewModel.metrics?.totalCompanies ?? viewModel.companies.length}',
              onTap: () {
                viewModel.setActiveTab('companies');
              },
            ),
            _buildSidebarNavItem(
              icon: Icons.layers_rounded,
              title: 'Subscription Plans',
              tabKey: 'plans',
              isActive: viewModel.activeTab == 'plans',
              badge: '${viewModel.metrics?.activePlans ?? viewModel.plans.length}',
              onTap: () {
                viewModel.setActiveTab('plans');
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                _confirmLogout(context, viewModel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.power_settings_new_rounded, color: Colors.white70),
              title: const Text('Exit Application', style: TextStyle(color: Colors.white70)),
              onTap: () async {
                final shouldClose = await _confirmCloseApp(context, viewModel);
                if (shouldClose == true) {
                  await SystemNavigator.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: DASHBOARD OVERVIEW
  // -------------------------------------------------------------
  Widget _buildDashboardTab(
    BuildContext context,
    HomeViewModel viewModel,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {

    final m = viewModel.metrics;
    final totalComp = m?.totalCompanies ?? 0;
    final activeComp = m?.activeCompanies ?? 0;
    final inactiveComp = m?.inactiveCompanies ?? 0;
    final totalUsers = m?.totalRegisteredUsers ?? 0;
    final activePlans = m?.activePlans ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Banner & Quick Action Buttons
        Container(
          padding: EdgeInsets.all(isMobile ? 18 : 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF334155)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, Super Admin 👋',
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 20 : 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'All company registrations, company admin accounts, and plan management occur exclusively within AQUA_USER.',
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 12 : 14,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_business_rounded, size: 18),
                  label: Text('Create Company', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showCreateCompanyDialog(context, viewModel),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 5 KPI Metric Cards (Requirement 1)
        Text(
          'PLATFORM METRICS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = isDesktop
                ? (constraints.maxWidth - (4 * 16)) / 5
                : isTablet
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildKpiCard(
                  title: 'Total Companies',
                  value: '$totalComp',
                  subtitle: 'Registered tenants',
                  icon: Icons.domain_rounded,
                  accentColor: kcPrimaryColor,
                  width: cardWidth,
                ),
                _buildKpiCard(
                  title: 'Active Companies',
                  value: '$activeComp',
                  subtitle: 'Live & operating',
                  icon: Icons.check_circle_rounded,
                  accentColor: kcSuccess,
                  width: cardWidth,
                ),
                _buildKpiCard(
                  title: 'Inactive Companies',
                  value: '$inactiveComp',
                  subtitle: 'Suspended / blocked',
                  icon: Icons.pause_circle_filled_rounded,
                  accentColor: kcWarning,
                  width: cardWidth,
                ),
                _buildKpiCard(
                  title: 'Registered Users',
                  value: '$totalUsers',
                  subtitle: 'Across all companies',
                  icon: Icons.people_alt_rounded,
                  accentColor: kcIndigoColor,
                  width: cardWidth,
                ),
                _buildKpiCard(
                  title: 'Active Plans',
                  value: '$activePlans',
                  subtitle: 'Available tiers',
                  icon: Icons.layers_rounded,
                  accentColor: const Color(0xFF0D9488),
                  width: cardWidth,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 32),

        // Recent Companies Section
        if (isMobile)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'RECENT COMPANIES',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => viewModel.setActiveTab('companies'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.inter(
                        color: kcPrimaryLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: kcPrimaryLight),
                  ],
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT COMPANIES',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: const Color(0xFF64748B),
                ),
              ),
              TextButton.icon(
                onPressed: () => viewModel.setActiveTab('companies'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: kcPrimaryLight),
                label: Text(
                  'View All Companies',
                  style: GoogleFonts.inter(color: kcPrimaryLight, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),

        _buildCompaniesTable(
          context,
          viewModel,
          viewModel.metrics?.recentCompanies ?? viewModel.companies,
          isMobile,
          limit: 6,
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: COMPANIES MANAGEMENT
  // -------------------------------------------------------------
  Widget _buildCompaniesTab(
    BuildContext context,
    HomeViewModel viewModel,
    bool isDesktop,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Controls Row
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            children: [
              if (isMobile) ...[
                TextField(
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search companies by name, ID, or email...',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  ),
                  onChanged: viewModel.setSearchQuery,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_business_rounded, size: 18),
                    label: Text(
                      'Create New Company',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _showCreateCompanyDialog(context, viewModel),
                  ),
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search companies by name, company ID (CMP-XXXX), or admin email...',
                          hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          isDense: true,
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
                            borderSide: const BorderSide(color: kcPrimaryColor, width: 1.5),
                          ),
                        ),
                        onChanged: viewModel.setSearchQuery,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_business_rounded, size: 18),
                      label: Text(
                        'Create Company',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showCreateCompanyDialog(context, viewModel),
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              // Filter Chips (Horizontally Scrollable on Mobile to prevent RenderFlex overflow)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildStatusFilterChip(viewModel, 'all', 'All Companies'),
                    const SizedBox(width: 8),
                    _buildStatusFilterChip(viewModel, 'active', 'Active Only'),
                    const SizedBox(width: 8),
                    _buildStatusFilterChip(viewModel, 'inactive', 'Inactive Only'),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        await viewModel.fetchCompanies();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Companies list refreshed.'),
                              backgroundColor: kcSuccess,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text(
                              'Refresh',
                              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _buildCompaniesTable(context, viewModel, viewModel.companies, isMobile),
      ],
    );
  }

  Widget _buildStatusFilterChip(HomeViewModel viewModel, String statusKey, String label) {
    final isSelected = viewModel.selectedStatus == statusKey;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
        ),
      ),
      selected: isSelected,
      selectedColor: kcPrimaryColor,
      backgroundColor: const Color(0xFF0F172A),
      onSelected: (_) => viewModel.setStatusFilter(statusKey),
    );
  }

  Widget _buildCompaniesTable(
    BuildContext context,
    HomeViewModel viewModel,
    List<CompanyModel> companies,
    bool isMobile, {
    int? limit,
  }) {
    final displayList = limit != null && companies.length > limit
        ? companies.sublist(0, limit)
        : companies;

    if (displayList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.domain_disabled_rounded, size: 54, color: Color(0xFF64748B)),
              const SizedBox(height: 12),
              Text(
                'No Companies Found',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Create a company to generate its unique Company ID, assign an admin, and issue login credentials.',
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Responsive Mobile Card View to avoid horizontal overflow & table squishing
    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final c = displayList[index];
          return _buildMobileCompanyCard(context, viewModel, c);
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            horizontalMargin: 20,
            columnSpacing: 24,
            headingRowColor: WidgetStateProperty.all(const Color(0xFF111827)),
            headingTextStyle: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            dataTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            columns: const [
              DataColumn(label: Text('COMPANY ID')),
              DataColumn(label: Text('COMPANY NAME')),
              DataColumn(label: Text('ADMIN EMAIL')),
              DataColumn(label: Text('PLAN')),
              DataColumn(label: Text('USERS / LIMIT')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('ACTIONS')),
            ],
            rows: displayList.map((c) {
              return DataRow(
                cells: [
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kcPrimaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kcPrimaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        c.companyCode,
                        style: GoogleFonts.outfit(
                          color: kcPrimaryLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          c.name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        if (c.phone != null && c.phone!.isNotEmpty)
                          Text(
                            c.phone!,
                            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                          ),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      c.adminEmail,
                      style: GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        c.planName,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFA5B4FC),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    InkWell(
                      onTap: () => _showCompanyUsersDialog(context, viewModel, c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (c.usersCount >= c.maxUsers && c.maxUsers > 0
                                  ? Colors.red
                                  : kcPrimaryColor)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 14,
                              color: c.usersCount >= c.maxUsers && c.maxUsers > 0
                                  ? Colors.redAccent
                                  : kcPrimaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${c.usersCount} / ${c.maxUsers}',
                              style: GoogleFonts.inter(
                                color: c.usersCount >= c.maxUsers && c.maxUsers > 0
                                    ? Colors.redAccent
                                    : const Color(0xFFE2E8F0),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Switch(
                      value: c.isActive,
                      activeColor: kcSuccess,
                      inactiveThumbColor: Colors.grey,
                      onChanged: (_) => viewModel.toggleCompanyStatus(c),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Manage Users (${c.usersCount}/${c.maxUsers})',
                          icon: const Icon(Icons.people_alt_rounded, size: 18, color: kcPrimaryLight),
                          onPressed: () => _showCompanyUsersDialog(context, viewModel, c),
                        ),
                        IconButton(
                          tooltip: 'Edit Company',
                          icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF94A3B8)),
                          onPressed: () => _showEditCompanyDialog(context, viewModel, c),
                        ),
                        IconButton(
                          tooltip: 'Delete Company (Permanent DB Purge)',
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                          onPressed: () => _showDeleteCompanyDialog(context, viewModel, c),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCompanyCard(
    BuildContext context,
    HomeViewModel viewModel,
    CompanyModel c,
  ) {
    final isLimitReached = c.usersCount >= c.maxUsers && c.maxUsers > 0;
    final remainingSlots = (c.maxUsers - c.usersCount).clamp(0, 9999);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLimitReached ? Colors.red.withValues(alpha: 0.3) : const Color(0xFF334155),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Code + Status Switch + Edit + Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kcPrimaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kcPrimaryColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  c.companyCode,
                  style: GoogleFonts.outfit(
                    color: kcPrimaryLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: c.isActive,
                    activeColor: kcSuccess,
                    inactiveThumbColor: Colors.grey,
                    onChanged: (_) => viewModel.toggleCompanyStatus(c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF94A3B8)),
                    tooltip: 'Edit Company',
                    onPressed: () => _showEditCompanyDialog(context, viewModel, c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                    tooltip: 'Delete Company',
                    onPressed: () => _showDeleteCompanyDialog(context, viewModel, c),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Company Name & Info
          Text(
            c.name,
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  c.adminEmail,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1)),
                ),
              ),
            ],
          ),
          if (c.phone != null && c.phone!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(
                  c.phone!,
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),

          // Plan & User Limit Box (Requirement 2 & 6)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        c.planName,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA5B4FC),
                        ),
                      ),
                    ),
                    Text(
                      '${c.usersCount} / ${c.maxUsers} Users',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isLimitReached ? Colors.redAccent : kcPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: c.maxUsers > 0 ? (c.usersCount / c.maxUsers).clamp(0.0, 1.0) : 0,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF1E293B),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isLimitReached ? Colors.redAccent : kcPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      isLimitReached ? Icons.lock_outline_rounded : Icons.check_circle_outline_rounded,
                      size: 13,
                      color: isLimitReached ? Colors.redAccent : const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isLimitReached
                            ? 'Plan limit reached • Upgrade to add users'
                            : '$remainingSlots user slots available to login in Marina Aqua',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isLimitReached ? Colors.redAccent : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // User Management Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.people_alt_rounded, size: 16),
                  label: Text('Manage Users (${c.usersCount})'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kcPrimaryLight,
                    side: const BorderSide(color: Color(0xFF475569)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showCompanyUsersDialog(context, viewModel, c),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLimitReached ? Colors.grey.shade700 : kcPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (isLimitReached) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Plan limit of ${c.maxUsers} users reached for ${c.name}. Please edit company and upgrade plan to create more users.',
                        ),
                        backgroundColor: Colors.amber.shade900,
                      ),
                    );
                  } else {
                    _showAddCompanyUserDialog(context, viewModel, c);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: PLANS MANAGEMENT
  // -------------------------------------------------------------
  Widget _buildPlansTab(
    BuildContext context,
    HomeViewModel viewModel,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Plan Catalog & User Limits',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Only Super Admin can manage subscription tiers and user limits.',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('New Plan', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showCreatePlanDialog(context, viewModel),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Catalog & User Limits',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Only Super Admin can manage subscription tiers and user limits.',
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('New Plan', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showCreatePlanDialog(context, viewModel),
              ),
            ],
          ),
        const SizedBox(height: 24),

        // Plans Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = isDesktop
                ? (constraints.maxWidth - 32) / 3
                : isTablet
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: viewModel.plans.map((plan) {
                return Container(
                  width: cardWidth,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: plan.isActive ? const Color(0xFF334155) : Colors.red.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: kcIndigoColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                plan.name,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFA5B4FC),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: plan.isActive
                                  ? kcSuccess.withValues(alpha: 0.15)
                                  : Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              plan.isActive ? 'ACTIVE' : 'INACTIVE',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: plan.isActive ? kcSuccess : Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹${NumberFormat('#,##,##0').format(plan.price)}',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '/ ${plan.duration}',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (plan.description != null && plan.description!.isNotEmpty)
                        Text(
                          plan.description!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFFCBD5E1),
                            height: 1.4,
                          ),
                        ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFF334155)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.people_outline, size: 18, color: kcPrimaryLight),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Max ${plan.maxUsers} Users Allowed',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.domain_rounded, size: 18, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${plan.companiesCount} Active Companies Assigned',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF475569)),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _showEditPlanDialog(context, viewModel, plan),
                              child: const Text('Edit Plan'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: plan.isActive ? 'Deactivate' : 'Activate',
                            icon: Icon(
                              plan.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                              size: 28,
                              color: plan.isActive ? kcSuccess : Colors.grey,
                            ),
                            onPressed: () => viewModel.togglePlanStatus(plan),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // DIALOGS: CREATE COMPANY (Requirement 2)
  // -------------------------------------------------------------
  void _showCreateCompanyDialog(BuildContext context, HomeViewModel viewModel) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    int? selectedPlanId = viewModel.plans.isNotEmpty ? viewModel.plans.first.id : null;
    String selectedStatus = 'active';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final isMobileDialog = MediaQuery.of(ctx).size.width < 500;

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            actionsOverflowButtonSpacing: 8,
            actionsAlignment: MainAxisAlignment.end,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kcPrimaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_business_rounded, color: kcPrimaryLight, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Create New Company',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: isMobileDialog ? 18 : 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SizedBox(
                  width: isMobileDialog ? double.maxFinite : 460,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Company Name *',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
                      ),
                      const SizedBox(height: 6),
                      _buildDarkTextField(nameCtrl, 'e.g. Apex Pure Water Ltd.', Icons.business),
                      const SizedBox(height: 14),

                      Text(
                        'Company Admin Email *',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
                      ),
                      const SizedBox(height: 6),
                      _buildDarkTextField(emailCtrl, 'admin@company.com', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 14),

                      if (isMobileDialog) ...[
                        Text(
                          'Admin Password *',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
                        ),
                        const SizedBox(height: 6),
                        _buildDarkTextField(passCtrl, 'Min 6 characters', Icons.lock_outline, obscureText: true),
                        const SizedBox(height: 14),

                        Text(
                          'Confirm Password *',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
                        ),
                        const SizedBox(height: 6),
                        _buildDarkTextField(confirmPassCtrl, 'Re-enter password', Icons.lock_outline, obscureText: true),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admin Password *',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
                                  ),
                                  const SizedBox(height: 6),
                                  _buildDarkTextField(passCtrl, 'Min 6 characters', Icons.lock_outline, obscureText: true),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Confirm Password *',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
                                  ),
                                  const SizedBox(height: 6),
                                  _buildDarkTextField(confirmPassCtrl, 'Re-enter password', Icons.lock_outline, obscureText: true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 14),

                      Text(
                        'Select Plan *',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: viewModel.plans.any((p) => p.id == selectedPlanId)
                            ? selectedPlanId
                            : (viewModel.plans.isNotEmpty ? viewModel.plans.first.id : null),
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E293B),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                        ),
                        items: viewModel.plans.map((p) {
                          return DropdownMenuItem<int>(
                            value: p.id,
                            child: Text(
                              '${p.name} (Max ${p.maxUsers} Users - ₹${p.price.toInt()})',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        selectedItemBuilder: (BuildContext context) {
                          return viewModel.plans.map<Widget>((p) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${p.name} (Max ${p.maxUsers} Users - ₹${p.price.toInt()})',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                              ),
                            );
                          }).toList();
                        },
                        onChanged: (val) {
                          if (val != null) setState(() => selectedPlanId = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      if (isMobileDialog) ...[
                        Text(
                          'Account Status',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E293B),
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'active', child: Text('Active')),
                            DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => selectedStatus = val);
                          },
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Phone Number',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
                        ),
                        const SizedBox(height: 6),
                        _buildDarkTextField(phoneCtrl, '+91 98765 00000', Icons.phone_outlined, keyboardType: TextInputType.phone),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account Status',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: selectedStatus,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF1E293B),
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFF0F172A),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'active', child: Text('Active')),
                                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => selectedStatus = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Phone Number',
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
                                  ),
                                  const SizedBox(height: 6),
                                  _buildDarkTextField(phoneCtrl, '+91 98765 00000', Icons.phone_outlined, keyboardType: TextInputType.phone),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 14),

                      Text(
                        'Company Address',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
                      ),
                      const SizedBox(height: 6),
                      _buildDarkTextField(addressCtrl, 'Street, City, State, PIN', Icons.location_on_outlined),
                    ],
                  ),
                ),
              ),
            ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kcPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final email = emailCtrl.text.trim();
                final pass = passCtrl.text;
                final confirm = confirmPassCtrl.text;

                if (name.isEmpty || email.isEmpty || pass.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields.')),
                  );
                  return;
                }

                if (pass != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match.')),
                  );
                  return;
                }

                if (pass.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password must be at least 6 characters.')),
                  );
                  return;
                }

                if (selectedPlanId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a plan.')),
                  );
                  return;
                }

                final creds = await viewModel.createCompany(
                  name: name,
                  adminEmail: email,
                  adminPassword: pass,
                  planId: selectedPlanId!,
                  status: selectedStatus,
                  phone: phoneCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                );

                if (creds != null && ctx.mounted) {
                  Navigator.pop(ctx);
                  // Open Credentials Dialog with Copy option!
                  _showGeneratedCredentialsDialog(context, viewModel, creds);
                } else if (viewModel.errorMessage != null && ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(viewModel.errorMessage!),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              },
              child: const Text('Create Company & Admin'),
            ),
          ],
        );
      },
    ),
  );
}

  // -------------------------------------------------------------
  // DIALOG: GENERATED CREDENTIALS (Requirement 2)
  // Display:
  // - Company Name
  // - Company ID
  // - Admin User ID
  // - Admin Email
  // - Temporary Password
  // - Assigned Plan
  // - Copy credentials option
  // -------------------------------------------------------------
  void _showGeneratedCredentialsDialog(
    BuildContext context,
    HomeViewModel viewModel,
    CredentialsModel creds,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: kcSuccess, width: 1.5),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kcSuccess.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: kcSuccess, size: 36),
            ),
            const SizedBox(height: 12),
            Text(
              'Company Registered Successfully!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'The company admin account is ready. Copy or record these login credentials.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width < 500 ? double.maxFinite : 460,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCredentialRow('Company Name', creds.companyName, isBold: true),
                  const Divider(color: Color(0xFF334155)),
                  _buildCredentialRow('Company ID', creds.companyId, highlight: true),
                  const Divider(color: Color(0xFF334155)),
                  _buildCredentialRow('Admin User ID', '#${creds.adminUserId}'),
                  const Divider(color: Color(0xFF334155)),
                  _buildCredentialRow('Admin Email', creds.adminEmail),
                  const Divider(color: Color(0xFF334155)),
                  _buildCredentialRow('Temporary Password', creds.temporaryPassword, isSecret: true),
                  const Divider(color: Color(0xFF334155)),
                  _buildCredentialRow('Assigned Plan', '${creds.assignedPlan} (Max ${creds.maxUsers} Users)'),
                ],
              ),
            ),
          ),
        ),
        actionsOverflowButtonSpacing: 8,
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copy Credentials'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kcPrimaryColor),
              foregroundColor: kcPrimaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {
              viewModel.copyCredentials(creds);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Company admin credentials copied to clipboard!'),
                  backgroundColor: kcSuccess,
                ),
              );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kcPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(
    String label,
    String value, {
    bool isBold = false,
    bool highlight = false,
    bool isSecret = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isBold || highlight ? FontWeight.w700 : FontWeight.w600,
                color: highlight
                    ? kcPrimaryLight
                    : isSecret
                        ? const Color(0xFFFBBF24)
                        : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // DIALOG: EDIT COMPANY
  // -------------------------------------------------------------
  void _showEditCompanyDialog(BuildContext context, HomeViewModel viewModel, CompanyModel company) {
    final nameCtrl = TextEditingController(text: company.name);
    final phoneCtrl = TextEditingController(text: company.phone ?? '');
    final addressCtrl = TextEditingController(text: company.address ?? '');
    int selectedPlanId = company.planId ?? (viewModel.plans.isNotEmpty ? viewModel.plans.first.id : 1);
    String selectedStatus = company.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final isMobileDialog = MediaQuery.of(ctx).size.width < 500;

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            actionsOverflowButtonSpacing: 8,
            actionsAlignment: MainAxisAlignment.end,
            title: Text(
              'Edit Company (${company.companyCode})',
              style: GoogleFonts.outfit(
                fontSize: isMobileDialog ? 18 : 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SizedBox(
                  width: isMobileDialog ? double.maxFinite : 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Company Name *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                      const SizedBox(height: 6),
                      _buildDarkTextField(nameCtrl, 'Company Name', Icons.business),
                      const SizedBox(height: 14),

                      Text('Subscription Plan *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: viewModel.plans.any((p) => p.id == selectedPlanId)
                            ? selectedPlanId
                            : (viewModel.plans.isNotEmpty ? viewModel.plans.first.id : null),
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E293B),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: viewModel.plans.map((p) {
                          return DropdownMenuItem<int>(
                            value: p.id,
                            child: Text(
                              '${p.name} (Max ${p.maxUsers} Users)',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        selectedItemBuilder: (BuildContext context) {
                          return viewModel.plans.map<Widget>((p) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${p.name} (Max ${p.maxUsers} Users)',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                              ),
                            );
                          }).toList();
                        },
                        onChanged: (val) {
                          if (val != null) setState(() => selectedPlanId = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      Text('Status', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E293B),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => selectedStatus = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      Text('Phone', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                      const SizedBox(height: 6),
                      _buildDarkTextField(phoneCtrl, 'Phone', Icons.phone),
                      const SizedBox(height: 14),

                      Text('Address', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                      const SizedBox(height: 6),
                      _buildDarkTextField(addressCtrl, 'Address', Icons.location_on),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kcPrimaryColor, foregroundColor: Colors.white),
                onPressed: () async {
                  final success = await viewModel.updateCompany(
                    company.id,
                    name: nameCtrl.text.trim(),
                    planId: selectedPlanId,
                    status: selectedStatus,
                    phone: phoneCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                  );
                  if (success && ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Company updated successfully.'), backgroundColor: kcSuccess),
                    );
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // DIALOG: DELETE COMPANY (Double Confirmation & DB Purge)
  // -------------------------------------------------------------
  void _showDeleteCompanyDialog(BuildContext context, HomeViewModel viewModel, CompanyModel company) {
    bool confirmedRisk = false;
    final confirmTextCtrl = TextEditingController();
    bool isDeleting = false;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final expectedCode = company.companyCode.trim().toUpperCase();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final typedText = confirmTextCtrl.text.trim().toUpperCase();
          final isCodeMatched = typedText == expectedCode || typedText == 'DELETE';
          final canDelete = confirmedRisk && isCodeMatched && !isDeleting;

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Delete Company',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF8FAFC),
                    ),
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? screenWidth * 0.95 : 500,
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You are about to permanently delete:',
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${company.name} (${company.companyCode})',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Warning card detailing database purge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Permanent Database Purge Action',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This action CANNOT be undone. Deleting this company will permanently erase all associated data from the database, including:',
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1), height: 1.4),
                          ),
                          const SizedBox(height: 6),
                          ...[
                            'All Company Users, logins & active session tokens',
                            'Company settings & business profile',
                            'All Invoices, payments, credit notes & transactions',
                            'All Products, categories, units, tax rates & inventory adjustments',
                            'All Purchases, suppliers & purchase items',
                            'All Dealers, dealer supplies, payments & ledgers',
                          ].map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirmation Step 1: Risk checkbox
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: confirmedRisk ? const Color(0xFFEF4444) : const Color(0xFF334155),
                        ),
                      ),
                      child: CheckboxListTile(
                        value: confirmedRisk,
                        activeColor: const Color(0xFFEF4444),
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        title: Text(
                          'Step 1: I understand that this action is irreversible and all database records for this company will be wiped clean.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: confirmedRisk ? const Color(0xFFF8FAFC) : const Color(0xFF94A3B8),
                          ),
                        ),
                        onChanged: isDeleting
                            ? null
                            : (val) {
                                setState(() {
                                  confirmedRisk = val ?? false;
                                });
                              },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Confirmation Step 2: Type company code or DELETE
                    Text(
                      'Step 2: Type "${company.companyCode}" or "DELETE" to confirm:',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: confirmTextCtrl,
                      enabled: !isDeleting,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        hintText: 'Enter ${company.companyCode} or DELETE',
                        hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF334155)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isCodeMatched ? const Color(0xFF10B981) : const Color(0xFF334155),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isCodeMatched ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  disabledBackgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white38,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.delete_forever_rounded, size: 18),
                label: Text(
                  isDeleting ? 'Purging Company Data...' : 'Permanently Delete Company',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                onPressed: canDelete
                    ? () async {
                        setState(() => isDeleting = true);
                        final success = await viewModel.deleteCompany(company);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Company "${company.name}" and all associated data have been permanently purged from the database.'),
                                backgroundColor: const Color(0xFF10B981),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(viewModel.errorMessage ?? 'Failed to delete company.'),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                          }
                        }
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // DIALOGS: CREATE / EDIT PLAN (Requirement 6)
  // -------------------------------------------------------------
  void _showCreatePlanDialog(BuildContext context, HomeViewModel viewModel) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '1999');
    final durationCtrl = TextEditingController(text: '30 Days');
    final maxUsersCtrl = TextEditingController(text: '10');
    String selectedStatus = 'active';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final isMobileDialog = MediaQuery.of(ctx).size.width < 500;

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            actionsOverflowButtonSpacing: 8,
            actionsAlignment: MainAxisAlignment.end,
            title: Text(
              'Create Subscription Plan',
              style: GoogleFonts.outfit(
                fontSize: isMobileDialog ? 18 : 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SizedBox(
                  width: isMobileDialog ? double.maxFinite : 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Plan Name *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                      const SizedBox(height: 6),
                      _buildDarkTextField(nameCtrl, 'e.g. Platinum Tier', Icons.layers),
                      const SizedBox(height: 12),

                      Text('Description', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                      const SizedBox(height: 6),
                      _buildDarkTextField(descCtrl, 'Plan highlights...', Icons.description),
                      const SizedBox(height: 12),

                      if (isMobileDialog) ...[
                        Text('Price (₹) *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                        const SizedBox(height: 6),
                        _buildDarkTextField(priceCtrl, '1999', Icons.currency_rupee, keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        Text('Duration *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                        const SizedBox(height: 6),
                        _buildDarkTextField(durationCtrl, '30 Days', Icons.calendar_today),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Price (₹) *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                                  const SizedBox(height: 6),
                                  _buildDarkTextField(priceCtrl, '1999', Icons.currency_rupee, keyboardType: TextInputType.number),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Duration *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                                  const SizedBox(height: 6),
                                  _buildDarkTextField(durationCtrl, '30 Days', Icons.calendar_today),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),

                      if (isMobileDialog) ...[
                        Text('Max Staff Users *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                        const SizedBox(height: 6),
                        _buildDarkTextField(maxUsersCtrl, '10', Icons.people, keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        Text('Status', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E293B),
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'active', child: Text('Active')),
                            DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => selectedStatus = val);
                          },
                        ),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Max Staff Users *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                                  const SizedBox(height: 6),
                                  _buildDarkTextField(maxUsersCtrl, '10', Icons.people, keyboardType: TextInputType.number),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Status', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: selectedStatus,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF1E293B),
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFF0F172A),
                                      isDense: true,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'active', child: Text('Active')),
                                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => selectedStatus = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kcPrimaryColor, foregroundColor: Colors.white),
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text) ?? 0.0;
                  final duration = durationCtrl.text.trim();
                  final maxUsers = int.tryParse(maxUsersCtrl.text) ?? 5;

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a plan name.')),
                    );
                    return;
                  }

                  final success = await viewModel.createPlan(
                    name: name,
                    description: descCtrl.text.trim(),
                    price: price,
                    duration: duration,
                    maxUsers: maxUsers,
                    status: selectedStatus,
                  );

                  if (success && ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Plan created successfully.'), backgroundColor: kcSuccess),
                    );
                  }
                },
                child: const Text('Create Plan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditPlanDialog(BuildContext context, HomeViewModel viewModel, PlanModel plan) {
    final nameCtrl = TextEditingController(text: plan.name);
    final descCtrl = TextEditingController(text: plan.description ?? '');
    final priceCtrl = TextEditingController(text: plan.price.toStringAsFixed(0));
    final durationCtrl = TextEditingController(text: plan.duration);
    final maxUsersCtrl = TextEditingController(text: plan.maxUsers.toString());
    String selectedStatus = plan.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final isMobileDialog = MediaQuery.of(ctx).size.width < 500;

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            actionsOverflowButtonSpacing: 8,
            actionsAlignment: MainAxisAlignment.end,
            title: Text(
              'Edit Plan',
              style: GoogleFonts.outfit(
                fontSize: isMobileDialog ? 18 : 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SizedBox(
                  width: isMobileDialog ? double.maxFinite : 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Plan Name *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                      const SizedBox(height: 6),
                      _buildDarkTextField(nameCtrl, 'Plan Name', Icons.layers),
                      const SizedBox(height: 12),

                      Text('Description', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                      const SizedBox(height: 6),
                      _buildDarkTextField(descCtrl, 'Description', Icons.description),
                      const SizedBox(height: 12),

                      if (isMobileDialog) ...[
                        Text('Price (₹) *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                        const SizedBox(height: 6),
                        _buildDarkTextField(priceCtrl, '1999', Icons.currency_rupee, keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        Text('Duration *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                        const SizedBox(height: 6),
                        _buildDarkTextField(durationCtrl, '30 Days', Icons.calendar_today),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Price (₹) *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                                  const SizedBox(height: 6),
                                  _buildDarkTextField(priceCtrl, '1999', Icons.currency_rupee, keyboardType: TextInputType.number),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Duration *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                                  const SizedBox(height: 6),
                                  _buildDarkTextField(durationCtrl, '30 Days', Icons.calendar_today),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),

                      if (isMobileDialog) ...[
                        Text('Max Staff Users *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                        const SizedBox(height: 6),
                        _buildDarkTextField(maxUsersCtrl, '10', Icons.people, keyboardType: TextInputType.number),
                        const SizedBox(height: 12),
                        Text('Status', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E293B),
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'active', child: Text('Active')),
                            DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => selectedStatus = val);
                          },
                        ),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Max Staff Users *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                                  const SizedBox(height: 6),
                                  _buildDarkTextField(maxUsersCtrl, '10', Icons.people, keyboardType: TextInputType.number),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Status', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: selectedStatus,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF1E293B),
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFF0F172A),
                                      isDense: true,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'active', child: Text('Active')),
                                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => selectedStatus = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kcPrimaryColor, foregroundColor: Colors.white),
                onPressed: () async {
                  final success = await viewModel.updatePlan(
                    plan.id,
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    price: double.tryParse(priceCtrl.text) ?? plan.price,
                    duration: durationCtrl.text.trim(),
                    maxUsers: int.tryParse(maxUsersCtrl.text) ?? plan.maxUsers,
                    status: selectedStatus,
                  );

                  if (success && ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Plan updated successfully.'), backgroundColor: kcSuccess),
                    );
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // COMPANY USERS MANAGEMENT & CREATION (Enforcing Plan Limits)
  // Users created here can log into the marina_aqua application!
  // -------------------------------------------------------------
  void _showCompanyUsersDialog(
    BuildContext context,
    HomeViewModel viewModel,
    CompanyModel company,
  ) {
    viewModel.loadCompanyUsers(company.id);

    showDialog(
      context: context,
      builder: (dialogCtx) => ListenableBuilder(
        listenable: viewModel,
        builder: (ctx, _) {
          final isMobile = MediaQuery.of(ctx).size.width < 600;
          final liveCompany = viewModel.companies.firstWhere(
            (c) => c.id == company.id,
            orElse: () => company,
          );
          final maxUsers = liveCompany.maxUsers;
          final currentUsers = viewModel.selectedCompanyUsers;
          final isLimitReached = currentUsers.length >= maxUsers && maxUsers > 0;
          final remainingSlots = (maxUsers - currentUsers.length).clamp(0, 9999);

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            actionsPadding: const EdgeInsets.all(16),
            actionsOverflowButtonSpacing: 8,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kcPrimaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.people_alt_rounded, color: kcPrimaryLight, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        liveCompany.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ID: ${liveCompany.companyCode} • Plan: ${liveCompany.planName}',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: isMobile ? double.maxFinite : 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan user limit indicator banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isLimitReached
                              ? Colors.red.withValues(alpha: 0.4)
                              : const Color(0xFF334155),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Plan User Limit:',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                              Text(
                                '${currentUsers.length} / $maxUsers Users',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isLimitReached ? Colors.redAccent : kcPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: maxUsers > 0 ? (currentUsers.length / maxUsers).clamp(0.0, 1.0) : 0,
                              minHeight: 8,
                              backgroundColor: const Color(0xFF1E293B),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isLimitReached ? Colors.redAccent : kcPrimaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                isLimitReached ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                                size: 14,
                                color: isLimitReached ? Colors.redAccent : const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  isLimitReached
                                      ? 'Plan limit reached. Upgrade company plan to create more users.'
                                      : '$remainingSlots user slots remaining under ${liveCompany.planName}.',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: isLimitReached ? Colors.redAccent : const Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Add user button and header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Company Users (${currentUsers.length})',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person_add_rounded, size: 16),
                          label: const Text('Add User'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLimitReached ? Colors.grey.shade700 : kcPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: isLimitReached
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Plan limit of $maxUsers users reached! Please edit company and upgrade plan to allow more users.',
                                      ),
                                      backgroundColor: Colors.amber.shade900,
                                    ),
                                  );
                                }
                              : () => _showAddCompanyUserDialog(context, viewModel, liveCompany),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Users list
                    if (viewModel.loadingCompanyUsers)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: kcPrimaryColor),
                              SizedBox(height: 12),
                              Text('Loading company users...', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                            ],
                          ),
                        ),
                      )
                    else if (viewModel.errorMessage != null && currentUsers.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 36, color: Colors.redAccent),
                            const SizedBox(height: 8),
                            Text(
                              viewModel.errorMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(fontSize: 13, color: Colors.redAccent),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: kcPrimaryColor),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Retry'),
                              onPressed: () => viewModel.loadCompanyUsers(company.id),
                            ),
                          ],
                        ),
                      )
                    else if (currentUsers.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.people_outline_rounded, size: 36, color: Color(0xFF64748B)),
                            const SizedBox(height: 8),
                            Text(
                              'No additional users registered yet.',
                              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: currentUsers.map((u) {
                          final isPrimaryAdmin = u.role == 'admin';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isPrimaryAdmin
                                        ? kcPrimaryColor.withValues(alpha: 0.2)
                                        : const Color(0xFF6366F1).withValues(alpha: 0.2),
                                    child: Icon(
                                      isPrimaryAdmin ? Icons.admin_panel_settings : Icons.person_rounded,
                                      size: 18,
                                      color: isPrimaryAdmin ? kcPrimaryLight : const Color(0xFFA5B4FC),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                u.name,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isPrimaryAdmin
                                                    ? kcPrimaryColor.withValues(alpha: 0.2)
                                                    : const Color(0xFF334155),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                u.role == 'sales_rep' ? 'STAFF / SALES' : u.role.toUpperCase(),
                                                style: GoogleFonts.inter(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: isPrimaryAdmin ? kcPrimaryLight : const Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          u.email,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                                        ),
                                        Text(
                                          'Can login to Marina Aqua application',
                                          style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF10B981)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: u.isActive,
                                    activeColor: kcSuccess,
                                    inactiveThumbColor: Colors.grey,
                                    onChanged: (_) async {
                                      await viewModel.toggleCompanyUserStatus(company.id, u.id);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_note_rounded, size: 20, color: Color(0xFF60A5FA)),
                                    tooltip: 'Edit User & Change Password/Email',
                                    onPressed: () => _showEditCompanyUserDialog(context, viewModel, liveCompany, u),
                                  ),
                                  if (!isPrimaryAdmin)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                      tooltip: 'Delete User',
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (c) => AlertDialog(
                                            backgroundColor: const Color(0xFF1E293B),
                                            title: const Text('Delete User?'),
                                            content: Text('Are you sure you want to delete ${u.name}?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                onPressed: () => Navigator.pop(c, true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await viewModel.deleteCompanyUser(company.id, u.id);
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Close', style: GoogleFonts.inter(color: Colors.white70)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddCompanyUserDialog(
    BuildContext context,
    HomeViewModel viewModel,
    CompanyModel company,
  ) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String selectedRole = 'sales_rep';
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final isMobile = MediaQuery.of(ctx).size.width < 600;

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
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
                  child: const Icon(Icons.person_add_rounded, color: kcPrimaryLight, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add User for ${company.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Allowed by Plan: ${company.usersCount}/${company.maxUsers} Users',
                        style: GoogleFonts.inter(fontSize: 11, color: kcPrimaryLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? MediaQuery.of(ctx).size.width * 0.95 : 460,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF10B981)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This user will be able to log into the Marina Aqua mobile/web application with these credentials.',
                              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFCBD5E1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text('Full Name *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    _buildDarkTextField(nameCtrl, 'e.g. John Doe', Icons.person_outline),
                    const SizedBox(height: 12),

                    Text('Email Address (Login ID) *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    _buildDarkTextField(emailCtrl, 'user@company.com', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),

                    Text('Password *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    _buildDarkTextField(passCtrl, 'Min 6 characters', Icons.lock_outline, obscureText: true),
                    const SizedBox(height: 12),

                    Text('Role *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E293B),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'sales_rep', child: Text('Sales Representative / Staff', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'manager', child: Text('Branch Manager', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'accountant', child: Text('Accountant', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'admin', child: Text('Co-Admin', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => selectedRole = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    Text('Phone (Optional)', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    _buildDarkTextField(phoneCtrl, '+91 98765 43210', Icons.phone_outlined, keyboardType: TextInputType.phone),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white70)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final name = nameCtrl.text.trim();
                        final email = emailCtrl.text.trim();
                        final pass = passCtrl.text;

                        if (name.isEmpty || email.isEmpty || pass.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all required fields.')),
                          );
                          return;
                        }

                        setState(() => isSubmitting = true);
                        final res = await viewModel.createCompanyUser(
                          companyId: company.id,
                          name: name,
                          email: email,
                          password: pass,
                          role: selectedRole,
                          phone: phoneCtrl.text.trim(),
                        );
                        if (ctx.mounted) setState(() => isSubmitting = false);

                        if (res != null && ctx.mounted) {
                          Navigator.pop(ctx);
                          final credsMap = res['credentials'] as Map<String, dynamic>? ?? {};
                          _showGeneratedUserCredentialsDialog(context, viewModel, credsMap);
                        } else if (viewModel.errorMessage != null && ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(viewModel.errorMessage!),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Create User'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditCompanyUserDialog(
    BuildContext context,
    HomeViewModel viewModel,
    CompanyModel company,
    CompanyUserModel user,
  ) {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final passCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: user.phone ?? '');
    String selectedRole = ['sales_rep', 'manager', 'accountant', 'admin'].contains(user.role)
        ? user.role
        : 'sales_rep';
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final isMobile = MediaQuery.of(ctx).size.width < 600;

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF60A5FA).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.manage_accounts_rounded, color: Color(0xFF60A5FA), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit User: ${user.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${company.name} (${company.companyCode})',
                        style: GoogleFonts.inter(fontSize: 11, color: kcPrimaryLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? MediaQuery.of(ctx).size.width * 0.95 : 460,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.security_rounded, size: 16, color: Color(0xFF60A5FA)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Update email ID, reset login password, or change assigned permissions for this company user.',
                              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFCBD5E1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text('Full Name *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    _buildDarkTextField(nameCtrl, 'Full Name', Icons.person_outline),
                    const SizedBox(height: 12),

                    Text('Email Address (Login ID) *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    _buildDarkTextField(emailCtrl, 'user@company.com', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Change Password', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1))),
                        Text(
                          '(Leave blank to keep current)',
                          style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildDarkTextField(
                      passCtrl,
                      'Enter new password (min 6 chars)',
                      Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),

                    Text('Confirm New Password', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    _buildDarkTextField(
                      confirmPassCtrl,
                      'Re-enter new password to verify',
                      Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),

                    Text('Role *', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E293B),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'sales_rep', child: Text('Sales Representative / Staff', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'manager', child: Text('Branch Manager', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'accountant', child: Text('Accountant', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'admin', child: Text('Co-Admin', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => selectedRole = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    Text('Phone (Optional)', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1))),
                    const SizedBox(height: 6),
                    _buildDarkTextField(phoneCtrl, '+91 98765 43210', Icons.phone_outlined, keyboardType: TextInputType.phone),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white70)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final name = nameCtrl.text.trim();
                        final email = emailCtrl.text.trim();
                        final newPassword = passCtrl.text;
                        final confirmPassword = confirmPassCtrl.text;

                        if (name.isEmpty || email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Name and Email are required.')),
                          );
                          return;
                        }

                        if (newPassword.isNotEmpty) {
                          if (newPassword.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('New password must be at least 6 characters long.')),
                            );
                            return;
                          }
                          if (newPassword != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Passwords do not match. Please verify.')),
                            );
                            return;
                          }
                        }

                        setState(() => isSubmitting = true);
                        final res = await viewModel.updateCompanyUser(
                          companyId: company.id,
                          userId: user.id,
                          name: name,
                          email: email,
                          password: newPassword.isNotEmpty ? newPassword : null,
                          role: selectedRole,
                          phone: phoneCtrl.text.trim(),
                        );
                        if (ctx.mounted) setState(() => isSubmitting = false);

                        if (res != null && ctx.mounted) {
                          Navigator.pop(ctx);
                          final passwordChanged = res['password_changed'] as bool? ?? false;
                          final credsMap = res['credentials'] as Map<String, dynamic>?;

                          if (passwordChanged && credsMap != null) {
                            _showGeneratedUserCredentialsDialog(context, viewModel, credsMap);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('User "${user.name}" updated successfully.'),
                                backgroundColor: kcSuccess,
                              ),
                            );
                          }
                        } else if (viewModel.errorMessage != null && ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(viewModel.errorMessage!),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void showGeneratedUserCredentialsDialog(
    BuildContext context,
    HomeViewModel viewModel,
    Map<String, dynamic> creds,
  ) => _showGeneratedUserCredentialsDialog(context, viewModel, creds);

  void _showGeneratedUserCredentialsDialog(
    BuildContext context,
    HomeViewModel viewModel,
    Map<String, dynamic> creds,
  ) {
    final companyName = creds['company_name']?.toString() ?? '';
    final companyCode = creds['company_id']?.toString() ?? '';
    final name = creds['name']?.toString() ?? '';
    final email = creds['email']?.toString() ?? '';
    final password = creds['password']?.toString() ?? '';
    final role = creds['role']?.toString() ?? 'staff';

    final formattedText = '''
========================================
   MARINA AQUA - USER CREDENTIALS
========================================
Company Name: $companyName ($companyCode)
User Name   : $name
Email / ID  : $email
Password    : $password
Role        : $role
Application : Marina Aqua (Mobile / Web)
========================================
''';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: kcSuccess, width: 1.5),
        ),
        actionsOverflowButtonSpacing: 8,
        actionsAlignment: MainAxisAlignment.end,
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kcSuccess.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: kcSuccess, size: 36),
            ),
            const SizedBox(height: 12),
            Text(
              'User Created Successfully!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'This user can now login at the Marina Aqua application.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF10B981), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width < 500 ? double.maxFinite : 460,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCredentialRow('Company', '$companyName ($companyCode)', isBold: true),
                  const Divider(color: Color(0xFF334155)),
                  _buildCredentialRow('Full Name', name),
                  const Divider(color: Color(0xFF334155)),
                  _buildCredentialRow('Email (Login ID)', email, highlight: true),
                  const Divider(color: Color(0xFF334155)),
                  _buildCredentialRow('Password', password, isSecret: true),
                  const Divider(color: Color(0xFF334155)),
                  _buildCredentialRow('Role', role.toUpperCase()),
                  const Divider(color: Color(0xFF334155)),
                  _buildCredentialRow('Login App', 'Marina Aqua Application', highlight: true),
                ],
              ),
            ),
          ),
        ),
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copy Credentials'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kcPrimaryColor),
              foregroundColor: kcPrimaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {
              viewModel.copyText(formattedText);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User login credentials copied to clipboard!'),
                  backgroundColor: kcSuccess,
                ),
              );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kcPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // HELPER WIDGETS
  // -------------------------------------------------------------
  Widget _buildDarkTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kcPrimaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildGlobalErrorBanner(HomeViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kcDanger.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kcDanger.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: kcDanger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              viewModel.errorMessage!,
              style: GoogleFonts.inter(color: const Color(0xFFFCA5A5), fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.white70),
            onPressed: () => viewModel.refreshAll(),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, HomeViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Confirm Sign Out',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to log out of the Super Administrator Portal?',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your session token will be cleared and you will be returned to the sign-in screen.',
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8), height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white70)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Yes, Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              await viewModel.logout();
            },
          ),
        ],
      ),
    );
  }

  Future<bool> confirmCloseApp(BuildContext context, HomeViewModel viewModel) =>
      _confirmCloseApp(context, viewModel);

  Future<bool> _confirmCloseApp(BuildContext context, HomeViewModel viewModel) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        actionsOverflowButtonSpacing: 8,
        actionsAlignment: MainAxisAlignment.end,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.power_settings_new_rounded, color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Exit Application',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to close and exit the application?',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Any unsaved work will be discarded. You can reopen the portal anytime.',
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8), height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white70)),
          ),
          if (viewModel.activeTab != 'dashboard')
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kcPrimaryColor),
                foregroundColor: kcPrimaryLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              icon: const Icon(Icons.dashboard_rounded, size: 16),
              label: const Text('Back to Home'),
              onPressed: () {
                Navigator.pop(ctx, false);
                viewModel.setActiveTab('dashboard');
              },
            ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.exit_to_app_rounded, size: 18),
            label: const Text('Close App', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
