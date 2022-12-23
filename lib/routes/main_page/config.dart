import 'package:flutter/material.dart';
const List<String> list = <String>['Selecione', 'One', 'Two', 'Three', 'Four'];
int order = 0;

void main() => runApp(const Conf());

class Conf extends StatelessWidget {
  const Conf({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        appBar: AppBar(title: const Center(child: Text('SquareCloud'))),
        body: const Center(
          child: Drop(),
        ),
      ),
    );
  }
}

class Drop extends StatefulWidget {
  const Drop({super.key});

  @override
  State<Drop> createState() => _Drop();
}

class _Drop extends State<Drop> {
  String dropdownValue = list.first;
  bool vs = false;
  bool isSwitched = false;
  bool swi = true;
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      DropdownButton<String>(
        value: dropdownValue,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        underline: Container(
          height: 2,
          color: const Color.fromARGB(255, 30, 89, 252),
        ),
        onChanged: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
            //order = int.parse(dropdownValue);
            vs = true;
          });
        },
        items: list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
        Align(
          alignment: const Alignment(-1, 0),
          child: Visibility(
          visible: vs,
          child: Switch(
            value: swi,
            inactiveThumbColor: const Color.fromARGB(255, 250, 38, 38),

            onChanged: (value) {
              setState(() {
                swi = value;
              });
            },
          ))
      ),
    ]);
  }
}
