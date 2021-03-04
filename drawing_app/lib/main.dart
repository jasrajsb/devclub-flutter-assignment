import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IITD Drawing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: listOfDrawings(),
    );
  }
}

// ignore: camel_case_types
class listOfDrawings extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return listOfDrawingsState();
  }

}

// ignore: camel_case_types
class listOfDrawingsState extends State{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: MyList(),
      ),
      appBar: AppBar(
        title: Text('DevClub IITD Drawing App'),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add",
        child: Icon(Icons.add),
        onPressed: () {

        },
      ),
    );
  }

}


class MyList extends StatefulWidget {
  MyList({Key key}) : super(key: key);

  @override
  MyListState createState() {
    return MyListState();
  }
}

class MyListState extends State<MyList> {
  final items = List<String>.generate(20, (i) => "Item ${i + 1}");

  @override
  Widget build(BuildContext context) {
    final title = 'Dismissing Items';

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Dismissible(
          // Each Dismissible must contain a Key. Keys allow Flutter to
          // uniquely identify widgets.
          key: Key(item),
          // Provide a function that tells the app
          // what to do after an item has been swiped away.
          onDismissed: (direction) {
            // Remove the item from the data source.
            setState(() {
              items.removeAt(index);
            });

            // Then show a snackbar.
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("$item dismissed")));
          },
          // Show a red background as the item is swiped away.
          background: Container(color: Colors.red),
          child: ListTile(title: Text('$item')),
        );
      },
    );
  }
}