import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:indoor_nav/models/navigation_packet.dart';
import 'package:indoor_nav/models/navigation_route.dart';
import 'package:indoor_nav/models/navigation_entity.dart';
import 'package:indoor_nav/utils/description_generator.dart';
import 'package:indoor_nav/utils/navigation_logic.dart';
import 'package:indoor_nav/models/building1_data.dart';
import 'package:indoor_nav/models/building1_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Class Level Initialisation
class _HomePageState extends State<HomePage> {
  final FlutterTts _flutterTts = FlutterTts();
  final DescriptionGenerator _generator = DescriptionGenerator();
  final NavigationLogic _navigationLogic = NavigationLogic();

  String _currentInstructionPacket = "Select a demo route to begin.";
  String _currentInstructionGenerated = "Select a demo route to begin.";
  int _currentIndex = 0;
  double _speechRate = 1.0; // Default rate
  double _speechPitch = 1.5; // Default pitch
  bool _isRouteComplete = false;
  NavigationRoute? _selectedRoute;
  List<NavigationRoute> demos = [];
  Map<String, NavigationEntity> buildingData = {};
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
            _navigationPacket(),
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
    // Import Data of the Indoor Environment and the List of Demo Routes (Demo Route A and Demo Route B)
    demos = building1DemoRoutes;
    buildingData = building1Data;
  }

  void _startOrContinueRoute(
    NavigationRoute route,
    Map<String, NavigationEntity> masterData,
  ) {
    NavigationPacket currentPacket;

    // Generate navigation packet containing instruction data captured from the current state in the route
    // NavigationPacket({current, next, distance, action, landmarks (attached)})
    currentPacket = _navigationLogic.updateNavigation(
      _currentIndex,
      route,
      masterData,
    );

    // Bound check
    if (_currentIndex >= route.data.length - 1) {
      setState(() {
        _currentActionIcon = Icons.check_circle;
        _isRouteComplete = true; // To stop the navigation and reset the route
      });
      _currentIndex = 0;
      return;
    }

    String instructionPacket;
    String instructionGenerated;

    // To print out the instruction packet
    instructionPacket =
        "${currentPacket.current.id} "
        "${currentPacket.next?.id} " 
        "${currentPacket.distance} "
        "${currentPacket.action} "
        "${currentPacket.landmarks.map((entity) => entity.id).join('\n')}";
    // Utilise description generator
    if (currentPacket.action == 'end') {
      instructionGenerated =
          "In ${currentPacket.distance.round()}m, your destination, ${currentPacket.current}.";
    } else {
      instructionGenerated = _generator.generate(
        currentPacket.next!,
        currentPacket.action,
      );
    }

    setState(() {
      _currentActionIcon = _getIconForAction(
        currentPacket.action,
      ); // Update Icon for the Action type
      _isRouteComplete = false;
    });
    // Update state and output TTS
    _setInstruction(instructionPacket, instructionGenerated);
    _currentIndex++;
  }

  void _setInstruction(String instructionPacket, instructionGenerated) {
    // Updates the current instruction based on the instruction generated for the landmark
    setState(() {
      _currentInstructionPacket = instructionPacket;
      _currentInstructionGenerated = instructionGenerated;
    });
    _flutterTts.setSpeechRate(_speechRate);
    _flutterTts.setPitch(_speechPitch);
    _flutterTts.speak(instructionGenerated);
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
                    _currentIndex = 0; // Go to beginning of demo
                    _startOrContinueRoute(
                      demo,
                      buildingData,
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
                _currentInstructionGenerated,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Column _navigationPacket() {
    // Displays navigation packet
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title Text Formatting
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Navigation Packet',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Spacing Between Title Text and Field
        SizedBox(height: 10),
        // Navigation Packet Field
        Container(
          // Background/Text Box Formatting
          height: 150,
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            border: Border.all(color: Colors.black),
          ),
          // Navigation Packet Text Formatting
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                _currentInstructionPacket,
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
              buildingData,
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
