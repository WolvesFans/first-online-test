import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Task1 extends StatefulWidget {
  const Task1({super.key});

  @override
  State<Task1> createState() => _Task1State();
}

class _Task1State extends State<Task1> {
  Map<String, List<String>> groupedNames = {};
  List<String> allNames = [];
  List<String> filteredAllNames = [];
  bool showGroupedList = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchAndGroupNames();
  }

  Future<void> fetchAndGroupNames() async {
    //retrieve data
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Nama Test 1').get();
    List<String> names = snapshot.docs.map((document) => document['Nama'] as String).toList();

    //list a-z letter
    Map<String, List<String>> firstLetterGroup = {};
    for (var letter in List.generate(26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index))) {
      firstLetterGroup[letter] = [];
    }

    //group first letter name with looping
    for (String name in names) {
      String firstLetter = name[0].toUpperCase();
      if (!firstLetterGroup.containsKey(firstLetter)) {
        firstLetterGroup[firstLetter] = [];
      }
      firstLetterGroup[firstLetter]!.add(name);
    }

    //sort first letter
    var sortedKeys = firstLetterGroup.keys.toList()..sort();
    Map<String, List<String>> sortedGrouped = {for (var key in sortedKeys) key: firstLetterGroup[key]!};

    setState(() {
      allNames = names;
      filteredAllNames = names;
      groupedNames = sortedGrouped;
    });
  }

  void filterSearchNames(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredAllNames = allNames;
      } else {
        filteredAllNames = allNames.where((name) => name.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Task 1'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: double.infinity),
              //search bar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //text
                  Text(
                    'Search:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 8),

                  //search bar
                  SizedBox(
                    width: 150,
                    child: TextField(
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      onChanged: (value) => filterSearchNames(value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              //just name list
              if (allNames.isNotEmpty) ...[
                Text(
                  'All Names',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: filteredAllNames.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredAllNames[index]),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              //toggle grouped list
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showGroupedList = !showGroupedList;
                  });
                },
                child: Text(
                  showGroupedList ? 'Hide Grouped List' : 'Show Grouped List',
                ),
              ),
              const SizedBox(height: 32),

              //first letter name list
              if (showGroupedList)
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: groupedNames.keys.length,
                  itemBuilder: (context, index) {
                    String firstLetter = groupedNames.keys.elementAt(index);
                    List<String> names = groupedNames[firstLetter]!;
                    return ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        firstLetter,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      children: names.map((name) {
                        return ListTile(
                          title: Text(name),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
