import '../models/navigation_entity.dart';

class NavigationPacket {
  final NavigationEntity current; // Node B
  final NavigationEntity? next; // Node C
  final double distance; // Manhattan distance from B -> C
  final String action; // "left", "right", "straight"
  final List<NavigationEntity> landmarks; // landmarks attached to node link B-C

  NavigationPacket({
    required this.current,
    this.next,
    // default values
    this.distance = 0.0,
    this.action = "straight",
    this.landmarks = const [],
  });
}
