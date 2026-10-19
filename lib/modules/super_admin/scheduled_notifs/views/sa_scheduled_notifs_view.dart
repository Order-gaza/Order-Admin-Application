import 'package:flutter/material.dart';
import '../../../../app/constants/api_endpoints.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/localization/app_translations.dart';
import '../../../../shared/utils/app_navigator.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../data/providers/api_provider.dart';

class SaScheduledNotifsView extends StatefulWidget {
  const SaScheduledNotifsView({super.key});
  @override
  State<SaScheduledNotifsView> createState() => _SaScheduledNotifsViewState();
}

class _SaScheduledNotifsViewState extends State<SaScheduledNotifsView> {
  bool _isLoading = true;
  bool _isSavingConfig = false;

  // Config
  bool _isActive = false;
  String _frequency = 'daily';
  int _sendHour = 12;
  String? _lastSentAt;

  // Messages pool
  List<Map<String, dynamic>> _messages = [];
  int _activeMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    final res = await ApiProvider.get(ApiEndpoints.saScheduledNotifsGetConfig);
    if (res.success && res.data != null) {
      final cfg = res.data['config'];
      if (mounted) {
        setState(() {
          _isActive = cfg['is_active'] == true || cfg['is_active'] == 1;
          _frequency = cfg['frequency'] ?? 'daily';
          _sendHour = (cfg['send_hour'] ?? 12) as int;
          _lastSentAt = cfg['last_sent_at'];
          _messages = List<Map<String, dynamic>>.from(res.data['messages'] ?? []);
          _activeMessageCount = (res.data['active_message_count'] ?? 0) as int;
        });
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    setState(() => _isSavingConfig = true);
    final res = await ApiProvider.post(ApiEndpoints.saScheduledNotifsUpdateConfig, body: {
      'is_active': _isActive ? '1' : '0',
      'frequency': _frequency,
      'send_hour': _sendHour.toString(),
    });
    if (mounted) {
      setState(() => _isSavingConfig = false);
    }

    if (res.success) {
      AppNavigator.snackbar('Success'.tr, 'Settings saved ✓'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withValues(alpha: 0.9),
          colorText: Colors.white, margin: const EdgeInsets.all(12));
    } else {
      AppNavigator.snackbar('Error'.tr, res.message ?? 'Failed to save'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          colorText: Colors.white, margin: const EdgeInsets.all(12));
    }
  }

  Future<void> _addMessage() async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Add Message'.tr, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'Title'.tr),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(hintText: 'Body'.tr),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.tr)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Add'.tr),
          ),
        ],
      ),
    );

    if (result != true) return;
    if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) return;

    final res = await ApiProvider.post(ApiEndpoints.saScheduledNotifsAddMessage, body: {
      'title': titleCtrl.text.trim(),
      'body': bodyCtrl.text.trim(),
    });

    if (res.success) {
      _loadConfig();
      AppNavigator.snackbar('Success'.tr, 'Message added ✓'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withValues(alpha: 0.9),
          colorText: Colors.white, margin: const EdgeInsets.all(12));
    }
  }

  Future<void> _editMessage(Map<String, dynamic> msg) async {
    final titleCtrl = TextEditingController(text: msg['title']);
    final bodyCtrl = TextEditingController(text: msg['body']);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Edit Message'.tr, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'Title'.tr),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(hintText: 'Body'.tr),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.tr)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Save'.tr),
          ),
        ],
      ),
    );

    if (result != true) return;

    final res = await ApiProvider.post(ApiEndpoints.saScheduledNotifsUpdateMessage, body: {
      'id': msg['id'].toString(),
      'title': titleCtrl.text.trim(),
      'body': bodyCtrl.text.trim(),
    });

    if (res.success) _loadConfig();
  }

  Future<void> _deleteMessage(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Delete Message'.tr, style: const TextStyle(color: Colors.white)),
        content: Text('Are you sure?'.tr, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.tr)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Delete'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final res = await ApiProvider.post(ApiEndpoints.saScheduledNotifsDeleteMessage, body: {'id': id});
    if (res.success) _loadConfig();
  }

  Future<void> _toggleMessage(Map<String, dynamic> msg) async {
    final newActive = !(msg['is_active'] == true || msg['is_active'] == 1);
    await ApiProvider.post(ApiEndpoints.saScheduledNotifsUpdateMessage, body: {
      'id': msg['id'].toString(),
      'is_active': newActive ? '1' : '0',
    });
    _loadConfig();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        title: Text('Scheduled Notifications'.tr),
        actions: [
          _isSavingConfig
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(color: AppColors.primaryOrange, strokeWidth: 2)))
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveConfig,
                  tooltip: 'Save Settings'.tr,
                ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.saScheduledNotifs),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
          : RefreshIndicator(
              onRefresh: _loadConfig,
              color: AppColors.primaryOrange,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Add multiple messages to the pool. The system will rotate them automatically so users never see the same message twice in a row.'.tr,
                              style: const TextStyle(color: AppColors.warning, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Active Toggle ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Scheduled Sending'.tr,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                _isActive ? 'Active'.tr : 'Disabled'.tr,
                                style: TextStyle(
                                  color: _isActive ? AppColors.success : AppColors.error,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isActive,
                            onChanged: (v) {
                              setState(() => _isActive = v);
                              _saveConfig();
                            },
                            activeThumbColor: AppColors.primaryOrange,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Frequency ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Frequency'.tr,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _frequency,
                            dropdownColor: AppColors.cardDark,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.repeat),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                            items: [
                              DropdownMenuItem(value: 'daily', child: Text('Every Day'.tr)),
                              DropdownMenuItem(value: 'every_2_days', child: Text('Every 2 Days'.tr)),
                              DropdownMenuItem(value: 'every_3_days', child: Text('Every 3 Days'.tr)),
                              DropdownMenuItem(value: 'weekly', child: Text('Once a Week'.tr)),
                            ],
                            onChanged: (v) => setState(() => _frequency = v!),
                          ),
                          const SizedBox(height: 16),
                          Text('Send Time'.tr,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            initialValue: _sendHour,
                            dropdownColor: AppColors.cardDark,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.schedule),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                            items: List.generate(24, (h) {
                              final label = h == 0
                                  ? '12:00 AM'
                                  : h < 12
                                      ? '$h:00 AM'
                                      : h == 12
                                          ? '12:00 PM'
                                          : '${h - 12}:00 PM';
                              return DropdownMenuItem(value: h, child: Text(label));
                            }),
                            onChanged: (v) => setState(() => _sendHour = v!),
                          ),
                          if (_lastSentAt != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                                const SizedBox(width: 6),
                                Text('Last sent: $_lastSentAt',
                                    style: const TextStyle(color: AppColors.success, fontSize: 12)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Save config button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSavingConfig ? null : _saveConfig,
                        icon: _isSavingConfig
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save),
                        label: Text(_isSavingConfig ? 'Saving...'.tr : 'Save Settings'.tr),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Message Pool ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Message Pool'.tr,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('$_activeMessageCount ${'active'.tr}',
                            style: const TextStyle(color: AppColors.primaryOrange, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_messages.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.inbox, color: AppColors.textSecondary, size: 40),
                            const SizedBox(height: 8),
                            Text('No messages yet'.tr,
                                style: const TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text('Add at least one message to start scheduled sending'.tr,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      )
                    else
                      ...List.generate(_messages.length, (i) {
                        final msg = _messages[i];
                        final active = msg['is_active'] == true || msg['is_active'] == 1;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(12),
                            border: active
                                ? null
                                : Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(msg['title'] ?? '',
                                        style: TextStyle(
                                          color: active ? Colors.white : AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        )),
                                  ),
                                  if (!active)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('Disabled'.tr,
                                          style: const TextStyle(color: AppColors.error, fontSize: 10)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(msg['body'] ?? '',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('Used ${msg['times_used'] ?? 0}x',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      active ? Icons.toggle_on : Icons.toggle_off,
                                      color: active ? AppColors.success : AppColors.textSecondary,
                                      size: 28,
                                    ),
                                    onPressed: () => _toggleMessage(msg),
                                    tooltip: active ? 'Disable'.tr : 'Enable'.tr,
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: AppColors.info, size: 20),
                                    onPressed: () => _editMessage(msg),
                                    tooltip: 'Edit'.tr,
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                    onPressed: () => _deleteMessage(msg['id'].toString()),
                                    tooltip: 'Delete'.tr,
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 12),

                    // Add message button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addMessage,
                        icon: const Icon(Icons.add),
                        label: Text('Add New Message'.tr),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primaryOrange),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
