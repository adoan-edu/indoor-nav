import 'route.dart';
import 'landmark.dart';
import 'building1_data.dart';

// Method for retrieving Landmark data from the Master Map of the Indoor Environment
Landmark getLandmark(String id) {
  return building1Landmarks[id] ??
      Landmark(
        id: 'err',
        name: '<error> landmark not found',
        x: 0,
        y: 0,
        isNode: false,
        property: '',
        type: '',
        sensoryType: '',
      );
}

final List<NavigationRoute> building1DemoRoutes = [
  NavigationRoute(
    id: 'Route 1',
    title: 'Demo Route 1',
    subtitle: 'Entrance to Elevator H',
    landmarks: [
      getLandmark('start'),
      getLandmark('chair_corner_storage'),
      getLandmark('board_function_room'),
      getLandmark('plant_elevator'),
      getLandmark('elevator_h'),
    ],
  ),
  NavigationRoute(
    id: 'Route 2',
    title: 'Demo Route 2',
    subtitle: 'Node A to Node B',
    landmarks: [

    ],
  ),
];