import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/contact.dart';
import '../models/channel.dart';
import '../models/session.dart';
import '../theme.dart';
import '../widgets/hover_card.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key, this.onOpenWebex});

  /// Called when the user taps "Browse all Webex" — parent switches to the
  /// Webex bottom-nav tab.
  final VoidCallback? onOpenWebex;

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  List<Contact> _contacts = const [];
  List<Channel> _channels = const [];
  List<Session> _sessions = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final contacts = await ApiService.instance.getContacts();
      final channels = await ApiService.instance.getChannels();
      final sessions =
          await ApiService.instance.getSessions(sortByMatch: true);
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _channels = channels;
        _sessions = sessions;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('ForYouScreen load failed: $e\n$st');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final topChannels = _channels.take(3).toList();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _recommendedHeader(),
        const SizedBox(height: 12),
        _sectionHeader(
          title: 'People to Meet',
          subtitle: 'Cisco experts and fellow attendees aligned with your interests',
        ),
        const SizedBox(height: 8),
        ..._contacts.map(_personCard),
        const SizedBox(height: 12),
        _sectionHeader(
          title: 'Webex',
          subtitle: 'Sponsored topic channels for networking and collaboration',
        ),
        const SizedBox(height: 8),
        ...topChannels.map(_channelCard),
        const SizedBox(height: 8),
        _browseAllWebexButton(),
        const SizedBox(height: 12),
        _sectionHeader(
          title: 'Sessions',
          subtitle: 'Powered by MCP session data and your goals',
        ),
        const SizedBox(height: 8),
        ..._sessions.map(_sessionCard),
      ],
    );
  }

  Widget _recommendedHeader() {
    return HoverCard(
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recommended For You',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Sessions, people, and Webex channels matched to your goals · ${_contacts.length} contacts near you',
            style: const TextStyle(color: AppTheme.muted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.headerBg,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({required String title, required String subtitle}) {
    return HoverCard(
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: AppTheme.muted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _personCard(Contact c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HoverCard(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (c.badge != null) _pill(c.badge!, _badgeColor(c.badge)),
                      if (c.distanceMeters != null)
                        _pill('Near you · ${c.distanceMeters}m',
                            const Color(0xFFD9F1FA), fg: AppTheme.primary),
                    ],
                  ),
                ),
                if (c.matchPercent != null)
                  Text('${c.matchPercent}% match',
                      style: TextStyle(
                          color: _matchColor(c.matchPercent!),
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Text(c.name,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('${c.title} · ${c.company}',
                style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
            if (c.description != null) ...[
              const SizedBox(height: 8),
              Text(c.description!,
                  style: const TextStyle(color: Colors.black87)),
            ],
            const SizedBox(height: 12),
            const Text('CURRENT LOCATION',
                style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
            Text(c.currentLocation ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (c.alignmentText != null) ...[
              const SizedBox(height: 6),
              Text(c.alignmentText!,
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontStyle: FontStyle.italic,
                      fontSize: 12)),
            ],
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final saved =
                        await ApiService.instance.toggleSaveContact(c.id);
                    if (!mounted) return;
                    setState(() => c.saved = saved);
                    messenger.showSnackBar(SnackBar(
                        content: Text(saved ? 'Saved' : 'Removed')));
                  },
                  child: Text(c.saved ? 'Saved' : 'Save Contact'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await ApiService.instance.scheduleMeeting(c.id);
                    if (!mounted) return;
                    messenger.showSnackBar(
                        const SnackBar(content: Text('Meeting scheduled')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Schedule Meeting'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _channelCard(Channel ch) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HoverCard(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _pill('Webex Sponsored', const Color(0xFFD9F1FA),
                        fg: AppTheme.primary),
                    _pill(ch.topic, _topicColor(ch.topic).withValues(alpha: 0.15),
                        fg: _topicColor(ch.topic)),
                  ],
                ),
              ),
              if (ch.matchPercent != null)
                Text('${ch.matchPercent}% match',
                    style: TextStyle(
                        color: _matchColor(ch.matchPercent!),
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
            ]),
            const SizedBox(height: 10),
            Text(ch.title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(ch.sponsor,
                style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
            const SizedBox(height: 8),
            Text(ch.description,
                style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 10),
            Text('${ch.members} members    ${ch.activeThreads} active threads',
                style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
            if (ch.alignmentText != null) ...[
              const SizedBox(height: 6),
              Text(ch.alignmentText!,
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontStyle: FontStyle.italic,
                      fontSize: 12)),
            ],
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final joined =
                        await ApiService.instance.toggleJoinChannel(ch.id);
                    if (!mounted) return;
                    setState(() => ch.joined = joined);
                    messenger.showSnackBar(SnackBar(
                        content: Text(joined ? 'Joined' : 'Left channel')));
                  },
                  child: Text(ch.joined ? 'Joined' : 'Join Channel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Opening threads in ${ch.title}…')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Threads'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _browseAllWebexButton() {
    return HoverCard(
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: OutlinedButton(
          onPressed: widget.onOpenWebex,
          child: const Text('Browse all Webex  →'),
        ),
      ),
    );
  }

  Widget _sessionCard(Session s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HoverCard(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  constraints: const BoxConstraints(maxWidth: 130),
                  child: Text(s.id,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary)),
                ),
              ),
              if (s.matchPercent != null)
                Text('${s.matchPercent}% match',
                    style: TextStyle(
                        color: _matchColor(s.matchPercent!),
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
            ]),
            const SizedBox(height: 10),
            Text(s.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('${s.day} · ${s.time} · ${s.room}',
                style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
            if (s.description != null) ...[
              const SizedBox(height: 8),
              Text(s.description!,
                  style: const TextStyle(color: Colors.black87)),
            ],
            if (s.alignmentText != null) ...[
              const SizedBox(height: 6),
              Text(s.alignmentText!,
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontStyle: FontStyle.italic,
                      fontSize: 12)),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final scheduled =
                    await ApiService.instance.toggleScheduleSession(s.id);
                if (!mounted) return;
                setState(() => s.scheduled = scheduled);
                messenger.showSnackBar(SnackBar(
                    content: Text(
                        scheduled ? 'Added to schedule' : 'Removed from schedule')));
              },
              icon: Icon(s.scheduled ? Icons.check_circle : Icons.add_circle,
                  size: 18,
                  color: s.scheduled ? AppTheme.muted : AppTheme.primary),
              label: Text(s.scheduled ? 'Scheduled' : 'Add to schedule'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    s.scheduled ? AppTheme.muted : AppTheme.primary,
                side: BorderSide(
                    color: s.scheduled
                        ? const Color(0xFFCFD8E3)
                        : AppTheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, Color bg, {Color? fg}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: fg ?? AppTheme.primary)),
      );

  Color _badgeColor(String? badge) {
    if (badge == 'Cisco Expert') return const Color(0xFFD9F1FA);
    return const Color(0xFFDFF7E7);
  }

  Color _matchColor(int m) {
    if (m >= 85) return const Color(0xFF16A34A);
    if (m >= 70) return const Color(0xFF3D9E63);
    return AppTheme.muted;
  }

  Color _topicColor(String topic) {
    switch (topic) {
      case 'AI Infrastructure':
        return const Color(0xFFEF9F1A);
      case 'Security':
        return const Color(0xFFEF9F1A);
      case 'Automation':
        return const Color(0xFFEF9F1A);
      case 'Collaboration':
        return const Color(0xFFEF9F1A);
      default:
        return AppTheme.primary;
    }
  }
}
