// building1_navigation.dart 
// file description: constructed navigation routes constructed using entities mapped in building1

import '../models/navigation_route.dart';
import '../models/navigation_entity.dart';
import 'building1_data.dart';

// Method for retrieving landmark data from the master map of the indoor environment
NavigationEntity getData(String key) {
  return building1Data[key] ??
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

// Note: this method can become the cause of long load times due to iterated search across the entire map
NavigationEntity findById(
  String targetId,
  Map<String, NavigationEntity> masterData,
) {
  NavigationEntity entities = masterData.values.firstWhere(
    (entity) => entity.id == targetId,
    orElse: () => throw Exception("ID $targetId not found in Master Data!"),
  );
  return entities;
}

// Uses findById so that we can import by referencing the id's of each entity instead of their key string
List<NavigationEntity> getRoute(
  List<String> ids,
  Map<String, NavigationEntity> masterData,
) {
  List<NavigationEntity> entities = ids
      .map(
        // take each element (string) inside ids (list of strings) and make them an 'id' to iterate findById over,
        (id) => findById(id, masterData),
      )
      .toList(); // return all results as a list
  return entities;
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
    data: getRoute([
      // Note: the use of the 'getRoute' method can be the cause of long load times due to incorporation of 'findByID' method which is not optimised
      '901',
      '902',
      '903',
      '904',
      '905',
      '906',
      '907',
      '908',
      '909',
      '910',
      '911',
      '912',
      '913',
    ], building1Data),
  ),
];
