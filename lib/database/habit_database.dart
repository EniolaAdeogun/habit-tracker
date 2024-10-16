import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
static late Isar isar;



 /*

SETUP 

 */

// I N I T I A L I Z E - DATABASE 

static Future <void> initialize() async {

  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
[HabitSchema , AppSettingsSchema],

directory: dir.path

  );
}

// SAVE First date of app startup (for heatmap)
Future <void > saveFirstLaunchDate () async{
  final existingSettings = await isar.appSettings.where().findFirst();
  if (existingSettings == null ) {
    final settings = AppSettings()..firstLaunchDate = DateTime.now();
    await isar.writeTxn(()=> isar.appSettings.put(settings));
  }
}


// Get first date of app startup (for heatmap)

Future <DateTime?> getFirstLaunchDate () async {
final settings = await isar.appSettings.where().findFirst();
return  settings?.firstLaunchDate;

}


/*
C R U D x Operations
*/


// List of Habits
final List <Habit> currentHabits = [];

//C R E A T E - add a new habit 

Future<void> addHabit (String habitName) async {
  //create new habit 
final newHabit = Habit()..name = habitName;

//save to db 
await isar.writeTxn(()=> isar.habits.put(newHabit));

// re read from db 
readhabits();
}
// read - read saved habits from db 

Future <void> readhabits ()async {
  // fetch all habits from db 
List <Habit > fetchedHabits = await isar.habits.where().findAll();

// give to current Habits
currentHabits.clear();
currentHabits.addAll(fetchedHabits);

// update ui 

notifyListeners();

}

//update = check habit on And off

Future <void> updateHabitCompletion(int id , bool isCompleted) async {

  // find the specific habit
final habit = await isar.habits.get(id);

// update complettion status
if (habit != null ){
await isar.writeTxn(()async {
if (isCompleted && !habit.completedDays.contains(DateTime.now())){
  final today = DateTime.now();

  habit.completedDays.add(
    DateTime(
      today.year,
      today.month,
      today.day
    )
  );
}
 else { 
// remove the current date if the habit is marked as not completed

habit.completedDays.removeWhere((date)=> 
date.year == DateTime.now().year && 
date.month == DateTime.now().month &&
date.day == DateTime.now().day

);

 }

 await isar.habits.put(habit);
});

}

// re read from db

readhabits();
}

// UPDATE - EDIT HABIT NAME 

Future <void> updateHabitName (int id , String newName ) async {
final habit = await isar.habits.get(id);

if (habit !=  null){
  await isar.writeTxn(()async {

    habit.name = newName;
await isar.habits.put(habit);
  });
}

// re read from db 

readhabits();
}
  

  Future<void> deleteHabit(int id ) async {
    await isar.writeTxn(() async {
await isar.habits.delete(id);
    });

    readhabits();
    
  }
}

