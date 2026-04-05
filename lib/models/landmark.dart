class Landmark {
  final String id;          // for differenting between unique landmarks of similar type
  final String name;        // e.g. "office A"
  final String property;    // e.g. "green", "buzzing"
  final String type;        // e.g. "plant", "cafe"
  final String sensoryType; // e.g. "visual", "auditory"
  final bool isNode;        // for differentiating between nodes and physical landmarks
  final double x;           // coordinate position
  final double y;

  const Landmark({
    required this.id,
    required this.name,
    required this.property,
    required this.type,
    required this.sensoryType,
    required this.isNode,
    required this.x,
    required this.y
  });
}