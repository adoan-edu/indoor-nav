import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:indoor_nav/models/route.dart';
import 'package:indoor_nav/models/landmark.dart';
import 'package:indoor_nav/utils/description_generator.dart';
import 'package:indoor_nav/utils/navigation_logic.dart';
import 'package:indoor_nav/models/building1_route1.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Class Level Initialisation
class _HomePageState extends State<HomePage> {
  final FlutterTts _flutterTts = FlutterTts();
  final DescriptionGenerator _generator = DescriptionGenerator();
  final NavigationLogic _navigationLogic =
      NavigationLogic(); // Used in _startOrContinueRoute

  String _currentInstructionLandmarkGuided = "Select a demo route to begin.";
  String _currentInstructionDistanceBased = "Select a demo route to begin.";
  int _currentLandmarkIndex = 0;
  double _speechRate = 0.5; // Default rate
  double _speechPitch = 1.0; // Default pitch
  bool _isRouteComplete = false;
  NavigationRoute? _selectedRoute;
  List<NavigationRoute> demos = [];
  IconData _currentActionIcon = Icons.explore_outlined; // Default compass icon

  @override
  void initState() {
    super.initState();
    _getInitialInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: SelectionArea(
        child: ListView(
          children: [
            _routeSelection(),
            SizedBox(height: 40),
            _navigationInstructions(),
            SizedBox(height: 40),
            _landmarkInstructions(),
            _nextStepButton(),
            _personalisationSettings(),
          ],
        ),
      ),
    );
  }

  void _getInitialInfo() {
    demos = building1DemoRoutes;
  }

  void _startOrContinueRoute(NavigationRoute route) {
    _selectedRoute = route;

    final String destinationName = route.landmarks.last.name;

    // Bound check
    if (_currentLandmarkIndex >= route.landmarks.length - 1) {
      _setInstruction(
        "You are arriving at $destinationName.",
        "You have arrived at $destinationName.",
      );
      setState(() {
        _currentActionIcon = Icons.check_circle;
        _isRouteComplete = true; // To stop the navigation and reset the route
      });
      _currentLandmarkIndex = 0;
      return;
    }

    // Get current landmark in the route and find action associated in the data
    Landmark currentLandmark = route.landmarks[_currentLandmarkIndex];
    Landmark nextLandmark = route.landmarks[_currentLandmarkIndex + 1];
    bool isDestination =
        (_currentLandmarkIndex + 1) == route.landmarks.length - 1;
    String action = _navigationLogic.calculateAction(
      currentLandmark,
      nextLandmark,
    );
    double distance = _navigationLogic.calculateDistance(
      currentLandmark,
      nextLandmark,
    );

    String instructionDistanceBased;
    String instructionLandmarkGuided;

    if (isDestination) {
      instructionDistanceBased =
          "In ${distance.round()}m, your destination, $destinationName, is on your $action.";
      instructionLandmarkGuided =
          "In ${distance.round()}m, your destination, $destinationName, is on your $action.";
    } else {
      instructionDistanceBased =
          "Head forwards ${distance.round()}m and turn $action.";
      // Utilise description generator for this step
      instructionLandmarkGuided =
          "Head forwards ${distance.round()}m ${_generator.generate(nextLandmark, action)}";
    }

    setState(() {
      _currentActionIcon = _getIconForAction(
        action,
      ); // Update Icon for the Action type
      _isRouteComplete = false;
    });
    // Update state and output TTS
    _setInstruction(instructionDistanceBased, instructionLandmarkGuided);
    _currentLandmarkIndex++;
  }

  void _setInstruction(
    String instructionDistanceBased,
    instructionLandmarkGuided,
  ) {
    // Updates the current instruction based on the instruction generated for the landmark
    setState(() {
      _currentInstructionDistanceBased = instructionDistanceBased;
      _currentInstructionLandmarkGuided = instructionLandmarkGuided;
    });
    _flutterTts.setSpeechRate(_speechRate);
    _flutterTts.setPitch(_speechPitch);
    _flutterTts.speak(instructionLandmarkGuided);
  }

  IconData _getIconForAction(String action) {
    final String lowerAction = action.toLowerCase();

    if (lowerAction.contains('left')) {
      return Icons.arrow_back;
    }
    if (lowerAction.contains('right')) {
      return Icons.arrow_forward;
    }
    if (lowerAction.contains('head') || lowerAction.contains('straight')) {
      return Icons.arrow_upward;
    }
    if (lowerAction.contains('arrive')) {
      return Icons.place;
    }
    if (lowerAction.contains('past')) {
      return Icons.shortcut;
    }
    return Icons.navigation; // Default
  }

  Column _routeSelection() {
    // UI buttons to Select between Demo Route A or B
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Subtitle Text Formatting
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Route Selection',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Subtitle Text Box Size
        SizedBox(height: 15),
        // Demo Route Selection Field
        Container(
          // Background Formatting
          padding: const EdgeInsets.all(8.0),
          height: 150,
          decoration: BoxDecoration(color: Colors.blue),
          // List of Routes Formatting
          child: ListView.builder(
            itemCount: demos.length,
            itemBuilder: (context, index) {
              final demo = demos[index];
              final bool isSelected =
                  (_selectedRoute == demo); // Store selection as a variable
              // List Item Formatting
              return Card(
                // Card Background Formatting
                color: isSelected ? Colors.white : Colors.blue,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                // List Item Title Formatting
                child: ListTile(
                  title: Text(
                    demo.title,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  // List Item Subtitle Formatting
                  subtitle: Text(
                    demo.subtitle,
                    style: TextStyle(color: Colors.black),
                  ),
                  // Tap Interataction with List Item
                  onTap: () {
                    setState(() {
                      _selectedRoute = demo; // Assign demo
                    });
                    _currentLandmarkIndex = 0; // Go to beginning of demo
                    _startOrContinueRoute(
                      demo,
                    ); // Call instruction generating function
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Column _landmarkInstructions() {
    // Displays landmark-guided instructions
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Subtitle Text Formatting
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Landmark-Guided Description',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Spacing Between Title Text and Field
        SizedBox(height: 10),
        // Landmark-Guided Instructions Field
        Container(
          // Background Text Box Formatting
          height: 150,
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey,
            border: Border.all(color: Colors.black),
          ),
          // Landmark-Guided Instructions Text Formatting
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_currentActionIcon, size: 40, color: Colors.white),
              SizedBox(height: 10),
              Text(
                _currentInstructionLandmarkGuided,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column _navigationInstructions() {
    // Displays original navigation instructions
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title Text Formatting
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Original Navigation Instructions',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Spacing Between Title Text and Field
        SizedBox(height: 10),
        // Navigation Instructions Field
        Container(
          // Background/Text Box Formatting
          height: 150,
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            border: Border.all(color: Colors.black),
          ),
          // Navigation Instructions Text Formatting
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                _currentInstructionDistanceBased,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Padding _nextStepButton() {
    // UI button to manually proceed to next step in the route. Changes to 'Reset' at the end of the route.
    return Padding(
      // Next Step Button Formatting
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        child: Text(_isRouteComplete ? "Reset Route" : "Next Step"),
        onPressed: () {
          if (_selectedRoute != null) {
            // Check that a route is selected and has been assigned to _selectedRoute
            _startOrContinueRoute(
              _selectedRoute!,
            ); // '!' to pass non-null non-local variables, in this case _selectedRoute is not a local variable and should be non-null
          }
        },
      ),
    );
  }

  Widget _personalisationSettings() {
    // UI sliders to set the speech rate and pitch
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title Text Formatting
          Text(
            "Voice Personalisation",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          // Speech Rate Slider Formatting
          Row(
            children: [
              Icon(
                Icons.speed, // Flutter Icon to Represent Rate
              ),
              Expanded(
                child: Slider(
                  value: _speechRate,
                  min: 0.1,
                  max: 1.0,
                  divisions: 100,
                  label:
                      "Rate: ${(_speechRate * 100).toInt()}%", // Rounding to int
                  // Set _speechRate to Slider Value
                  onChanged: (double value) {
                    setState(() {
                      _speechRate = value;
                    });
                  },
                ),
              ),
              Text("Rate"),
            ],
          ),
          // Pitch Slider Formatting
          Row(
            children: [
              Icon(
                Icons.compress, // Flutter Icon to Represent Pitch
              ),
              Expanded(
                child: Slider(
                  value: _speechPitch,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label:
                      "Pitch: ${_speechPitch.toStringAsFixed(1)}", // Round to 1 d.p.
                  // Set _speechPitch to Slider Value
                  onChanged: (double value) {
                    setState(() {
                      _speechPitch = value;
                    });
                  },
                ),
              ),
              Text("Pitch"),
            ],
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    // appBar persisting at the top of the screen, displaying app title
    return AppBar(
      title: Text(
        'Indoor Navigator',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0.0, //remove shadow of app bar
      centerTitle: true,
    );
  }
}
