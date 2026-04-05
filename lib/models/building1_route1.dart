import 'route.dart';
import 'landmark.dart';
import 'building1_data.dart';

// Method for retrieving Landmark data from the Master Map of the Indoor Environment
Landmark getLandmark(String id) {
  return building1Landmarks[id] ??
      Landmark(
        id: 'err',
        name: '',
        x: 0,
        y: 0,
        isNode: false,
        property: '',
        type: '',
        sensoryType: '',
      );
}

final List<NavigationRoute> building1Route1 = [
  NavigationRoute(
    id: 'Route 1',
    title: 'Demo Route 1',
    subtitle: 'Entrance to Elevator H',
    landmarks: [
      getLandmark('Start'),
      getLandmark('Chair'),
      getLandmark('Board'),
      getLandmark('Plant'),
      getLandmark('Elevator H'),
    ],
  ),
];
