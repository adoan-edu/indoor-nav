// navigation_logic.dart
// file description: contains logic between navigation entities

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
    String idA = (currentIndex > 0) ? route.data[currentIndex - 1].id : '';
    String idB = route.data[currentIndex].id;
    String idC = (currentIndex < route.data.length - 1)
        ? route.data[currentIndex + 1].id
        : '';

    // Assign nodes using currentIndex, checking for nulls at boundaries
    NavigationEntity? nodeA = (currentIndex > 0)
        ? route.data[currentIndex - 1]
        : null;
    NavigationEntity? nodeB = route.data[currentIndex];
    NavigationEntity? nodeC = (currentIndex < route.data.length - 1)
        ? route.data[currentIndex + 1]
        : null;

    // Empty list to store both the attached landmarks and its direction and add it to the packet
    List<MapEntry<NavigationEntity, String>> landmarksWithDirections = [];

    // Bound check
    // At end: next node is null, current and previous node is non-null
    if (nodeC == null && nodeA != null) {
      // Get landmarks attached to node link and their directions
      List<NavigationEntity> linkedLandmarks = findLandmarksOnLink(
        nodeA.id,
        nodeB.id,
        masterData,
      );
      for (NavigationEntity landmark in linkedLandmarks) {
        String direction = calculateLandmarkDirection(nodeA, nodeB, landmark);
        landmarksWithDirections.add(MapEntry(landmark, direction));
      }
      return NavigationPacket(
        current: nodeB,
        next: null,
        distance: 0.0,
        action: 'end',
        landmarks: landmarksWithDirections,
      );
    } else if (nodeA == null) {
      // Get landmarks attached to node link and their directions
      List<NavigationEntity> linkedLandmarks = findLandmarksOnLink(
        nodeB.id,
        nodeC!.id,
        masterData,
      );
      for (NavigationEntity landmark in linkedLandmarks) {
        String direction = calculateLandmarkDirection(nodeB, nodeC, landmark);
        landmarksWithDirections.add(MapEntry(landmark, direction));
      }
      return NavigationPacket(
        current: nodeB,
        next: nodeC,
        distance: calculateDistance(nodeB, nodeC),
        action: 'start',
        landmarks: landmarksWithDirections,
      );
    } else {
      // Get landmarks attached to node link and their directions
      List<NavigationEntity> linkedLandmarks = findLandmarksOnLink(
        nodeB.id,
        nodeC!.id,
        masterData,
      );
      for (NavigationEntity landmark in linkedLandmarks) {
        String direction = calculateLandmarkDirection(nodeB, nodeC, landmark);
        landmarksWithDirections.add(MapEntry(landmark, direction));
      }
      return NavigationPacket(
        current: nodeB,
        next: nodeC,
        distance: calculateDistance(nodeB, nodeC),
        action: calculateAction(nodeA, nodeB, nodeC),
        landmarks: landmarksWithDirections,
      );
    }
  }
}

// Return list of landmarks attached to the link between two nodes
// Used to process the landmarks along a given route (the route does not contain landmark information - landmark data is gathered by using this method's lookup with the master data)
List<NavigationEntity> findLandmarksOnLink(
  String fromId,
  String toId,
  Map<String, NavigationEntity> masterData,
) {
  List<NavigationEntity> landmarks = [];
  for (NavigationEntity entity in masterData.values) {
    if (entity.isNode == false &&
        (entity.attachedToLink == '$fromId-$toId' ||
            entity.attachedToLink == '$toId-$fromId')) {
      landmarks.add(entity);
    }
  }
  return landmarks;
}

// Calculate direction using 2D cross product of node link heading vector and the attached landmark vector
String calculateLandmarkDirection(
  NavigationEntity current,
  NavigationEntity next,
  NavigationEntity landmark,
) {
  // Node link vector
  double ax = next.x - current.x;
  double ay = next.y - current.y;
  // Landmark vector (from current node)
  double bx = landmark.x - current.x;
  double by = landmark.y - current.y;
  double crossProduct = (ax * by) - (ay * bx);

  return (crossProduct > 0) ? 'left' : 'right';
}

// Calculate Manhattan distance between two points
double calculateDistance(
  NavigationEntity currentNode,
  NavigationEntity nextNode,
) {
  double dy = nextNode.y - currentNode.y;
  double dx = nextNode.x - currentNode.x;

  return dx.abs() + dy.abs(); // Node Link Distance
}

// Calculate bearing (unit circle) between two points
double calculateHeading(
  NavigationEntity currentNode,
  NavigationEntity nextNode,
) {
  double dy = nextNode.y - currentNode.y;
  double dx = nextNode.x - currentNode.x;

  return atan2(dy, dx);
}

// Generate action string when traversing between nodes
String calculateAction(
  NavigationEntity previousNode,
  NavigationEntity currentNode,
  NavigationEntity nextNode,
) {
  num theta = calculateHeading(previousNode, currentNode);
  num phi = calculateHeading(currentNode, nextNode);

  if (theta == phi) {
    return 'straight';
  }
  if (phi - theta == pi / 2 || phi - theta == -3 * pi / 2) {
    return 'left';
  }
  if (phi - theta == 3 * pi / 2 || phi - theta == -pi / 2) {
    return 'right';
  }
  throw Exception('error - check angle logic in navigation_logic.dart');
}
