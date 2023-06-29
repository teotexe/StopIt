import 'package:flutter/material.dart';
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
        primarySwatch: Colors.blue,
      ),
      home: WorkoutDesignPage(workoutKey: UniqueKey()),
    );
  }
}

List<Set> sets = []; // Initialize the sets list

class WorkoutDesignPage extends StatefulWidget {
  Key? workoutKey; // Add the workout index parameter

  WorkoutDesignPage({this.workoutKey});

  @override
  _WorkoutDesignPageState createState() => _WorkoutDesignPageState();
}

class _WorkoutDesignPageState extends State<WorkoutDesignPage> {
  @override
  void initState() {
    super.initState();
    // Retrieve the selected workout using the provided workout index
    final selectedWorkout =
        workouts.firstWhere((workout) => workout.key == widget.workoutKey);
    // Initialize the sets list with the sets from the selected workout
    sets = selectedWorkout.sets.cast<Set>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Design'),
      ),
      body: ReorderableListView(
        padding: EdgeInsets.symmetric(vertical: 10),
        children: sets
            .asMap()
            .map((index, set) => MapEntry(
                  index,
                  SetWidget(
                    key: ValueKey(index),
                    set: set,
                    onDelete: () {
                      setState(() {
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
            final Set set = sets.removeAt(oldIndex);
            sets.insert(newIndex, set);
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            sets.add(Set());
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class Set {
  String name = '';
  List<Interval> intervals = [];
  int repetitions = 1;

  Set({this.name = '', this.repetitions = 1});

  Set.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        intervals = (json['intervals'] as List<dynamic>)
            .map((intervalJson) => Interval.fromJson(intervalJson))
            .toList(),
        repetitions = json['repetitions'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'intervals': intervals.map((interval) => interval.toJson()).toList(),
      'repetitions': repetitions,
    };
  }
}

class Interval {
  String name = '';
  IntervalType type;
  int duration; // in seconds
  int reps;
  int repetitions = 1;

  Interval({
    this.type = IntervalType.time,
    this.duration = 0,
    this.reps = 0,
    this.name = '',
    this.repetitions = 1,
  });

  Interval.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        type = IntervalType.values[json['type']],
        duration = json['duration'],
        reps = json['reps'],
        repetitions = json['repetitions'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.index,
      'duration': duration,
      'reps': reps,
      'repetitions': repetitions,
    };
  }
}

enum IntervalType {
  time,
  reps,
}

class SetWidget extends StatefulWidget {
  final Set set;
  final VoidCallback onDelete;

  const SetWidget({Key? key, required this.set, required this.onDelete})
      : super(key: key);

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
      key: widget.key,
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: TextFormField(
              controller: _nameController,
              onChanged: (value) {
                setState(() {
                  widget.set.name = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Set Name',
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  widget.onDelete();
                });
              },
            ),
          ),
          Row(
            children: [
              Text('Repetitions:'),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _repetitionsController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      widget.set.repetitions = int.tryParse(value) ?? 1;
                    });
                  },
                ),
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
                        key: ValueKey(index),
                        interval: interval,
                        onDelete: () {
                          setState(() {
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
                final Interval interval =
                    widget.set.intervals.removeAt(oldIndex);
                widget.set.intervals.insert(newIndex, interval);
              });
            },
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.set.intervals.add(Interval(type: IntervalType.time));
                });
              },
              child: Text('Add Interval'),
            ),
          ),
        ],
      ),
    );
  }
}

class IntervalWidget extends StatefulWidget {
  final Interval interval;
  final VoidCallback onDelete;

  const IntervalWidget(
      {Key? key, required this.interval, required this.onDelete})
      : super(key: key);

  @override
  _IntervalWidgetState createState() => _IntervalWidgetState();
}

class _IntervalWidgetState extends State<IntervalWidget> {
  IntervalType selectedIntervalType = IntervalType.time;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _durationController = TextEditingController();
  TextEditingController _repsController = TextEditingController();
  TextEditingController _repetitionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedIntervalType = widget.interval.type;
    _nameController.text = widget.interval.name;
    _durationController.text = widget.interval.duration.toString();
    _repsController.text = widget.interval.reps.toString();
    _repetitionsController.text = widget.interval.repetitions.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: widget.key,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: TextFormField(
                controller: _nameController,
                onChanged: (value) {
                  setState(() {
                    widget.interval.name = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Interval Name',
                ),
              ),
            ),
            Row(
              children: [
                Text('Interval Type:'),
                SizedBox(width: 10),
                DropdownButton<IntervalType>(
                  value: selectedIntervalType,
                  onChanged: (IntervalType? newValue) {
                    setState(() {
                      selectedIntervalType = newValue!;
                      widget.interval.type = newValue;
                    });
                  },
                  items: IntervalType.values.map((IntervalType type) {
                    return DropdownMenuItem<IntervalType>(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (selectedIntervalType == IntervalType.time)
              Row(
                children: [
                  Text('Duration (seconds):'),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          widget.interval.duration = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            if (selectedIntervalType == IntervalType.reps)
              Row(
                children: [
                  Text('Reps:'),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          widget.interval.reps = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            Row(
              children: [
                Text('Repetitions:'),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _repetitionsController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        widget.interval.repetitions = int.tryParse(value) ?? 1;
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      widget.onDelete();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}