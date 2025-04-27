import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Task3 extends StatefulWidget {
  const Task3({super.key});

  @override
  State<Task3> createState() => _Task3State();
}

class _Task3State extends State<Task3> {
  List<Map<String, dynamic>> paths = [];
  List<Map<String, dynamic>> filteredPaths = [];
  int currentPage = 1;
  final int itemsPerPage = 10;
  String searchQuery = '';
  final TextEditingController childController = TextEditingController();
  final TextEditingController parentController = TextEditingController();
  String? selectedParent;

  @override
  void initState() {
    super.initState();
    fetchPaths();
  }

  //fetching paths
  Future<void> fetchPaths() async {
    //retrieve data from database
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Path Test 3-4').orderBy('Created At', descending: true).get();
    List<Map<String, dynamic>> allPaths = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();

    //generate full path
    List<Map<String, dynamic>> fullPaths = [];
    for (var path in allPaths) {
      String fullPath = await buildFullPath(path['Parent'], path['Child']);
      fullPaths.add({
        'Id': path['Id'],
        'Full Path': fullPath,
        'Parent': path['Parent'],
        'Child': path['Child'],
      });
    }

    setState(() {
      paths = fullPaths;
      filteredPaths = paths;
      currentPage = 1;
    });
  }

  //build full path
  Future<String> buildFullPath(String? parent, String child) async {
    if (parent == null) return child;
    List<String> pathSegments = [child];
    String? currentParent = parent;
    while (currentParent != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Path Test 3-4')
          .where('Child', isEqualTo: currentParent.split('/').last)
          .get();
      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        pathSegments.insert(0, doc['Child']);
        currentParent = doc['Parent'];
      } else {
        break;
      }
    }
    return pathSegments.join('/');
  }

  //add child
  Future<void> addChild(String childName, String? parent) async {
    //validate input: letter, number, space
    RegExp regex = RegExp(r'^[a-zA-Z0-9\s]+$');
    if (!regex.hasMatch(childName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only letter, number, and space allowed!'),
        ),
      );
      return;
    }
    await FirebaseFirestore.instance.collection('Path Test 3-4').add({
      'Parent': parent,
      'Child': childName.toLowerCase(),
      'Created At': FieldValue.serverTimestamp(),
    });
    childController.clear();
    parentController.clear();
    selectedParent = null;
    fetchPaths();
  }

  //filter data from search
  void filterPaths() {
    setState(() {
      //filter data from search query
      if (searchQuery.isEmpty) {
        filteredPaths = paths;
      } else {
        filteredPaths = paths.where((path) {
          return path['Full Path'].toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }
      currentPage = 1;
    });
  }

  //count total pages
  int get totalPages => (filteredPaths.length / itemsPerPage).ceil();

  //take data for particular page
  List<Map<String, dynamic>> get paginatedPaths {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > filteredPaths.length) endIndex = filteredPaths.length;
    return filteredPaths.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Task 3'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(width: double.infinity),
              //search bar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //search title
                  const Text('Search:'),
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
                      onChanged: (value) {
                        searchQuery = value;
                        filterPaths();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              //table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Path')),
                  ],
                  rows: paginatedPaths.map((path) {
                    return DataRow(cells: [
                      DataCell(
                        Text(path['Full Path']),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              //pagination
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //text
                  Text(
                    'Showing ${(currentPage - 1) * itemsPerPage + 1} to ${currentPage * itemsPerPage > filteredPaths.length ? filteredPaths.length : currentPage * itemsPerPage} of ${filteredPaths.length} entries',
                  ),

                  //page number
                  Row(
                    children: [
                      IconButton(
                        onPressed: currentPage > 1
                            ? () {
                                setState(() {
                                  currentPage--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.arrow_left_sharp),
                      ),
                      Text('$currentPage / $totalPages'),
                      IconButton(
                        onPressed: currentPage < totalPages
                            ? () {
                                setState(() {
                                  currentPage++;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.arrow_right_sharp),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),

              //input parent
              Row(
                children: [
                  const Text('Parent Name'),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return paths.map((path) => path['Full Path'] as String).where((fullPath) => fullPath.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        setState(() {
                          selectedParent = selection;
                          parentController.text = selection;
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        parentController.text = selectedParent ?? '';
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onSubmitted: (value) => onFieldSubmitted(),
                          decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          )),
                        );
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),

              //input child
              Row(
                children: [
                  const Text('Child Name'),
                  const SizedBox(width: 18),
                  Expanded(
                    child: TextField(
                      controller: childController,
                      decoration: InputDecoration(
                        hintText: 'Letter, Number, and Space allowed',
                        hintStyle: Theme.of(context).textTheme.bodyMedium!.apply(color: Colors.grey[400]),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),

              //save button
              ElevatedButton(
                onPressed: () {
                  if (childController.text.isNotEmpty) {
                    addChild(childController.text, selectedParent);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
