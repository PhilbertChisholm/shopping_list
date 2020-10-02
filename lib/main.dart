import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MaterialApp(
    title: "Shopping List App with Re-orderable Lists & Swipe Cards",
    home: App(),
  ));
}

class ListItem {
  String itemText;
  bool todoCheck;
  ListItem(this.itemText, this.todoCheck);
}

class _strikeThrough extends StatelessWidget {
  final String itemText;
  final bool todoCheck;
  _strikeThrough(this.itemText, this.todoCheck) : super();

  Widget _widget() {
    if (todoCheck) {
      return Text(
        itemText,
        style: TextStyle(
          decoration: TextDecoration.lineThrough,
          fontStyle: FontStyle.italic,
          fontSize: 22.0,
          color: Colors.red[200],
        ),
      );
    } else {
      return Text(
        itemText,
        style: TextStyle(fontSize: 22.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _widget();
  }
}

class App extends StatefulWidget {
  @override
  AppState createState() {
    return AppState();
  }
}

class AppState extends State<App> with WidgetsBindingObserver {
  var textController = TextEditingController();
  var popUpTextController = TextEditingController();
  bool isActive = false;
  List<ListItem> WidgetList = [];

  @override
  void dispose() {
    textController.dispose();
    popUpTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor('#000080'),
      appBar: AppBar(
        title: Text(
          "My Supermarket Shopping List",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: hexToColor('#000080'),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Plus to add new item",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "After typing press Add",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ), //to show the
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(60)),
                    color: Colors.white),
                child: Column(
                  children: [
                    Container(
                      width: 300.0,
                      child: TextField(
                        enabled: isActive,
                        decoration:
                        InputDecoration(hintText: "Enter Text Here"),
                        style: TextStyle(
                          fontSize: 22.0,
                          //color: Theme.of(context).accentColor,
                        ),
                        controller: textController,
                        cursorWidth: 3.0,
                        autocorrect: true,
                        autofocus: true,
                        //onSubmitted: ,
                      ),
                    ),
                    RaisedButton(
                      color: Colors.blue,
                      child: Text("Add"),
                      onPressed: () {
                        if (textController.text.isNotEmpty) {
                          WidgetList.add(
                              new ListItem(textController.text, false));
                          setState(() {
                            textController.clear();
                            isActive = false;
                          });
                        }
                      },
                    ),
                    Expanded(
                      child: ReorderableListView(
                        children: <Widget>[
                          for (final widget in WidgetList)
                            GestureDetector(
                              key: Key(widget.itemText),
                              child: Dismissible(
                                key: Key(widget.itemText),
                                child: CheckboxListTile(
                                  //key: ValueKey("Checkboxtile $widget"),
                                  value: widget.todoCheck,
                                  title: _strikeThrough(
                                      widget.itemText, widget.todoCheck),
                                  onChanged: (checkValue) {
                                    //_strikethrough toggle
                                    setState(() {
                                      if (!checkValue) {
                                        widget.todoCheck = false;
                                      } else {
                                        widget.todoCheck = true;
                                      }
                                    });
                                  },
                                ),
                                background: Container(
                                  child: Icon(Icons.delete),
                                  alignment: Alignment.centerRight,
                                  color: Colors.red[300],
                                ),
                                confirmDismiss: (dismissDirection) async {
                                  return await showDialog(
                                    //On Dismissing
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Delete Item?"),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text("OK"),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                            ), //OK Button
                                            FlatButton(
                                              child: Text("Cancel"),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                            ), //Cancel Button
                                          ],
                                        );
                                      });
                                },
                                direction: DismissDirection.endToStart,
                                movementDuration:
                                const Duration(milliseconds: 200),
                                onDismissed: (dismissDirection) {
                                  //Delete Todo
                                  WidgetList.remove(widget);
                                  Fluttertoast.showToast(msg: "Item Deleted!");
                                },
                              ),
                              onDoubleTap: () async {
                                popUpTextController.text = widget.itemText;
                                //For Editing Todo
                                return await showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Edit Item"),
                                        content: TextFormField(
                                          controller: popUpTextController,
                                        ),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text("OK"),
                                            onPressed: () {
                                              setState(() {
                                                widget.itemText =
                                                    popUpTextController.text;
                                              });
                                              Navigator.of(context).pop(true);
                                            },
                                          ), //OK Button
                                          FlatButton(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ), //Cancel Button
                                        ],
                                      );
                                    });
                              },
                            )
                        ],
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            var replaceWiget = WidgetList.removeAt(oldIndex);
                            WidgetList.insert(newIndex, replaceWiget);
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          ]),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(
                'MENU',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              decoration: BoxDecoration(
                color: hexToColor('#000080'),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text('My Bio'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => bioPage()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          setState(() {
            isActive = true;
          });
        },
      ),
    );
  }
}

class bioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexToColor('#000080'),
      appBar: AppBar(
        title: Text("My Supermarket Shopping List"),
        backgroundColor: hexToColor('#000080'),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Image(
                  image: AssetImage('images/pngegg.png'),
                  height: 100,
                  width: 100,
                ),
              ),
            ],
          ), //to show the
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(60)),
                    color: Colors.white),
                child: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.fromLTRB(20, 20, 20, 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(30)),
                            color: Colors.blueAccent),
                        child: Column(
                          children: [
                            Text(
                              "Done by Philbert Chihsolm",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "N.B. Main concept for from Github creator",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200),
                            ),
                          ],
                        )),
                    Container(
                      padding: EdgeInsets.all(3),
                      margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
                      color: Colors.green,
                      child: Column(
                        children: [
                          Text(
                            "-Started programming in 2011,\n"
                                "-Currently Studying Computer Information Systems At the Norther Caribbean University\n"
                                "-Verse in several programming Languages\n"
                                "\tThese include:\n"
                                "\t -pascal\n"
                                "\t -C\n"
                                "\t -C++\n"
                                "\t -C#\n"
                                "\t -Java\n"
                                "\t -JSP\n"
                                "\t -PHP\n"
                                "\t -JavaScript\n"
                                "-Programming Languages Being Learnedn\n"
                                "\t -Python\n"
                                "\t -Flutter/Dart\n"
                                "\t -ASP.net\n",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          Text(
                            "Assignment 1",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}