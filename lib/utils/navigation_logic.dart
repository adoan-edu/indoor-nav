import '../models/landmark.dart';
import 'dart:math';

// Contains the mathematics and logic that connects the nodes and landmarks
class NavigationLogic {
  num currentHeading = 0;
  // Get action from route data
  double calculateDistance(Landmark currentLandmark, Landmark nextLandmark) {
    final double xO = currentLandmark.x;
    final double yO = currentLandmark.y;
    final double xN = nextLandmark.x;
    final double yN = nextLandmark.y;

    return (xN - xO).abs() + (yN - yO).abs(); // Node Link Distance
  }

  String calculateAction(Landmark currentLandmark, Landmark nextLandmark) {
    final double xO = currentLandmark.x;
    final double yO = currentLandmark.y;
    final double xN = nextLandmark.x;
    final double yN = nextLandmark.y;

    num theta = atan(
      (yN - yO).abs() / (xN - xO).abs(),
    ); // Angle between the x and y components that separate the current landmark and the next landmark
    double angleThreshold = (3 / 4) * pi;

    // Compare the current heading with the new heading and update if there is a change
    if (currentHeading == theta) {
      return 'head towards';
    } else {
      currentHeading = theta;
      if (0 < theta && theta < angleThreshold) {
        return 'right';
      }
      if (-angleThreshold < theta && theta < 0) {
        return 'left';
      }
    }
    return 'continue forward';
  }
}
