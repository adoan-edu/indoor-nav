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
    else if (nodeC == null && nodeA != null) {
      return NavigationPacket(
        current: nodeB,
        next: null,
        distance: 0.0,
        action: "end",
        landmarks: findLandmarksOnLink(nodeA.id, nodeB.id, masterData),
      );
    } else if (nodeA == null) {
      return NavigationPacket(
        current: nodeB,
        next: nodeC!,
        distance: calculateDistance(nodeB, nodeC),
        action: "start",
        landmarks: findLandmarksOnLink(nodeB.id, nodeC.id, masterData),
      );
    } else {
      return NavigationPacket(
        current: nodeB,
        next: nodeC!,
        distance: calculateDistance(nodeB, nodeC),
        action: calculateAction(nodeA, nodeB, nodeC),
        landmarks: findLandmarksOnLink(nodeB.id, nodeC.id, masterData),
      );
    }
  }
}

List<NavigationEntity> findLandmarksOnLink(
  String fromId,
  String toId,
  Map<String, NavigationEntity> masterData,
) {
  List<NavigationEntity> landmarks = [];
  for (NavigationEntity entity in masterData.values) {
    if (entity.isNode == false && entity.attachedToLink == "$fromId-$toId") {
      landmarks.add(entity);
    }
  }
  return landmarks;
}

// Get action from route data
double calculateDistance(
  NavigationEntity currentNode,
  NavigationEntity nextNode,
) {
  double dy = nextNode.y - currentNode.y;
  double dx = nextNode.x - currentNode.x;

  return dx.abs() + dy.abs(); // Node Link Distance
}

double calculateHeading(
  NavigationEntity currentNode,
  NavigationEntity nextNode,
) {
  double dy = nextNode.y - currentNode.y;
  double dx = nextNode.x - currentNode.x;

  return atan2(dy, dx);
}

String calculateAction(
  NavigationEntity previousNode,
  NavigationEntity currentNode,
  NavigationEntity nextNode,
) {
  num theta = calculateHeading(previousNode, currentNode);
  num phi = calculateHeading(currentNode, nextNode);

  if (theta == phi) {
    return "straight";
  }
  if (theta - phi == pi / 2 || theta - pi == -3 * pi / 2) {
    return "left";
  }
  if (theta - phi == 3 * pi / 2 || theta - pi == -3 * pi / 2) {
    return "right";
  }
  throw Exception("error - check angle logic in navigation_logic.dart");
}
