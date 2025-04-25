import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Task2 extends StatefulWidget {
  const Task2({super.key});

  @override
  State<Task2> createState() => _Task2State();
}

class _Task2State extends State<Task2> {
  List<Map<String, dynamic>> transaction = [];
  List<Map<String, dynamic>> filteredTransaction = [];
  DateTime? transactionDate;
  int currentPage = 1;
  final int itemsPerPage = 10;
  String globalSearchQuery = '';
  String dateSearchQuery = '';
  String transactionNumberQuery = '';
  String? sortColumn;
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  //retrieve data from database
  Future<void> fetchTransactions() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Transaction Test 2').orderBy('Transaction Date', descending: true).get();
    setState(() {
      transaction = snapshot.docs.map((docs) => docs.data() as Map<String, dynamic>).toList();
      filteredTransaction = transaction;
      currentPage = 1;
      sortColumn = null;
      sortAscending = true;
    });
  }

  //pick new transaction date
  Future<void> pickTransactionDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2002),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != transactionDate) {
      setState(() {
        transactionDate = picked;
      });
    }
  }

  //generate transaction number based on transaction date
  Future<void> generateTransactionNumber(DateTime date) async {
    String yearMonth = DateFormat('yyMM').format(date);
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Transaction Test 2').where('Year and Month', isEqualTo: yearMonth).get();
    int transactionCount = snapshot.docs.length;
    int newNumber = transactionCount + 1;
    String formattedNumber = newNumber.toString().padLeft(4, '0');
    String transactionNumber = 'MSK/$yearMonth/$formattedNumber';
    await FirebaseFirestore.instance.collection('Transaction Test 2').add({
      'Transaction Date': DateFormat('yyyy-MM-dd').format(date),
      'Transaction Number': transactionNumber,
      'Year and Month': yearMonth,
    });
    setState(() {
      transactionDate = null;
    });
    fetchTransactions();
  }

  //count total pages
  int get totalPages => (filteredTransaction.length / itemsPerPage).ceil();

  //take data for particular page
  List<Map<String, dynamic>> get paginatedTransactions {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > filteredTransaction.length) endIndex = filteredTransaction.length;
    return filteredTransaction.sublist(startIndex, endIndex);
  }

  //filter data from search
  void filterAndSortTransaction() {
    setState(() {
      //filter data from search query
      var tempFiltered = transaction.where((transaction) {
        bool globalSearch = globalSearchQuery.isEmpty ||
            transaction['Transaction Date'].toLowerCase().contains(globalSearchQuery.toLowerCase()) ||
            transaction['Transaction Number'].toLowerCase().contains(globalSearchQuery.toLowerCase());
        bool dateSearch = dateSearchQuery.isEmpty ||
            transaction['Transaction Date'].toLowerCase().contains(
                  dateSearchQuery.toLowerCase(),
                );
        bool transactionNumberSearch = transactionNumberQuery.isEmpty ||
            transaction['Transaction Number'].toLowerCase().contains(
                  transactionNumberQuery.toLowerCase(),
                );
        return globalSearch && dateSearch && transactionNumberSearch;
      }).toList();

      //sort data
      if (sortColumn != null) {
        tempFiltered.sort((a, b) {
          if (sortColumn == 'Transaction Date') {
            return sortAscending ? a['Transaction Date'].compareTo(b['Transaction Date']) : b['Transaction Date'].compareTo(a['Transaction Date']);
          } else if (sortColumn == 'Transaction Number') {
            return sortAscending
                ? a['Transaction Number'].compareTo(
                    b['Transaction Number'],
                  )
                : b['Transaction Number'].compareTo(
                    a['Transaction Number'],
                  );
          }
          return 0;
        });
      }
      filteredTransaction = tempFiltered;
      currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Task 2'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //search bar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //search title
                  Text(
                    'Search: ',
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
                      onChanged: (value) {
                        globalSearchQuery = value;
                        filterAndSortTransaction();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              //select transaction date
              ElevatedButton(
                onPressed: () => pickTransactionDate(context),
                child: const Text('Select Transaction Date'),
              ),

              //selected date
              Text(
                transactionDate != null ? DateFormat('yyyy-MM-dd').format(transactionDate!) : '',
              ),

              //save transaction date
              ElevatedButton(
                onPressed: () => generateTransactionNumber(transactionDate!),
                child: const Text('Save Date'),
              ),

              //data table
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Column(
                          children: [
                            const Text('Tanggal'),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 20,
                              width: 100,
                              child: TextField(
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search Tanggal',
                                  hintStyle: Theme.of(context).textTheme.bodySmall!.apply(color: Colors.grey[400]),
                                ),
                                onChanged: (value) {
                                  dateSearchQuery = value;
                                  filterAndSortTransaction();
                                },
                              ),
                            )
                          ],
                        ),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            sortColumn = 'Transaction Date';
                            sortAscending = ascending;
                            filterAndSortTransaction();
                          });
                        },
                      ),
                      DataColumn(
                        label: Column(
                          children: [
                            const Text('Nomor Urut'),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 20,
                              width: 100,
                              child: TextField(
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search Nomor Urut',
                                  hintStyle: Theme.of(context).textTheme.bodySmall!.apply(color: Colors.grey[400]),
                                ),
                                onChanged: (value) {
                                  transactionNumberQuery = value;
                                  filterAndSortTransaction();
                                },
                              ),
                            )
                          ],
                        ),
                        onSort: (columnIndex, ascending) {
                          setState(() {
                            sortColumn = 'Transaction Number';
                            sortAscending = ascending;
                            filterAndSortTransaction();
                          });
                        },
                      ),
                    ],
                    sortColumnIndex: sortColumn == 'Transaction Date' ? 0 : sortColumn == 'Transaction Number' ? 1 : null,
                    sortAscending: sortAscending,
                    rows: paginatedTransactions.map((transaction) {
                      return DataRow(cells: [
                        DataCell(Text(transaction['Transaction Date'])),
                        DataCell(Text(transaction['Transaction Number'])),
                      ]);
                    }).toList(),
                  ),
                ),
              ),

              //pagination
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${(currentPage - 1) * itemsPerPage + 1} to ${currentPage * itemsPerPage > filteredTransaction.length ? filteredTransaction.length : currentPage * itemsPerPage} of ${filteredTransaction.length} entries',
                  ),
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
                        icon: const Icon(Icons.arrow_right),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
