// navigation_entity.dart 
// file description: class for entity data (nodes or landmarks)

class NavigationEntity {
  final String
  id; // for differenting between unique landmarks of similar type - 'ABC' where digit 'A' is the type identifier and 'BC' is the value
  final String name; // e.g. "office A"
  final bool isNode; // for differentiating between nodes and physical landmarks
  final double x; // coordinate position
  final double y;
  final String? attachedToLink; // the node link that landmarks can be attached to, e.g. '101-102' (idNodeA-idNodeB)
  final String? property; // e.g. "green", "buzzing"
  final String? type; // e.g. "plant", "cafe"
  final String? sensoryType; // e.g. "visual", "auditory"

  const NavigationEntity({
    required this.id,
    required this.name,
    required this.isNode,
    required this.x,
    required this.y,
    this.attachedToLink,
    this.property,
    this.type,
    this.sensoryType,
  });
}