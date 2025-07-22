import 'package:flutter/material.dart';
import 'checklist_data.dart';
import 'package:provider/provider.dart';
import 'parallel_parking_backend.dart';

class RoadTripPage extends StatelessWidget {
  final List<String> sectionTitles = [
    'STARTING',
    'MOVING OFF',
    'STEERING',
    'CLUTCH',
    'GEAR CHANGING',
    'SIGNALLING',
    'LANE CHANGING',
    'OVERTAKING',
    'INTERSECTION VEHICLE ENTRY/EXIT',
    'SPEED CONTROL',
    'STOPPING',
    'FREEWAYS ENTRY/EXIT',
  ];

  RoadTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Road Trip')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _CollapsibleChecklist(sectionTitles: sectionTitles),
      ),
    );
  }
}

class _CollapsibleChecklist extends StatefulWidget {
  final List<String> sectionTitles;
  const _CollapsibleChecklist({required this.sectionTitles});

  @override
  State<_CollapsibleChecklist> createState() => _CollapsibleChecklistState();
}

class _CollapsibleChecklistState extends State<_CollapsibleChecklist> {
  Map<String, bool> _expanded = {};

  @override
void initState() {
  super.initState();
  _syncExpandedMap();
}

  @override
void didUpdateWidget(covariant _CollapsibleChecklist oldWidget) {
  super.didUpdateWidget(oldWidget);
  _syncExpandedMap();
}

void _syncExpandedMap() {
  final currentKeys = widget.sectionTitles.toSet();

  // Add missing keys
  for (var title in widget.sectionTitles) {
    _expanded.putIfAbsent(title, () => false);
  }

  // Remove outdated keys
  _expanded.removeWhere((key, _) => !currentKeys.contains(key));
}

  @override
  Widget build(BuildContext context) {
    final backend = Provider.of<Page2Backend>(context);
    return ListView.builder(
      itemCount: widget.sectionTitles.length,
      itemBuilder: (context, index) {
        final sectionTitle = widget.sectionTitles[index];
        final section = testSections.firstWhere(
          (s) => s.title == sectionTitle,
          orElse: () => TestSection(title: sectionTitle, checks: []),
        );
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: ExpansionTile(
            key: PageStorageKey(sectionTitle),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Builder(
                    builder: (context) {
                      final penalty = _calculateTotal(section, backend);
                      return Text(
                        'Penalty: $penalty',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: penalty > 0 ? Colors.red : Colors.green,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            initiallyExpanded: _expanded[sectionTitle] ?? false,
            onExpansionChanged: (expanded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  try {
                    _expanded[sectionTitle] = expanded;
                  } catch (e, stack) {
                    debugPrint('Expansion error for $sectionTitle: $e\n$stack');
                  }
                });
              });
            },
            children: [
              if (section.checks.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('No checklist items defined.'),
                )
              else
                ...[
                  Column(
                    children: section.checks.map((check) {
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
                    }).toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Total Penalty: ${_calculateTotal(section, backend)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
            ],
          ),
        );
      },
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
