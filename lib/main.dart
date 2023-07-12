import 'package:flutter/material.dart';
import 'edit_workout.dart';
import 'play.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainWidget(),
    );
  }
}

List<Workout> workouts = [];

class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  @override
  void initState() {
    super.initState();
  }

  void addWorkout() {
    setState(() {
      workouts.add(Workout(
        key: UniqueKey(),
        index: workouts.length, // Assign the index of the workout
        removeWorkout: removeWorkout,
        name: 'Workout ${workouts.length}',
      ));
    });
  }

  void removeWorkout(Workout workout) {
    setState(() {
      workouts.remove(workout);
    });
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final workout = workouts.removeAt(oldIndex);
      workouts.insert(newIndex, workout);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xff252525),
        ),
        child: Column(
          children: [
            Container(
              height:
                  100, // Adjust the height as needed for the logo and settings wheel
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Add your logo widget here
                  Icon(
                    Icons.ac_unit, // Replace with your logo icon
                    size: 50,
                    color: Colors.white,
                  ),
                  // Add your settings wheel widget here
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Handle settings button press
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
                height: 16.0), // Add spacing between the header and the list
            Expanded(
              child: ReorderableListView(
                onReorder: onReorder,
                children: workouts.map((workout) {
                  return workout;
                }).toList(),
              ),
            ),
            SizedBox(
                height: 16.0), // Add spacing between the list and the button
            SizedBox(
              width: double.infinity, // Make the button occupy the entire width
              child: ElevatedButton(
                onPressed: addWorkout,
                child: Text(
                  'Add Workout',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[850],
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Workout extends StatefulWidget {
  Workout({
    Key? key,
    required this.index,
    required this.removeWorkout,
    required this.name,
  }) : super(key: key);

  final int index;
  String name;
  List<WorkoutSet> sets = [];
  final Function(Workout) removeWorkout;

  @override
  _WorkoutState createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  bool isExpanded = false;

  void editWorkout(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WorkoutDesignPage(workoutKey: widget.key)),
    );
  }

  void playWorkout(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PlayWorkoutPage(workoutKey: widget.key)),
    );
  }

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void removeWorkout() {
    widget.removeWorkout(this.widget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.key,
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.orange[800],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: toggleExpansion,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded)
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 8.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.remove_circle),
                          onPressed: removeWorkout,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            editWorkout(context, widget.index);
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () {
                            playWorkout(context, widget.index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 8.0,
                ), // Add some spacing between the workout content and sets
// Add your code to display the sets here
// For example, if you have a list of sets, you can iterate over them and display each set
                for (var set in widget.sets)
                  SizedBox(
                    width: 150.0, // Specify a fixed height for the container
                    child: Container(
                      margin: EdgeInsets.only(top: 8.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text('$set'),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
