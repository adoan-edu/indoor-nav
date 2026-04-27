import 'package:indoor_nav/models/navigation_route.dart';

import '../models/navigation_entity.dart';
import '../models/navigation_packet.dart';
import 'dart:math';

// Contains the mathematics and logic that connects the nodes and landmarks
class NavigationLogic {
  num currentHeading = 0;

  // Returns a packet containing instruction data captured from the current state in the route
  NavigationPacket updateNavigation(
    int currentIndex,
    NavigationRoute route,
    Map<String, NavigationEntity> masterData,
  ) {
    // Get IDs from the route.data
    // node A->B = incoming link, node B->C = outgoing link
    String idA = (currentIndex > 0) ? route.data[currentIndex - 1].id : "";
    String idB = route.data[currentIndex].id;
    String idC = (currentIndex < route.data.length - 1)
        ? route.data[currentIndex + 1].id
        : "";

    // Assign nodes using currentIndex, checking for boundary (null)
    NavigationEntity? nodeA = (currentIndex > 0)
        ? route.data[currentIndex - 1]
        : null;
    NavigationEntity? nodeB =
        route.data[currentIndex];
    NavigationEntity? nodeC = (currentIndex < route.data.length - 1)
        ? route.data[currentIndex + 1]
        : null;

    // Bound check
    if (nodeC == null && nodeA != null) {
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

// Return list of landmarks attached to the link between two nodes
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

// Get action from route.data.id data
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
  if (phi - theta == pi / 2 || phi - theta == -3 * pi / 2) {
    return "left"; 
  }
  if (phi - theta == 3 * pi / 2 || phi - theta == -pi / 2) {
    return "right";
  }
  throw Exception("error - check angle logic in navigation_logic.dart");
}
