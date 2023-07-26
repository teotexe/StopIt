import 'package:flutter/material.dart';
import 'Save/save_workout.dart';
import 'main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: WorkoutDesignPage(workoutId: 0),
    );
  }
}

List<WorkoutSet> sets = []; // Initialize the sets list
int _workoutId = 0;

class WorkoutDesignPage extends StatefulWidget {
  final int workoutId; // Add the workout index parameter

  WorkoutDesignPage({required this.workoutId});

  @override
  _WorkoutDesignPageState createState() => _WorkoutDesignPageState();
}

class _WorkoutDesignPageState extends State<WorkoutDesignPage> {
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Retrieve the selected workout using the provided workout index
    final selectedWorkout =
        workouts.firstWhere((workout) => workout.Id == widget.workoutId);
    // Initialize the sets list with the sets from the selected workout
    sets = selectedWorkout.sets.cast<WorkoutSet>();
    nameController.text = selectedWorkout.name;

    _workoutId = widget.workoutId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(80), // Set the preferred height of the AppBar
        child: AppBar(
          title: Align(
            alignment:
                Alignment.bottomLeft, // Align the label to the bottom left
            child: TextFormField(
              controller: nameController,
              style: TextStyle(
                color: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  workouts
                      .firstWhere((workout) => workout.Id == widget.workoutId)
                      .name = value;
                  savePersistant(workouts
                      .firstWhere((workout) => workout.Id == widget.workoutId));
                });
              },
              decoration: InputDecoration(
                labelText: 'Workout Name',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFff0000)),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFaf0404)),
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              ),
            ),
          ),
          toolbarHeight: 60, // Reduce the height of the AppBar
          backgroundColor: Color(0xFF252525),
        ),
      ),
      body: ReorderableListView(
        padding: EdgeInsets.symmetric(vertical: 10),
        children: sets
            .asMap()
            .map((index, set) => MapEntry(
                  index,
                  SetWidget(
                    key: UniqueKey(),
                    set: set,
                    workoutId: widget.workoutId, // Pass the workoutId parameter
                    onDelete: () {
                      setState(() {
                        removeSet(
                            workouts.firstWhere(
                                (workout) => workout.Id == widget.workoutId),
                            set);
                        sets.removeAt(index);
                      });
                    },
                  ),
                ))
            .values
            .toList(),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final set = sets.removeAt(oldIndex);
            sets.insert(newIndex, set);
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            sets.add(WorkoutSet());
            savePersistant(workouts
                .firstWhere((workout) => workout.Id == widget.workoutId));
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFFF0000),
      ),
      backgroundColor: Color(0xFF414141),
    );
  }
}

class WorkoutSet {
  String name = '';
  List<WorkoutInterval> intervals = [];
  int repetitions = 1;

  WorkoutSet({
    this.name = '',
    this.repetitions = 1,
    List<WorkoutInterval>? intervals,
  }) : intervals = intervals ?? [];

  WorkoutSet.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        intervals = (json['intervals'] as List<dynamic>)
            .map((intervalJson) => WorkoutInterval.fromJson(intervalJson))
            .toList(),
        repetitions = json['repetitions'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'intervals': intervals.map((interval) => interval.toJson()).toList(),
      'repetitions': repetitions,
    };
  }

  @override
  String toString() {
    String intervalsText = '';
    for (WorkoutInterval interval in intervals) {
      intervalsText += '   • ${interval.toString()}\n';
    }
    return '• $name (x$repetitions)\n$intervalsText';
  }
}

class WorkoutInterval {
  String name = '';
  String type = "Time";
  int duration = 0; // in seconds
  int reps = 0;
  int repetitions = 1;

  WorkoutInterval(
      {this.type = "Time",
      this.duration = 0,
      this.reps = 0,
      this.name = '',
      this.repetitions = 1});

  WorkoutInterval.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        type = json['type'],
        duration = json['duration'],
        reps = json['reps'],
        repetitions = json['repetitions'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'duration': duration,
      'reps': reps,
      'repetitions': repetitions,
    };
  }

  @override
  String toString() {
    if (type == "Time") {
      return '$name: $duration seconds';
    } else {
      return '$name: $reps reps';
    }
  }
}

class SetWidget extends StatefulWidget {
  final Key? key;
  final WorkoutSet set;
  final int workoutId; // Add the workoutId parameter
  final VoidCallback onDelete;

  const SetWidget({
    this.key,
    required this.set,
    required this.workoutId, // Pass the workoutId parameter
    required this.onDelete,
  });

  @override
  _SetWidgetState createState() => _SetWidgetState();
}

class _SetWidgetState extends State<SetWidget> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _repetitionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.set.name;
    _repetitionsController.text = widget.set.repetitions.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: UniqueKey(),
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Color(0xFF252525),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: TextFormField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  widget.set.name = value;
                  savePersistant(workouts
                      .firstWhere((workout) => workout.Id == widget.workoutId));
                });
              },
              decoration: InputDecoration(
                labelText: 'Set Name',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFff0000)),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFaf0404)),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                setState(() {
                  widget.onDelete();
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Repetitions:',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.remove, color: Colors.white),
                onPressed: () {
                  setState(() {
                    if (widget.set.repetitions > 0) {
                      widget.set.repetitions--;
                      _repetitionsController.text =
                          widget.set.repetitions.toString();
                    }
                    savePersistant(workouts.firstWhere(
                        (workout) => workout.Id == widget.workoutId));
                  });
                },
              ),
              SizedBox(
                width: 50,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  controller: _repetitionsController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      widget.set.repetitions = int.tryParse(value) ?? 1;
                      savePersistant(workouts.firstWhere(
                          (workout) => workout.Id == widget.workoutId));
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF414141),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  setState(() {
                    widget.set.repetitions++;
                    _repetitionsController.text =
                        widget.set.repetitions.toString();
                    savePersistant(workouts.firstWhere(
                        (workout) => workout.Id == widget.workoutId));
                  });
                },
              ),
            ],
          ),
          ReorderableListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: widget.set.intervals
                .asMap()
                .map((index, interval) => MapEntry(
                      index,
                      IntervalWidget(
                        key: UniqueKey(),
                        interval: interval,
                        onDelete: () {
                          setState(() {
                            removeInterval(
                                workouts.firstWhere((workout) =>
                                    workout.Id == widget.workoutId),
                                widget.set,
                                interval);
                            widget.set.intervals.removeAt(index);
                          });
                        },
                      ),
                    ))
                .values
                .toList(),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final interval = widget.set.intervals.removeAt(oldIndex);
                widget.set.intervals.insert(newIndex, interval);
              });
            },
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.set.intervals.add(WorkoutInterval(
                      type: "Time", duration: 0, reps: 0, name: ''));
                  savePersistant(workouts
                      .firstWhere((workout) => workout.Id == widget.workoutId));
                });
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFaf0404),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Add Interval'),
            ),
          ),
        ],
      ),
    );
  }
}

class IntervalWidget extends StatefulWidget {
  final WorkoutInterval interval;
  final VoidCallback onDelete;

  const IntervalWidget(
      {Key? key, required this.interval, required this.onDelete})
      : super(key: key);

  @override
  _IntervalWidgetState createState() => _IntervalWidgetState();
}

class _IntervalWidgetState extends State<IntervalWidget> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _durationController = TextEditingController();
  TextEditingController _repsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.interval.name;
    _durationController.text = widget.interval.duration.toString();
    _repsController.text = widget.interval.reps.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Color(0xFF252525),
      child: ListTile(
        leading: IconButton(
          icon: Icon(Icons.delete),
          color: Colors.white,
          onPressed: () {
            setState(() {
              widget.onDelete();
            });
          },
        ),
        title: TextFormField(
          style: TextStyle(color: Colors.white),
          controller: _nameController,
          onChanged: (value) {
            setState(() {
              widget.interval.name = value;
              savePersistant(
                  workouts.firstWhere((workout) => workout.Id == _workoutId));
            });
          },
          decoration: InputDecoration(
            labelText: 'Interval Name',
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
        subtitle: Row(
          children: [
            Text('Type:', style: TextStyle(color: Colors.white)),
            SizedBox(width: 10),
            DropdownButton<String>(
              value: widget.interval.type,
              onChanged: (value) {
                setState(() {
                  widget.interval.type = value!;
                  savePersistant(workouts
                      .firstWhere((workout) => workout.Id == _workoutId));
                });
              },
              items: [
                DropdownMenuItem(
                  child: Text(
                    'Time',
                    style: TextStyle(
                        color: Colors.white), // Set the text color to white
                  ),
                  value: 'Time',
                ),
                DropdownMenuItem(
                  child: Text(
                    'Reps',
                    style: TextStyle(
                        color: Colors.white), // Set the text color to white
                  ),
                  value: 'Reps',
                ),
              ],
              dropdownColor: Color(0xFF252525),
              underline: Container(),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: widget.interval.type == "Time"
                    ? _durationController
                    : _repsController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    if (widget.interval.type == "Time") {
                      widget.interval.duration = int.tryParse(value) ?? 0;
                    } else {
                      widget.interval.reps = int.tryParse(value) ?? 0;
                    }
                    savePersistant(workouts
                        .firstWhere((workout) => workout.Id == _workoutId));
                  });
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF414141),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
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
