import '../models/navigation_entity.dart';
import 'dart:math';

// Contains the mathematics and logic that connects the nodes and landmarks
class NavigationLogic {
  num currentHeading = 0;

void updateNavigation(int currentIndex, List<String> route, Map<String, NavigationEntity> masterData) {
    // Get IDs from the route
    // node A->B = incoming link, node B->C = outgoing link
    String idA = (currentIndex > 0) ? route[currentIndex - 1] : "";
    String idB = route[currentIndex];
    String idC = (currentIndex < route.length - 1) ? route[currentIndex + 1] : "";

    NavigationEntity? nodeA = masterData[idA];
    NavigationEntity? nodeB = masterData[idB];
    NavigationEntity? nodeC = masterData[idC];

    // Bound check
    if (nodeA == null) {
      return;
    }

    if (nodeB != null) {
      if (nodeC == null) {
        return;
      }
      calculateAction(nodeA, nodeB, nodeC);
    }
  }

  // Get action from route data
  double calculateDistance(NavigationEntity currentNode, NavigationEntity nextNode) {
    final double xO = currentNode.x;
    final double yO = currentNode.y;
    final double xN = nextNode.x;
    final double yN = nextNode.y;

    return (xN - xO).abs() + (yN - yO).abs(); // Node Link Distance
  }

  String calculateAction(NavigationEntity previousNode, NavigationEntity currentNode, NavigationEntity nextNode) {
    final double xA = currentNode.x;
    final double yA = currentNode.y;
    final double xB = nextNode.x;
    final double yB = nextNode.y;

    num theta = atan(
      (yB - yA).abs() / (xB - xA).abs(),
    ); // Angle between the x and y components that separate the current NavigationEntity and the next NavigationEntity
    double angleThreshold = (1 / 2) * pi;

}
