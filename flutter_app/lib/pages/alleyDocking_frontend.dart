import 'package:flutter/material.dart';
import 'checklist_data.dart';
import 'package:provider/provider.dart';
import 'alleyDocking_backend.dart';

class AlleyDockingPage extends StatelessWidget {
  const AlleyDockingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alley Docking')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: _ChecklistCard(sectionTitle: 'ALLEY DOCKING (Left)')),
            Expanded(child: _MiddleCard()),
            Expanded(child: _ChecklistCard(sectionTitle: 'ALLEY DOCKING (Right)')),
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
    final backend = Provider.of<Page3Backend>(context);
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
                      onPressed: () => backend.incrementCheck(key),
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

  int _calculateTotal(TestSection section, Page3Backend backend) {
    int total = 0;
    for (var check in section.checks) {
      final key = '${section.title}-${check.description}';
      final count = backend.getCheckCount(key);
      total += check.penaltyValue * count;
    }
    return total;
  }
}

class _MiddleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final backend = Provider.of<Page3Backend>(context);

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: backend.circles.map((circle) {
              return Positioned(
                left: circle.x * width - 15,
                top: circle.y * height - 15,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: circle.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
