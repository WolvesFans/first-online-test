import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_online/screen/task1.dart';
import 'package:test_online/screen/task2.dart';
import 'package:test_online/screen/task3.dart';
import 'package:test_online/screen/task4.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 60,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.task),
              label: 'Task 1',
            ),
            NavigationDestination(
              icon: Icon(Icons.task),
              label: 'Task 2',
            ),
            NavigationDestination(
              icon: Icon(Icons.task),
              label: 'Task 3',
            ),
            NavigationDestination(
              icon: Icon(Icons.task),
              label: 'Task 4',
            ),
          ],
        ),
      ),
      body: Obx(
        () => controller.screens[controller.selectedIndex.value],
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const Task1(),
    const Task2(),
    const Task3(),
    const Task4(),
  ];
}
