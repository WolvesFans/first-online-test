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
  DateTime? transactionDate;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //select transaction date
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => pickTransactionDate(context),
                    child: const Text('Select Transaction Date'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    transactionDate != null ? DateFormat('yyyy-MM-dd').format(transactionDate!) : '',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              //save transaction date
              ElevatedButton(
                onPressed: () => generateTransactionNumber(transactionDate!),
                child: const Text('Save Date'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
