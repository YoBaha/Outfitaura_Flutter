import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/users_view_model.dart';
import '../widgets/sidebar.dart';
import './send_email_page.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsersViewModel()..fetchUsers(),
      child: Scaffold(
        body: Row(
          children: [
            const Sidebar(),
            Expanded(
              child: Container(
                color: const Color(0xFFDDEAE0),
                padding: const EdgeInsets.all(16.0),
                child: Consumer<UsersViewModel>(
                  builder: (context, viewModel, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Management',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007180),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Search Field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search users by name...',
                                    prefixIcon: const Icon(Icons.search, color: Color(0xFF007180)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFF007180)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFF4ACDEB)),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  onChanged: (value) {
                                    viewModel.updateSearchQuery(value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4ACDEB),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  viewModel.updateSearchQuery('');
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (viewModel.isLoading)
                          const Center(child: CircularProgressIndicator(color: Color(0xFF007180)))
                        else if (viewModel.errorMessage != null)
                          Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(color: Color(0xFFE15757), fontSize: 16),
                          )
                        else if (viewModel.users.isEmpty)
                          const Text(
                            'No users available',
                            style: TextStyle(color: Color(0xFF007180), fontSize: 16),
                          )
                        else
                          Expanded(
                            child: SingleChildScrollView(
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: DataTable(
                                  columnSpacing: 20,
                                  columns: const [
                                    DataColumn(
                                        label: Text('Name',
                                            style: TextStyle(color: Color(0xFF007180)))),
                                    DataColumn(
                                        label: Text('Gender',
                                            style: TextStyle(color: Color(0xFF007180)))),
                                    DataColumn(
                                        label: Text('Email',
                                            style: TextStyle(color: Color(0xFF007180)))),
                                    DataColumn(
                                        label: Text('Action',
                                            style: TextStyle(color: Color(0xFF007180)))),
                                  ],
                                  rows: viewModel.users.map((user) {
                                    return DataRow(cells: [
                                      DataCell(Text(user['name']?.toString() ?? 'N/A')),
                                      DataCell(Text(user['gender']?.toString() ?? 'N/A')),
                                      DataCell(Text(user['email']?.toString() ?? 'N/A')),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.email, color: Color(0xFF4ACDEB)),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => SendEmailPage(
                                                  email: user['email']?.toString() ?? '',
                                                  username: user['name']?.toString() ?? 'N/A',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}