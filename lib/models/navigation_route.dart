// navigation_route.dart 
// file description: class for route data

import 'navigation_entity.dart';

class NavigationRoute { // Class name 'Route' is taken by flutter's in-built screen navigation system
  final String id;
  final String title;
  final String subtitle;
  final List<NavigationEntity> data;


  const NavigationRoute({
    required this.id,
    required this.title, 
    required this.subtitle,
    required this.data,
  });
}