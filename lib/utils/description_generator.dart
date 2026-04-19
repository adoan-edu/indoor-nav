import '../models/navigation_entity.dart';

// Contains the algorithm that translates the mathematics and logic from NavigationLogic into natural language i.e. sentence builder
class DescriptionGenerator {
  String generate(NavigationEntity landmark, String action) {
    // Check for an allocation of the end of the route
    if (landmark.type == 'destination') {
      return "You are arriving at ${landmark.name}.";
    }
    // Rules for sensory types
    if (landmark.sensoryType == 'auditory') {
      return "At a ${landmark.property} ${landmark.type}, turn $action.";
    } else if (landmark.sensoryType == 'tactile') {
      return "There is a ${landmark.property} ${landmark.type} ahead. Turn $action when you can feel it";
    } else {
      // Default visual/general description
      return "until your next $action turn, where there is a ${landmark.property} ${landmark.type}. Turn $action.";
    }
  }
}
