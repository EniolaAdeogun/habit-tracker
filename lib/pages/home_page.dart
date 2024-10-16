
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/utilites/habit_util.dart';

import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

@override
  void initState() {
    // read existing habits on app startup
    Provider.of<HabitDatabase>(context , listen:false).readhabits();
    super.initState();
  }

  //check habit on and off

  void checkHabitOnOff(bool ? value , Habit habit){
// update habit completition status

if (value != null){
context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
}
  }


// edit habit box
void editHabitBox(Habit habit){
  textController.text = habit.name;

  showDialog(
    context: context, 
    builder: (context)=> AlertDialog(
content: TextField(controller: textController,
),
actions: [
 MaterialButton(onPressed: (){
    // get the new habit name
    String newHabitName = textController.text;

    // save to db 

    context.read<HabitDatabase>().updateHabitName(habit.id , newHabitName);

    // pop box 

    Navigator.pop(context);

    // clear controller
textController.clear();


  },
  child: const Text('save'),
  
  ),

  // cancel button 

  MaterialButton(onPressed: (){
    Navigator.pop(context);

    // clear button 

    textController.clear();

  }, 

  child: const Text('Cancel'),
  
  )
],

    ));
}
// text controller 
final TextEditingController textController = TextEditingController();

// create new habit
void createNewHabit (){
  showDialog(context: context, builder: (context) => AlertDialog(
content:  TextField(

  controller: textController,
  decoration: InputDecoration(
    hintText: 'Create a new habit '
  ),
),
actions: [
  // save button 
  MaterialButton(onPressed: (){
    // get the new habit name
    String newHabitName = textController.text;

    // save to db 

    context.read<HabitDatabase>().addHabit(newHabitName);

    // pop box 

    Navigator.pop(context);

    // clear controller
textController.clear();


  },
  child: const Text('save'),
  
  ),

  // cancel button 

  MaterialButton(onPressed: (){
    Navigator.pop(context);

    // clear button 

    textController.clear();

  }, 

  child: const Text('Cancel'),
  
  )
],

  ));
}
 // delete habit

 void deleteHabitBox(Habit habit){
  showDialog(
    context: context, 
    builder: (context)=> AlertDialog(
title: const Text('Are you sure you want to delete'),
actions: [
 MaterialButton(onPressed: (){
   

    // save to db 

    context.read<HabitDatabase>().deleteHabit(habit.id );

    // pop box 

    Navigator.pop(context);

    


  },
  child: const Text('Delete'),
  
  ),

  // cancel button 

  MaterialButton(onPressed: (){
    Navigator.pop(context);

   
  }, 

  child: const Text('Cancel'),
  
  )
],

    ));
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(onPressed: createNewHabit,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      child: const Icon(Icons.add , color: Colors.green,),
      
      ),
      body:  ListView(
        children: [

          //HEAT MAP 
_buildHeatMap(),

          // HABIT LIST
          _buildHabitList()
        ],
      ),
    );
  }


  Widget _buildHeatMap(){
 // habit database 

 final habitDatabase = context.watch<HabitDatabase>();

// current habits

List<Habit> currentHabits = habitDatabase.currentHabits;

// return heat map ui 

return FutureBuilder<DateTime?>
(future: habitDatabase.getFirstLaunchDate(),
 builder: (context , snapshot) {
  // once the data is available -> build heatmap

  if (snapshot.hasData){
    return MyHeatMap(startDate: snapshot.data!, datasets: prepHeatMapDataset(currentHabits));
  }

  // handle case where no data is returned 
  else {
    return Container();
  }
 }
 );

  }

  Widget _buildHabitList(){
// habit db 
 final habitDatabase = context.watch<HabitDatabase>();

//current habits
List<Habit> currentHabits = habitDatabase.currentHabits;


// return List of habits ui 

return ListView.builder(
  itemCount: currentHabits.length,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemBuilder: (context , index){

  final habit = currentHabits[index];

  bool isCompletedToday = isHabitCompletedToday(habit.completedDays);


  return MyHabitTile(
    isCompleted: isCompletedToday, 
  text: habit.name,
  onChanged: (value) => checkHabitOnOff(value , habit),
  editHabit: (context)=> editHabitBox(habit),
  deleteHabit: (context) => deleteHabitBox(habit),
  
  );
});
  }
}