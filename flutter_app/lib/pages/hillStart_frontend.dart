import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'checklist_data.dart';
import 'hillStart_backend.dart';

class HillStartPage extends StatelessWidget {
  const HillStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Incline Start')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Provider.of<HillStartBackend>(context, listen: false).startTest();
                  },
                  child: Text('Start'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Consumer<HillStartBackend>(
                    builder: (context, backend, _) {
                      return LinearProgressIndicator(value: backend.progressValue);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(child: _ChecklistCard(sectionTitle: 'INCLINE START')),
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
    final backend = Provider.of<HillStartBackend>(context);
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
                      icon: Icon(Icons.add, color: Colors.green,),
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

  double _calculateTotal(TestSection section, HillStartBackend backend) 
  {
    double total = 0;
    for (var check in section.checks) {
      final key = '${section.title}-${check.description}';
      final count = backend.getCheckCount(key);
      total += check.penaltyValue * count;
    }
    return total;
  }
} 
