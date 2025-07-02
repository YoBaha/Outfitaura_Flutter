import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:outfitaura/models/clothing_item.dart';
import 'package:outfitaura/services/api_service.dart';
import 'package:outfitaura/viewmodels/wardrobe_viewmodel.dart';

class OutfitPlannerPage extends StatefulWidget {
  const OutfitPlannerPage({super.key});

  @override
  _OutfitPlannerPageState createState() => _OutfitPlannerPageState();
}

class _OutfitPlannerPageState extends State<OutfitPlannerPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _plannedOutfits = [];
  late Future<void> _fetchPlannedOutfitsFuture;

  @override
  void initState() {
    super.initState();
    _fetchPlannedOutfitsFuture = _fetchPlannedOutfits();
    _selectedDay = _focusedDay;
  }

  Future<void> _fetchPlannedOutfits() async {
    try {
      _plannedOutfits = await ApiService.getPlannedOutfits();
      setState(() {});
    } catch (e) {
      debugPrint('Error fetching planned outfits: $e');
    }
  }

  void _showPlanOutfitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PlanOutfitDialog(
        selectedDay: _selectedDay!,
        onSave: (items) async {
          try {
            await ApiService.savePlannedOutfit(_selectedDay!, items);
            await _fetchPlannedOutfits();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving outfit: $e')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
            const SizedBox(width: 8),
            const Text('Outfit Planner',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF007180),
      ),
      body: Container(
        color: const Color(0xFFDDEAE0),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF4ACDEB),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: const Color(0xFF007180),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<void>(
                future: _fetchPlannedOutfitsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final selectedOutfit = _plannedOutfits.firstWhere(
                    (outfit) => isSameDay(outfit['date'], _selectedDay),
                    orElse: () => {},
                  );
                  if (selectedOutfit.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No outfit planned for this date',
                            style: TextStyle(
                                fontSize: 18, color: Color(0xFF007180)),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4ACDEB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _showPlanOutfitDialog(context),
                            child: const Text('Plan Outfit'),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Planned Outfit for ${_selectedDay!.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007180)),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          children: (selectedOutfit['items'] as List)
                              .map<Widget>((item) => Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    child: ListTile(
                                      leading: Image.network(
                                        item['imageUrl'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.error,
                                                color: Color(0xFFE15757)),
                                      ),
                                      title: Text(item['title']),
                                      subtitle: Text('Type: ${item['type']}'),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4ACDEB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _showPlanOutfitDialog(context),
                            child: const Text('Edit Outfit'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE15757),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              try {
                                await ApiService.deletePlannedOutfit(
                                    selectedOutfit['id']);
                                await _fetchPlannedOutfits();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                            child: const Text('Delete Outfit'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlanOutfitDialog extends StatefulWidget {
  final DateTime selectedDay;
  final Function(List<Map<String, dynamic>>) onSave;

  const PlanOutfitDialog({super.key, required this.selectedDay, required this.onSave});

  @override
  _PlanOutfitDialogState createState() => _PlanOutfitDialogState();
}

class _PlanOutfitDialogState extends State<PlanOutfitDialog> {
  final List<Map<String, dynamic>> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WardrobeViewModel>(context, listen: false);

    return Dialog(
      backgroundColor: const Color(0xFFDDEAE0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Plan Outfit for ${widget.selectedDay.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007180)),
            ),
            const SizedBox(height: 20),
            FutureBuilder<void>(
              future: viewModel.fetchWardrobe(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Color(0xFFE15757)));
                }
                return SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: viewModel.items.length,
                    itemBuilder: (context, index) {
                      final item = viewModel.items[index];
                      final isSelected = _selectedItems.any(
                          (selected) => selected['clothingItemId'] == item.id);
                      return CheckboxListTile(
                        title: Text(item.title),
                        subtitle: Text(
                            'Added: ${item.createdAt.toLocal().toString().split('.')[0]}'),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedItems.add({
                                'type': item.title,
                                'clothingItemId': item.id,
                                'title': item.title,
                                'imageUrl': item.imageUrl,
                                'createdAt': item.createdAt.toIso8601String(),
                              });
                            } else {
                              _selectedItems.removeWhere(
                                  (selected) => selected['clothingItemId'] == item.id);
                            }
                          });
                        },
                        secondary: Image.network(
                          item.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, color: Color(0xFFE15757)),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ACDEB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    widget.onSave(_selectedItems);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE15757),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}