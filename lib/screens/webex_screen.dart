import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/channel.dart';
import '../theme.dart';
import '../widgets/hover_card.dart';

class WebexScreen extends StatefulWidget {
  const WebexScreen({super.key});

  @override
  State<WebexScreen> createState() => _WebexScreenState();
}

class _WebexScreenState extends State<WebexScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<String> _topics = const ['All topics'];
  List<Channel> _channels = const [];
  String _selectedTopic = 'All topics';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final topics = await ApiService.instance.getWebexTopics();
      final channels = await ApiService.instance.getChannels();
      if (!mounted) return;
      setState(() {
        _topics = topics;
        _channels = channels;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('WebexScreen load failed: $e\n$st');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<Channel> get _filteredChannels {
    if (_selectedTopic == 'All topics') return _channels;
    return _channels.where((c) => c.topic == _selectedTopic).toList();
  }

  List<Channel> get _myChannels =>
      _channels.where((c) => c.joined).toList();

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final onDiscover = _tabController.index == 0;
    final list = onDiscover ? _filteredChannels : _myChannels;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _headerCard(),
        const SizedBox(height: 12),
        _topicsRow(),
        const SizedBox(height: 12),
        _tabsBar(),
        const SizedBox(height: 12),
        if (list.isEmpty)
          onDiscover ? _emptyDiscover() : _emptyMyWebex()
        else
          ...list.map(_channelCard),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _headerCard() {
    return HoverCard(
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pill('Webex Sponsored', const Color(0xFFD9F1FA),
              fg: AppTheme.primary),
          const SizedBox(height: 10),
          const Text('Webex',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
              'Join sponsored topic channels to network, share ideas, and follow collaboration threads.',
              style: TextStyle(color: AppTheme.muted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _topicsRow() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _topics.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = _topics[i];
          final selected = t == _selectedTopic;
          return ChoiceChip(
            label: Text(t),
            selected: selected,
            onSelected: (_) => setState(() => _selectedTopic = t),
            selectedColor: const Color(0xFFD9F1FA),
            backgroundColor: Colors.white,
            side: BorderSide(
                color: selected ? AppTheme.primary : const Color(0xFFCFD8E3)),
            labelStyle: TextStyle(
              color: selected ? AppTheme.primary : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

  Widget _tabsBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E8EF)),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        indicator: BoxDecoration(
          color: const Color(0xFFD9F1FA),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.muted,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: [
          const Tab(text: 'Discover'),
          Tab(text: 'My Webex (${_myChannels.length})'),
        ],
      ),
    );
  }

  Widget _emptyMyWebex() {
    return HoverCard(
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: const Center(
        child: Text(
            "You haven't joined any channels yet.\nJoin one from Discover to see it here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.muted)),
      ),
    );
  }

  Widget _emptyDiscover() {
    return HoverCard(
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Center(
        child: Text(
            'No channels for "$_selectedTopic" yet.\nPick another topic to see sponsored channels.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.muted)),
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
                child: _pill(ch.topic, const Color(0xFFFFE9C7),
                    fg: const Color(0xFFB86B00)),
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
            if (ch.alignmentText != null) ...[
              const SizedBox(height: 8),
              Text(ch.alignmentText!,
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontStyle: FontStyle.italic,
                      fontSize: 12)),
            ],
            const SizedBox(height: 10),
            Text('${ch.members} members    ${ch.activeThreads} threads',
                style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
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

  Color _matchColor(int m) {
    if (m >= 85) return const Color(0xFF16A34A);
    if (m >= 70) return const Color(0xFF3D9E63);
    return AppTheme.muted;
  }
}
