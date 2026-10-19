import 'package:flutter/material.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/providers/api_provider.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';

class SaNotificationsView extends StatefulWidget {
  const SaNotificationsView({super.key});
  @override
  State<SaNotificationsView> createState() => _SaNotificationsViewState();
}

class _SaNotificationsViewState extends State<SaNotificationsView> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  String _mode = 'all'; // 'all' or 'selected'
  bool _isSending = false;
  bool _isSearching = false;

  List<Map<String, dynamic>> _customers = [];
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchCustomers(String query) async {
    setState(() => _isSearching = true);
    final res = await ApiProvider.get(
      ApiEndpoints.saCustomersGetAll,
      queryParams: {'search': query, 'limit': '50'},
    );
    if (res.success && res.data != null) {
      setState(() {
        _customers =
            List<Map<String, dynamic>>.from(res.data['customers'] ?? []);
      });
    }
    setState(() => _isSearching = false);
  }

  Future<void> _send() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isEmpty || body.isEmpty) {
      AppNavigator.snackbar('Error'.tr, 'Title and body are required'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12));
      return;
    }

    if (_mode == 'selected' && _selectedIds.isEmpty) {
      AppNavigator.snackbar('Error'.tr, 'Please select at least one customer'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12));
      return;
    }

    final recipientText = _mode == 'all'
        ? 'all customers'.tr
        : '${_selectedIds.length} ${'selected customers'.tr}';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Confirm Send'.tr,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          '${'Send notification to'.tr} $recipientText?\n\n${'Title'.tr}: $title',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel'.tr)),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Send'.tr)),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSending = true);

    final reqBody = <String, String>{
      'title': title,
      'body': body,
      'mode': _mode,
    };

    if (_mode == 'selected') {
      reqBody['user_ids'] = _selectedIds.toList().join(',');
    }

    final res =
        await ApiProvider.post(ApiEndpoints.saNotificationsSend, body: reqBody);

    setState(() => _isSending = false);

    if (res.success) {
      final count = res.data?['sent_count'] ?? 0;
      _titleCtrl.clear();
      _bodyCtrl.clear();
      _selectedIds.clear();
      AppNavigator.snackbar('Success'.tr, '${'Sent to'.tr} $count ${'customers'.tr} ✓',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withValues(alpha: 0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message ?? 'Failed to send'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(title: Text('Send Notification'.tr)),
      drawer: const AppDrawer(currentRoute: AppRoutes.saNotifications),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.campaign, color: AppColors.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Send promotional notifications to your customers. They will receive both a push notification and an in-app notification.'
                          .tr,
                      style:
                          const TextStyle(color: AppColors.info, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Title
            _label('Notification Title'.tr),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.white),
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'e.g. Special Offer! 🎉'.tr,
                prefixIcon: const Icon(Icons.title),
                counterStyle: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),

            // Body
            _label('Notification Body'.tr),
            TextField(
              controller: _bodyCtrl,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'e.g. Order now and get 20% off with code SAVE20'.tr,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.message),
                ),
                counterStyle: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),

            // Recipient mode
            _label('Recipients'.tr),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text('All Customers (Broadcast)'.tr,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text('Send to every active customer'.tr,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    value: 'all',
                    groupValue: _mode,
                    activeColor: AppColors.primaryOrange,
                    onChanged: (v) => setState(() => _mode = v!),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  RadioListTile<String>(
                    title: Text('Selected Customers'.tr,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text('Search and pick specific customers'.tr,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    value: 'selected',
                    groupValue: _mode,
                    activeColor: AppColors.primaryOrange,
                    onChanged: (v) {
                      setState(() => _mode = v!);
                      if (_customers.isEmpty) _searchCustomers('');
                    },
                  ),
                ],
              ),
            ),

            // Customer picker (only in selected mode)
            if (_mode == 'selected') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name, email, or phone...'.tr,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryOrange)))
                      : null,
                ),
                onChanged: (v) => _searchCustomers(v),
              ),
              if (_selectedIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_selectedIds.length} ${'selected'.tr}',
                    style: const TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _customers.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            _searchCtrl.text.isEmpty
                                ? 'Search for customers above'.tr
                                : 'No customers found'.tr,
                            style:
                                const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _customers.length,
                        separatorBuilder: (_, __) =>
                            const Divider(color: AppColors.divider, height: 1),
                        itemBuilder: (ctx, i) {
                          final c = _customers[i];
                          final id = c['id'].toString();
                          final selected = _selectedIds.contains(id);
                          return CheckboxListTile(
                            value: selected,
                            activeColor: AppColors.primaryOrange,
                            title: Text(c['name'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            subtitle: Text(
                              '${c['email'] ?? ''} • ${c['phone'] ?? ''}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12),
                            ),
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _selectedIds.add(id);
                                } else {
                                  _selectedIds.remove(id);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
            ],

            const SizedBox(height: 32),

            // Send button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _send,
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label:
                    Text(_isSending ? 'Sending...'.tr : 'Send Notification'.tr),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),

            const SizedBox(height: 16),

            // Link to scheduled notifications
            Center(
              child: TextButton.icon(
                onPressed: () => AppNavigator.toNamed(AppRoutes.saScheduledNotifs),
                icon: const Icon(Icons.schedule, size: 18),
                label: Text('Manage Scheduled Notifications'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      );
}
