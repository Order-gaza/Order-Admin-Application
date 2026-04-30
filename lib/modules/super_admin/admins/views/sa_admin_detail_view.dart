import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../data/providers/api_provider.dart';

class SaAdminDetailView extends StatefulWidget {
  final String adminId;
  final String adminName;

  const SaAdminDetailView({
    super.key,
    required this.adminId,
    required this.adminName,
  });

  @override
  State<SaAdminDetailView> createState() => _SaAdminDetailViewState();
}

class _SaAdminDetailViewState extends State<SaAdminDetailView> {
  bool _loading = true;
  Map<String, dynamic> _admin = {};
  Map<String, dynamic> _stats = {};
  List<dynamic> _sessions = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await ApiProvider.post(ApiEndpoints.saAdminsGetById,
          body: {'admin_id': widget.adminId});
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        setState(() {
          _admin = d['admin'] ?? {};
          _stats = d['stats'] ?? {};
          _sessions = d['sessions'] ?? [];
        });
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primaryOrange))
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Stats Cards ──
                        _statsRow(),
                        const SizedBox(height: 20),

                        // ── Contact Info ──
                        _sectionTitle('Contact Information'.tr),
                        const SizedBox(height: 10),
                        _infoCard([
                          _infoRow(
                              Icons.person, 'Name'.tr, _admin['name'] ?? '—'),
                          _infoRow(Icons.email, 'Email'.tr,
                              _admin['email'] ?? '—',
                              copyable: true),
                          _infoRow(Icons.phone, 'Phone'.tr,
                              _admin['phone'] ?? '—',
                              copyable: true),
                        ]),
                        const SizedBox(height: 20),

                        // ── Recent Login Sessions ──
                        _sectionTitle(
                            'Active / Recent Sessions'.tr + ' (${_sessions.length})'),
                        const SizedBox(height: 10),
                        if (_sessions.isEmpty)
                          _card(
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  children: [
                                    Icon(Icons.security,
                                        size: 36,
                                        color: Colors.white
                                            .withValues(alpha: 0.2)),
                                    const SizedBox(height: 8),
                                    Text('No recent sessions'.tr,
                                        style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.4),
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ..._sessions.map((s) => _sessionCard(s)),
                        const SizedBox(height: 20),

                        // ── System Info ──
                        _sectionTitle('System Info'.tr),
                        const SizedBox(height: 10),
                        _infoCard([
                          _infoRow(Icons.fingerprint, 'Admin ID'.tr,
                              _admin['id']?.toString() ?? '—',
                              copyable: true),
                          _infoRow(Icons.calendar_today, 'Registered'.tr,
                              _admin['created_at'] ?? '—'),
                          _infoRow(Icons.update, 'Updated'.tr,
                              _admin['updated_at'] ?? '—'),
                        ]),
                        const SizedBox(height: 24),

                        // ── Actions ──
                        _actionsSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  SliverAppBar _buildAppBar() {
    final isActive = _admin['is_active'] == true || _admin['is_active'] == 1;
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.charcoalBlack,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.charcoalBlack, Color(0xFF2C2C2C)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isActive
                        ? [AppColors.primaryOrange, AppColors.darkOrange]
                        : [AppColors.textSecondary, const Color(0xFF555555)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    (_admin['name'] ?? widget.adminName)[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _admin['name'] ?? widget.adminName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: (isActive ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'Active'.tr : 'Inactive'.tr,
                  style: TextStyle(
                      color: isActive ? AppColors.success : AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _fetch,
        ),
      ],
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        _statCard('Admin'.tr,
          'Role'.tr,
          AppColors.primaryOrange,
        ),
        const SizedBox(width: 10),
        _statCard('${_stats['total_recorded_logins'] ?? 0}',
          'Total Logins'.tr,
          AppColors.info,
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.7), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _sessionCard(dynamic session) {
    final isExpired = session['is_expired'] == true;
    final color = isExpired ? AppColors.textSecondary : AppColors.success;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.computer, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session['ip_address'] ?? 'Unknown IP'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(session['user_agent'] ?? 'Unknown Device'.tr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text('Logged in:'.tr + ' ${session['created_at']}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                Text('Expires:'.tr + ' ${session['expires_at']}',
                    style: TextStyle(
                        color: isExpired
                            ? AppColors.error
                            : AppColors.textSecondary,
                        fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isExpired ? 'Expired'.tr : 'Active'.tr,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionsSection() {
    final isActive = _admin['is_active'] == true || _admin['is_active'] == 1;
    final phone = _admin['phone']?.toString() ?? '';
    return Column(
      children: [
        // ── Call Admin Button ──
        if (phone.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse('tel:$phone')),
                icon: const Icon(Icons.phone, color: Colors.white),
                label: Text('Call Admin'.tr,
                    style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final res = await ApiProvider.post(
                ApiEndpoints.saAdminsToggle,
                body: {'admin_id': widget.adminId},
              );
              if (res.success) {
                Get.snackbar('Success'.tr, res.message?.tr ?? 'Status updated'.tr,
                    backgroundColor: const Color(0xFF4CAF50),
                    colorText: const Color(0xFFFFFFFF));
                _fetch();
              } else {
                Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed'.tr,
                    backgroundColor: const Color(0xFFF44336),
                    colorText: const Color(0xFFFFFFFF));
              }
            },
            icon: Icon(
              isActive ? Icons.block : Icons.check_circle_outline,
              color: isActive ? AppColors.warning : AppColors.success,
            ),
            label: Text(
              isActive ? 'Deactivate Admin'.tr : 'Activate Admin'.tr,
              style: TextStyle(
                  color: isActive ? AppColors.warning : AppColors.success),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: isActive ? AppColors.warning : AppColors.success),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmDeleteFromDetail(),
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            label: Text('Delete Admin'.tr,
                style: const TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDeleteFromDetail() {
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Text('Delete Admin'.tr, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete "%s"?'.tr.replaceFirst('%s', _admin['name'] ?? ''),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This action is irreversible and the admin will be completely removed.'.tr,
                    style: const TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () async {
            Get.back();
            final res = await ApiProvider.post(
              ApiEndpoints.saAdminsDelete,
              body: {'admin_id': widget.adminId},
            );
            if (res.success) {
              Get.snackbar('Done'.tr, res.message?.tr ?? 'Admin removed'.tr,
                  backgroundColor: const Color(0xFF4CAF50),
                  colorText: const Color(0xFFFFFFFF));
              Get.back(result: true);
            } else {
              Get.snackbar('Error'.tr, res.message?.tr ?? 'Failed to remove'.tr,
                  backgroundColor: const Color(0xFFF44336),
                  colorText: const Color(0xFFFFFFFF));
            }
          },
          child: Text('Delete'.tr),
        ),
      ],
    ));
  }

  // ── Helpers ──

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600));
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }

  Widget _infoCard(List<Widget> rows) {
    return _card(
      child: Column(
        children: rows
            .expand((r) => [
                  r,
                  if (r != rows.last)
                    Divider(
                        height: 20,
                        color: AppColors.divider.withValues(alpha: 0.2))
                ])
            .toList(),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {bool copyable = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ),
        if (copyable)
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              Get.snackbar('Copied'.tr, '$label ' + 'copied'.tr,
                  backgroundColor: AppColors.cardDark,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 1));
            },
            icon: const Icon(Icons.copy, size: 14, color: AppColors.textSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            splashRadius: 14,
          ),
      ],
    );
  }
}
