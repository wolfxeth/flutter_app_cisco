import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../models/session.dart';
import '../theme.dart';
import '../widgets/hover_card.dart';

enum _LocationStatus { checking, granted, denied, servicesDisabled }

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  _LocationStatus _status = _LocationStatus.checking;
  String _selectedRoom = 'Auto (nearby)';
  List<Session> _sessions = const [];
  List<String> _rooms = const [];
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([_loadData(), _requestLocation()]);
  }

  Future<void> _loadData() async {
    final sessions = await ApiService.instance.getSessions(sortByDistance: true);
    final rooms = await ApiService.instance.getRooms();
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _rooms = rooms;
      _loadingData = false;
    });
  }

  Future<void> _requestLocation() async {
    if (!mounted) return;
    setState(() => _status = _LocationStatus.checking);

    final servicesOn = await Geolocator.isLocationServiceEnabled();
    if (!servicesOn) {
      if (!mounted) return;
      setState(() => _status = _LocationStatus.servicesDisabled);
      return;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (!mounted) return;
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      setState(() => _status = _LocationStatus.denied);
    } else {
      setState(() => _status = _LocationStatus.granted);
    }
  }

  List<Session> get _visibleSessions {
    if (_selectedRoom == 'Auto (nearby)') return _sessions;
    return _sessions.where((s) => s.room == _selectedRoom).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingData) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildStatusCard(),
        const SizedBox(height: 12),
        _buildRoomPicker(),
        const SizedBox(height: 16),
        _sessionsHeader(),
        const SizedBox(height: 8),
        ..._visibleSessions.map(_buildSessionCard),
        if (_visibleSessions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: HoverCard(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              child: const Center(
                child: Text('No sessions match this room yet.',
                    style: TextStyle(color: AppTheme.muted)),
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  ({IconData icon, Color color, String subtitle, String buttonLabel})
      _statusMeta() {
    switch (_status) {
      case _LocationStatus.checking:
        return (
          icon: Icons.my_location,
          color: AppTheme.primary,
          subtitle: 'Checking your location…',
          buttonLabel: 'Retry Location',
        );
      case _LocationStatus.granted:
        return (
          icon: Icons.location_on,
          color: AppTheme.success,
          subtitle: 'Sessions closest to you are listed first.',
          buttonLabel: 'Refresh Location',
        );
      case _LocationStatus.denied:
        return (
          icon: Icons.location_off_outlined,
          color: AppTheme.warning,
          subtitle: 'Location denied — select a room manually',
          buttonLabel: 'Retry Location',
        );
      case _LocationStatus.servicesDisabled:
        return (
          icon: Icons.gps_off_outlined,
          color: AppTheme.danger,
          subtitle:
              'Location services are off — enable them to see nearby rooms',
          buttonLabel: 'Retry Location',
        );
    }
  }

  Widget _buildStatusCard() {
    final meta = _statusMeta();
    final text = Theme.of(context).textTheme;
    return HoverCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: meta.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(meta.icon, color: meta.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nearby Sessions', style: text.titleLarge),
                  const SizedBox(height: 4),
                  Text(meta.subtitle, style: text.bodySmall),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            OutlinedButton.icon(
              onPressed:
                  _status == _LocationStatus.checking ? null : _requestLocation,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(meta.buttonLabel),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildRoomPicker() {
    final items = ['Auto (nearby)', ..._rooms];
    return HoverCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.meeting_room_outlined,
                size: 16, color: AppTheme.primary),
            SizedBox(width: 6),
            Text('Or pick a room',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRoom,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppTheme.muted),
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w600),
                items: items
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedRoom = v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(children: [
        Text('${_visibleSessions.length} session${_visibleSessions.length == 1 ? '' : 's'}',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.muted,
                letterSpacing: 0.4)),
        const SizedBox(width: 6),
        const Expanded(child: Divider(color: AppTheme.border, thickness: 1)),
      ]),
    );
  }

  Widget _buildSessionCard(Session s) {
    final showDistance =
        _status == _LocationStatus.granted && s.distanceMeters != null;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HoverCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _pill(s.id,
                  bg: AppTheme.accentSoft, fg: AppTheme.primary, bold: true),
              const SizedBox(width: 8),
              if (showDistance)
                _pill('${s.distanceMeters}m away',
                    bg: AppTheme.success.withValues(alpha: 0.12),
                    fg: AppTheme.success,
                    icon: Icons.near_me),
            ]),
            const SizedBox(height: 12),
            Text(s.title, style: text.titleMedium),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: AppTheme.muted),
              const SizedBox(width: 4),
              Text('${s.day} · ${s.time}', style: text.bodySmall),
              const SizedBox(width: 12),
              const Icon(Icons.place_outlined,
                  size: 13, color: AppTheme.muted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(s.room,
                    style: text.bodySmall,
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label,
      {required Color bg,
      required Color fg,
      IconData? icon,
      bool bold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: fg,
                letterSpacing: bold ? 0.3 : 0,
              )),
        ],
      ),
    );
  }
}
