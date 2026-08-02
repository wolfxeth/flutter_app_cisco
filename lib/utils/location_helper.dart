import 'dart:math' as math;

class LocationHelper {
  /// Returns distance in meters between two lat/lon points using Haversine.
  static double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // Earth radius in meters
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat/2) * math.sin(dLat/2) +
        math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) *
        math.sin(dLon/2) * math.sin(dLon/2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
    return R * c;
  }

  static double _deg2rad(double deg) => deg * (math.pi / 180.0);
}
