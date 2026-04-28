import '../models/navigation_entity.dart';
import '../models/navigation_packet.dart';

// Contains the algorithm that translates the mathematics and logic from NavigationLogic into natural language i.e. sentence builder
class DescriptionGenerator {
  String generate(NavigationPacket currentPacket) {
    // Check for an allocation of the end of the route

    String instruction;
    NavigationEntity currentEntity = currentPacket.current;
    double distance = currentPacket.distance;
    String action = currentPacket.action;
    List<NavigationEntity> landmarks = currentPacket.landmarks.map((landmark) => landmark.key).toList(); // landmarks attached to node link
    List<String> landmarkDirections = currentPacket.landmarks.map((landmark) => landmark.value).toList(); // directions of landmarks attached to node link
    String straightInstruction = 'Continue straight for ${distance.toInt()} metres.';

    if (action == 'start') {
      instruction = 'Head forwards for ${distance.toInt()} metres.';
    } else if (action == 'end' && currentEntity.name == '') {
      return 'You have arrived at your destination.';
    } else if (action == 'end' && currentEntity.name != '') {
      return 'You have arrived at your destination, ${currentEntity.name}.';
    } else if (action == 'straight') {
      instruction = straightInstruction;
    } else if (action == 'left') {
      instruction = 'Turn left and ${straightInstruction.toLowerCase()}';
    } else if (action == 'right') {
      instruction = 'Turn right and ${straightInstruction.toLowerCase()}';
    } else {
      instruction = 'Proceed onwards.';
    }

    if (landmarks.isNotEmpty) {
      // Keep it simple with just the first landmark that is found attached to the node link
      NavigationEntity landmark = landmarks.first;
      String landmarkDirection = landmarkDirections.first;
      instruction += ' You will pass the ${landmark.name} on your $landmarkDirection.';
    }
    return instruction;
  }
}
