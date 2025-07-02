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
                    final filteredUsers = viewModel.users.where((user) {
                      final query = viewModel.searchQuery.toLowerCase();
                      return (user['name']?.toLowerCase() ?? '').contains(query) ||
                          (user['email']?.toLowerCase() ?? '').contains(query);
                    }).toList();

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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search users by name or email...',
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
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4ACDEB),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => viewModel.fetchUsers(),
                                child: const Text('Refresh'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (viewModel.isLoading)
                          const Center(child: CircularProgressIndicator(color: Color(0xFF007180)))
                        else if (viewModel.errorMessage != null)
                          Column(
                            children: [
                              Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(color: Color(0xFFE15757), fontSize: 16),
                              ),
                              ElevatedButton(
                                onPressed: () => viewModel.fetchUsers(),
                                child: const Text('Retry'),
                              ),
                            ],
                          )
                        else if (filteredUsers.isEmpty)
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
                                        label: Text('Status',
                                            style: TextStyle(color: Color(0xFF007180)))),
                                    DataColumn(
                                        label: Text('Action',
                                            style: TextStyle(color: Color(0xFF007180)))),
                                  ],
                                  rows: filteredUsers.map((user) {
                                    return DataRow(cells: [
                                      DataCell(Text(user['name']?.toString() ?? 'N/A')),
                                      DataCell(Text(user['gender']?.toString() ?? 'N/A')),
                                      DataCell(Text(user['email']?.toString() ?? 'N/A')),
                                      DataCell(
                                        Text(
                                          (user['status']?.toString() ?? 'Unknown').toUpperCase(),
                                          style: TextStyle(
                                            color: user['status'] == 'inactive' ? Colors.red : Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                user['status'] == 'inactive'
                                                    ? Icons.lock
                                                    : Icons.lock_open,
                                                color: const Color(0xFF4ACDEB),
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Confirm Status Change'),
                                                    content: Text(
                                                      'Change status of ${user['name']} to ${user['status'] == 'active' ? 'inactive' : 'active'}?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          viewModel.toggleUserStatus(
                                                            user['_id'],
                                                            user['status'] ?? 'active',
                                                          );
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text('Confirm'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
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
                                          ],
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