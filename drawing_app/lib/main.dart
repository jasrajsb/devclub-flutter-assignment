import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
class listOfDrawings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return listOfDrawingsState();
  }
}

// ignore: camel_case_types
class listOfDrawingsState extends State {
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CanvasPage()),
          );
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

class CanvasPage extends StatefulWidget {
  @override
  createState() => new CanvasState();
}

class CanvasState extends State {
  List<Offset> _points = <Offset>[];
  var showCanvas=true;
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        setState(() {
          showCanvas = true;
        });
      },
      child: new Scaffold(
//      appBar: AppBar(title:Text("Drawing Screen"),),
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            new Container(
              height: showCanvas?MediaQuery.of(context).size.height*0.9:50,//MediaQuery.of(context).size.height * 0.9,
              child: new GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    RenderBox object = context.findRenderObject();
                    Offset _localPosition =
                        object.globalToLocal(details.globalPosition);
                    print(_localPosition.dy);
                    print(MediaQuery.of(context).size.height * 0.9);
                    if(_localPosition.dy<MediaQuery.of(context).size.height * 0.9){
                    _points = new List.from(_points)..add(_localPosition);}
                  });
                },
                onPanEnd: (DragEndDetails details) => _points.add(null),
                child: Container(
                  height:MediaQuery.of(context).size.height * 0.9,
                  child: new CustomPaint(
                      painter: new Signature(points: _points),
                      size: Size(
                        MediaQuery.of(context).size.width * 1,
                        MediaQuery.of(context).size.height * 0.9,
                      )),
                ),
              ),
            ),
            Row(
              children: [
                new Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.only(
                          ),
                      child: TextField(
                        onTap: (){
                          setState(() {
                            showCanvas=false;
                          });
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter File Name here'
                                ' '),
                      ),
                    ),
                  ),
                ),
                FlatButton(
                  child: Text("Save"),
                  onPressed: () {
                    print(_points);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FlatButton(
                    child: Text("Clear"),
                    onPressed: () {
                      _points.clear();
                    },
                  ),
                )
              ],
            ),
          ],
        ),
//      floatingActionButton: new FloatingActionButton(
//        child: new Icon(Icons.clear),
//        onPressed: () => _points.clear(),
//      ),
      ),
    );
  }
}

class Signature extends CustomPainter {
  List<Offset> points;

  Signature({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;
}
