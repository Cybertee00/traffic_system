import 'package:flutter/material.dart';
import 'checklist_data.dart';
import 'package:provider/provider.dart';
import 'parallel_parking_backend.dart';

class ParallelParkingPage extends StatelessWidget {
  const ParallelParkingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Parallel Parking')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: _ChecklistCard(sectionTitle: 'PARALLEL PARKING (Left)')),
            Expanded(child: _MiddleCard()),
            Expanded(child: _ChecklistCard(sectionTitle: 'PARALLEL PARKING (Right)')),
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
                      icon: Icon(Icons.add_rounded, color: Colors.green),onPressed: () {backend.incrementCheck(key); // You can implement decrement if needed
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

class _MiddleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final backend = Provider.of<Page2Backend>(context);

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
                left: circle.x * width - backend.circleSize / 2,
                top: circle.y * height - backend.circleSize / 2,
                child: Container(
                  width: backend.circleSize,
                  height: backend.circleSize,
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
