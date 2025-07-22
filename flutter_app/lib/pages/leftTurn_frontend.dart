import 'package:flutter/material.dart';
import 'checklist_data.dart';
import 'package:provider/provider.dart';
import 'parallel_parking_backend.dart';

class LeftTurnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Left Turn')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: _ChecklistCard(sectionTitle: 'LEFT TURN')),
          ],
        ),
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final String sectionTitle;
  const _ChecklistCard({required this.sectionTitle});

  @override
  Widget build(BuildContext context) {
    final backend = Provider.of<Page2Backend>(context);
    final section = testSections.firstWhere((s) => s.title == sectionTitle);

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                section.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: section.checks.length,
                itemBuilder: (context, index) {
                  final check = section.checks[index];
                  final key = '${section.title}-${check.description}';
                  final count = backend.getCheckCount(key);

                  return ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.add_rounded, color: Colors.green),
                      onPressed: () {
                        backend.incrementCheck(key);
                      },
                    ),
                    title: Text(check.description),
                    trailing: Text('$count'),
                  );
                },
              ),
            ),
            Text(
              'Total Penalty: ${_calculateTotal(section, backend)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotal(TestSection section, Page2Backend backend) {
    int total = 0;
    for (var check in section.checks) {
      final key = '${section.title}-${check.description}';
      final count = backend.getCheckCount(key);
      total += check.penaltyValue * count;
    }
    return total;
  }
}
