import '../models/navigation_entity.dart';
import '../models/navigation_packet.dart';
import 'dart:math';

// Contains the mathematics and logic that connects the nodes and landmarks
class NavigationLogic {
  num currentHeading = 0;

  NavigationPacket updateNavigation(
    int currentIndex,
    List<String> route,
    Map<String, NavigationEntity> masterData,
  ) {
    // Get IDs from the route
    // node A->B = incoming link, node B->C = outgoing link
    String idA = (currentIndex > 0) ? route[currentIndex - 1] : "";
    String idB = route[currentIndex];
    String idC = (currentIndex < route.length - 1)
        ? route[currentIndex + 1]
        : "";

    NavigationEntity? nodeA = masterData[idA];
    NavigationEntity? nodeB = masterData[idB];
    NavigationEntity? nodeC = masterData[idC];

    // Data check
    if (nodeB == null) {
      throw Exception("Error: Node $idB not found in Master Data");
    }

    // Bound check
    if (nodeC == null) {
      return NavigationPacket(
        current: nodeB,
        next: null,
        distance: 0.0,
        action: "end",
        landmarks: findLinkLandmarks(nodeB.id, nodeC.id, masterData),
      );
    }

    if (nodeA == null) {
      return NavigationPacket(
        current: nodeB,
        next: nodeC,
        distance: calculateDistance(nodeB, nodeC),
        action: "start",
        landmarks: findLinkLandmarks(nodeB.id, nodeC.id, masterData),
      );
    }

    return NavigationPacket(
      current: nodeB,
      next: nodeC,
      distance: calculateDistance(nodeB, nodeC),
      action: calculateAction(nodeA, nodeB, nodeC),
      landmarks: findLandmarksForLink(nodeB.id, nodeC.id, masterData),
    );
  }
}

void findLandmarksForLink() {}

// Get action from route data
double calculateDistance(
  NavigationEntity currentNode,
  NavigationEntity nextNode,
) {
  final double xO = currentNode.x;
  final double yO = currentNode.y;
  final double xN = nextNode.x;
  final double yN = nextNode.y;

  return (xN - xO).abs() + (yN - yO).abs(); // Node Link Distance
}

String calculateAction(
  NavigationEntity previousNode,
  NavigationEntity currentNode,
  NavigationEntity nextNode,
) {
  final double xA = currentNode.x;
  final double yA = currentNode.y;
  final double xB = nextNode.x;
  final double yB = nextNode.y;

  num theta = atan(
    (yB - yA).abs() / (xB - xA).abs(),
  ); // Angle between the x and y components that separate the current NavigationEntity and the next NavigationEntity
  double angleThreshold = (1 / 2) * pi;
}
