import 'package:flutter/material.dart';

import 'data/database/database_initializer.dart';
import 'features/products/presentation/products_page.dart';

void main() {
  initializeDatabase();

  runApp(const SalesManagementApp());
}

class SalesManagementApp extends StatelessWidget {
  const SalesManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sales Management System',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const ProductsPage(),
    );
  }
}