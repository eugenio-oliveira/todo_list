import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

void main(){
  runApp(
    MaterialApp(
      home: Home(),
    )
  );
}
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _toDoList = [];
  Map<String, dynamic> _lastItemRemoved;
  int _lastItemRemovedPos;

  final _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TODO LIST"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "New Task",
                      labelStyle: TextStyle(color: Colors.blueAccent),
                    ),
                    controller: _taskController,
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                itemBuilder: buildItem,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(context, index){
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
            child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (checked){
          setState(() {
            _toDoList[index]["ok"] = checked;
            _saveData();
          });
        },
      ),
      onDismissed: (direction){
        setState(() {
          _lastItemRemoved = Map.from(_toDoList[index]);
          _lastItemRemovedPos = index;
          _toDoList.removeAt(index);
          _saveData();
          final snackBar = SnackBar(
            content: Text("Task \"${_lastItemRemoved["title"]}\" deleted."),
            action: SnackBarAction(label: "Undo", onPressed: (){
              setState(() {
                _toDoList.insert(_lastItemRemovedPos, _lastItemRemoved);
                _saveData();
              });
            }),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        });
      },
    );
  }
  void _addTask(){
    setState(() {
      Map<String, dynamic> newTask = Map();
      newTask["title"] = _taskController.text;
      _taskController.text = "";
      newTask["ok"] = false;
      _toDoList.add(newTask);
      _saveData();
    });
  }


  @override
  void initState() {
    super.initState();
    _readData().then((data){
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  Future<File> _getFile() async{
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async{
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    }catch(exception){
      return null;
    }
  }

}



