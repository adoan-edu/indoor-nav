import 'route.dart';
import 'navigation_entity.dart';
import 'building1_data.dart';

// Method for retrieving Landmark data from the Master Map of the Indoor Environment
NavigationEntity getData(String id) {
  return building1Data[id] ??
      NavigationEntity(
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
    data: [
      getData('start'),
      getData('chair_corner_storage'),
      getData('board_function_room'),
      getData('plant_elevator'),
      getData('elevator_h'),
    ],
  ),
  NavigationRoute(
    id: 'Route 2',
    title: 'Demo Route 2',
    subtitle: 'Node A to Node B',
    data: [

    ],
  ),
];