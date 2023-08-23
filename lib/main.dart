import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'listitem.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

void main() {
  runApp(const ToDoListApp());
}

class ToDoListApp extends StatelessWidget {
  const ToDoListApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Add TODO"),
          ),
          body: const MyToDoListApp(),
        )
    );
  }
}

class MyToDoListApp extends StatefulWidget {
  const MyToDoListApp({super.key});

  @override
  State<MyToDoListApp> createState() => _MyToDoListAppState();
}

class _MyToDoListAppState extends State<MyToDoListApp> {
  List<ListItem>? items = [];
  var _controller = TextEditingController();
  bool? _isTextfieldVisible;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isTextfieldVisible = true;
    _loadItemsFromSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Column(
          children: [
            _addToDo(),
            _mainList(),
            _bottomTab()
          ],
        ),
      ),
    );
  }

  Future<void> _saveItemsToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final itemListJson = json.encode(items?.map((item) => item.toJson()).toList());
    prefs.setString('itemList', itemListJson);
  }

  Future<void> _loadItemsFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final itemListJson = prefs.getString('itemList');
    if (itemListJson != null) {
      List<Map<String, dynamic>> itemListData = List<Map<String, dynamic>>.from(json.decode(itemListJson));
      items = itemListData.map((itemData) => ListItem.fromJson(itemData)).toList();
    } else {
      items = [
        ListItem(title: "Morning run", dateOfCreation: DateTime.now().toString()),
        ListItem(title: "Pay bills", dateOfCreation: DateTime.now().toString()),
      ];
    }
  }

  Widget _addToDo() {
    return Visibility(
      visible: _isTextfieldVisible ?? false,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: TextField(
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter here',
              suffixIcon: GestureDetector(child: Icon(Icons.cancel), onTap: (){
                _controller.clear();
                setState(() {
                  _isTextfieldVisible = false;
                });
              })
          ),
          controller: _controller,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            setState(() {
              var newItem = ListItem(title: value, isChecked: false, dateOfCreation: DateTime.now().toString());
              items?.add(newItem);
              _controller.clear();
              _saveItemsToSharedPreferences();
            });
          },
        ),
      ),
    );
  }

  Widget _mainList() {
    return Expanded(
      child: ListView.builder(
          itemCount: items?.length,
          itemBuilder: (context, index){
            return CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.deepPurpleAccent,
                side: const BorderSide(color: Colors.deepPurpleAccent),
                title: Text(items?[index].title ?? "title",
                  style: TextStyle(
                      color: Colors.deepPurpleAccent,
                      decoration: items?[index].isChecked ?? false ? TextDecoration.lineThrough : TextDecoration.none),
                ),
                secondary: Text(DateFormat('kk:mm a').format(DateTime.parse(items?[index].dateOfCreation ?? DateTime.now().toString()))),
                value: items?[index].isChecked,
                onChanged: (bool? val){
                  setState(() {
                    items?[index].isChecked = val ?? false;
                    items?.sort((a, b) => a.isChecked ? 1 : -1);
                  });
                });
          }),
    );
  }

  Widget _bottomTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text('${items?.length.toString()} tasks'.toUpperCase(),
                  style: const TextStyle(color: Colors.deepPurpleAccent),),
              ),
              ElevatedButton(
                child: const Align(
                  alignment: Alignment.topLeft,
                  child: Text('ADD NEW +'),
                ),
                onPressed: () {
                  setState(() {
                    _isTextfieldVisible = true;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
