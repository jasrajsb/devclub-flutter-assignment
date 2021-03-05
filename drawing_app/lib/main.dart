import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

resolveOffset(arr){
  List<Offset> arrd=[];
  for(var offset in arr){

    offset = offset??"Offset(0,0)";
    if(offset !='null'){
      arrd.add(Offset(double.parse(offset.split("(")[1].split(",")[0]),double.parse(offset.split(",")[1].split(")")[0])));
    } else{
      arrd.add(null);
    }
  }
  return arrd;
}

Future<SharedPreferences> _prefs;
SharedPreferences prefs ;
var list;
var dataArr=[];
List <List<Offset>>points;
getItems() async {
  _prefs = SharedPreferences.getInstance();
  prefs = await _prefs;
  var data2 = prefs.getString("data");
  var data = jsonDecode(data2);
  dataArr = data;
  var arr=[];
  points=[];
  for(var drawing in data){
    if(!(drawing == null)){
      arr.add(drawing["name"]);
      points.add(resolveOffset(drawing["points"]));
    }
  }

  list=arr;
  return arr;
}
getItems2(data2) async {
  var data = jsonDecode(data2);
  dataArr = data;
  var arr=[];
  points=[];
  for(var drawing in data){
    if(!(drawing == null)){
      arr.add(drawing["name"]);
      points.add(resolveOffset(drawing["points"]));
    }
  }

  list=arr;
  return arr;
}

void main() async {
  runApp(MyApp(list));
}

class MyApp extends StatelessWidget {
  @override
  var list=[];
  MyApp(listVar) {
    list=listVar;
  }

  Widget build(BuildContext context)  {

    return MaterialApp(
      title: 'IITD Drawing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: listOfDrawings(list),
    );
  }
}

// ignore: camel_case_types
class listOfDrawings extends StatefulWidget {
  @override
  var list=[];
  listOfDrawings(listVar){
    list = listVar;
  }
  State<StatefulWidget> createState() {
    return listOfDrawingsState(list);
  }
}
var _reloader;
// ignore: camel_case_types
class listOfDrawingsState extends State {
  var list = [];
  listOfDrawingsState(listVar){
    list = listVar;
  }

  _getList() async {
    var _items = await getItems();
    setState((){
      print(_items);
      list = _items;
    });
  }

  initState() {

    setState(()  {
      _getList();
    });

  }
  @override
  Widget build(BuildContext context) {
     _reloader = (){
      _getList();
    };
    print('78');
    print(list);
    return Scaffold(
      body: Container(
        child: MyList(_reloader),
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
            MaterialPageRoute(builder: (context) => CanvasPage(points.length)),
          );
        },
      ),
    );
  }
}

class MyList extends StatefulWidget {
  var _reloader;
  MyList(rdr){
    _reloader = rdr;
  }


  @override
  createState()  {
    print('112');
    return MyListState();
  }
}

class MyListState extends State<MyList> {

  final itemsa = List<String>.generate(20, (i) => "Item ${i + 1}");
  @override

  Widget build(BuildContext context) {
    var items = list??[];
    print(126);
    print(items);
    final title = 'Dismissing Items';

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return GestureDetector(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CanvasPage((index))),
            );

          },
          child: Dismissible(

            key: Key(item),

            onDismissed: (direction) async {
              print(index);
              setState(() {
                items.removeAt(index);
                points.removeAt(index);
                dataArr.removeAt(index);

              });
              _prefs = SharedPreferences.getInstance();
              prefs = await _prefs;
              var str = prefs.getString("data")??'[]';
              var arr = jsonDecode(str);
//              print (arr[6]);
              arr.removeAt(index);
  //            print (arr[6]);
              prefs.setString("data", jsonEncode(arr));
              // Then show a snackbar.
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("$item dismissed")));
            },
            // Show a red background as the item is swiped away.
            background: Container(color: Colors.red),
            child: ListTile(title: Text('$item')),
          ),
        );
      },
    );
  }
}

class CanvasPage extends StatefulWidget {
  @override
  var p,   _reloader;
  CanvasPage(i, ){
    p=i;

  }


  createState() => new CanvasState(p);
}

class CanvasState extends State {
  var index;
  bool isNewDoc;
  CanvasState(inde){
    index=inde;
     isNewDoc = index==points.length;
    if(!isNewDoc){
      tec.text = list[index];
    }
  }

  var showCanvas=true;
  bool coolDown = false;
  List<Offset> _points = [];

  var tec = TextEditingController();
  Widget build(BuildContext context) {


    if(!isNewDoc){
      _points.addAll(points[index]??[]);
      _points.add(null);
    }

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
                  if(isNewDoc){
                    setState(() {
                      RenderBox object = context.findRenderObject();
                      Offset _localPosition =
                      object.globalToLocal(details.globalPosition);
                      print(_localPosition.dy);
                      print(MediaQuery.of(context).size.height * 0.9);
                      if(_localPosition.dy<MediaQuery.of(context).size.height * 0.9){
                        _points = new List.from(_points)..add(_localPosition);}
                    });
                  } else{
                    if(!coolDown){
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Drawing cannot be edited.")));
                      coolDown = true;
                      Future.delayed(const Duration(milliseconds: 5000),(){
                        coolDown = false;
                      });
                    }
                  }

                },

                onPanEnd: (DragEndDetails details) {if(isNewDoc)return _points.add(null);},
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
                        controller: tec,
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
                  onPressed: () async {
                    print(_points);
                    _prefs = SharedPreferences.getInstance();
                    prefs = await _prefs;
                    var str = prefs.getString("data")??'[]';
                    var arr = jsonDecode(str);
                    var _newpoints = [];
                    for(var point in _points){
                      _newpoints.add(point.toString());
                    }
                    if(!isNewDoc){
                      print("saving new doc...");
                      arr[index] = ({
                        "name": tec.text,
                        "points":_newpoints,
                        "id": DateTime.now().millisecondsSinceEpoch,
                      });
                    } else{
                      print(tec.text=='');
                      var name = tec.text!=''?tec.text:"doc "+(DateTime.now().millisecondsSinceEpoch.toString());
                      arr.add({

                        "name":name,
                        "points":_newpoints,
                        "id": DateTime.now().millisecondsSinceEpoch,
                      });
                    }

                    print(jsonDecode(str));
                    prefs.setString("data", jsonEncode(arr));
                    getItems2( jsonEncode(arr));
                    _reloader();
                    Navigator.pop(context);
                  },
                ),
                isNewDoc?Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FlatButton(
                    child: Text("Clear"),
                    onPressed: () {
                      _points.clear();
                    },
                  ),
                ):Container()
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
