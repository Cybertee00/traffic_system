import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'checklist_data.dart';
import 'parallel_parking_backend.dart';
import 'alleyDocking_backend.dart';
import 'hillStart_backend.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dashboard_backend.dart';

class ReportPreviewPage extends StatelessWidget {
  final Officer? officer;
  final Learner? learner;
  final String carLicence;
  final String carReg;
  final String carTransmission;
  final String carWeather;
  final Duration fieldTestDuration;
  final Duration roadTestDuration;
  final Duration totalTestDuration;

  const ReportPreviewPage({
    super.key,
    this.officer,
    this.learner,
    this.carLicence = 'N/A',
    this.carReg = 'N/A',
    this.carTransmission = 'N/A',
    this.carWeather = 'N/A',
    this.fieldTestDuration = Duration.zero,
    this.roadTestDuration = Duration.zero,
    this.totalTestDuration = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Preview'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () async {
                final pdf = await _generateReportPdf(
                  context,
                  officer: officer,
                  learner: learner,
                  carLicence: carLicence,
                  carReg: carReg,
                  carTransmission: carTransmission,
                  carWeather: carWeather,
                  fieldTestDuration: fieldTestDuration,
                  roadTestDuration: roadTestDuration,
                  totalTestDuration: totalTestDuration,
                );
                await Printing.layoutPdf(
                  onLayout: (format) async => pdf.save(),
                  name: 'Traffic_Report.pdf',
                );
              },
              child: const Text('Download PDF'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Officer, Learner, and Car Details (Preview)
            const Text('Officer/Instructor Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Name: ${officer?.name ?? 'N/A'}'),
            Text('Infra nr: ${officer?.infraNr ?? 'N/A'}'),
            Divider(),
            const SizedBox(height: 8),
            const Text('Learner Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Name: ${learner?.name ?? 'N/A'}'),
            Text('ID: ${learner?.idNumber ?? 'N/A'}'),
            Text('Code: ${learner?.code ?? 'N/A'}'),
            Text('Gender: ${learner?.gender ?? 'N/A'}'),
            Divider(),
            const SizedBox(height: 8),
            const Text('Car Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Licence Number: $carLicence'),
            Text('Registration Number: $carReg'),
            Text('Transmission: $carTransmission'),
            Text('Weather: $carWeather'),
            Divider(),
            const SizedBox(height: 8),
            const Text('Test Times', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Field Test: ${_formatDuration(fieldTestDuration)}'),
            Text('Road Test: ${_formatDuration(roadTestDuration)}'),
            Text('Total Test: ${_formatDuration(totalTestDuration)}'),
            Divider(),
            // Detailed Description of Each Page
            const Text('Detailed Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _PageDetailsSection(),
          ],
        ),
      ),
    );
  }
}

class _PageDetailsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final page2Backend = Provider.of<Page2Backend>(context);
    final page3Backend = Provider.of<Page3Backend>(context);
    final hillStartBackend = Provider.of<HillStartBackend>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionDetail('Pretrip Inspection', page2Backend, ['PRETRIP INTERIOR', 'PRETRIP EXTERIOR']),
        _sectionDetail('Parallel Parking', page2Backend, ['PARALLEL PARKING (Left)', 'PARALLEL PARKING (Right)']),
        _sectionDetail('Alley Docking', page3Backend, ['ALLEY DOCKING (Left)', 'ALLEY DOCKING (Right)']),
        _sectionDetail('Hill Start', hillStartBackend, ['INCLINE START']),
        _sectionDetail('3 Point Turn', page2Backend, ['TURN IN THE ROAD']),
        _sectionDetail('Left Turn', page2Backend, ['LEFT TURN']),
        _sectionDetail('Straight Reverse', page2Backend, ['STRAIGHT REVERSING']),
        _sectionDetail('Road Trip', page2Backend, [
          'STARTING','MOVING OFF','STEERING','CLUTCH','GEAR CHANGING','SIGNALLING','LANE CHANGING','OVERTAKING','INTERSECTION VEHICLE ENTRY/EXIT','SPEED CONTROL','STOPPING','FREEWAYS ENTRY/EXIT',
        ]),
      ],
    );
  }

  Widget _sectionDetail(String title, dynamic backend, List<String> sectionTitles) {
    double sectionTotal = 0;
    List<Widget> rows = [];
    for (var sectionTitle in sectionTitles) {
      final section = testSections.firstWhere(
        (s) => s.title == sectionTitle,
        orElse: () => TestSection(title: sectionTitle, checks: []),
      );
      if (section.checks.isEmpty) continue;
      rows.add(Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(section.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ));
      rows.add(Row(
        children: const [
          Expanded(child: Text('Check Item', style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 8),
          Text('Penalty', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Text('Count', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ));
      for (var check in section.checks) {
        final key = '${section.title}-${check.description}';
        final count = backend.getCheckCount(key);
        final total = check.penaltyValue * count;
        sectionTotal += total;
        rows.add(Row(
          children: [
            Expanded(child: Text(check.description)),
            SizedBox(width: 8),
            Text('${check.penaltyValue}'),
            SizedBox(width: 8),
            Text('$count'),
            SizedBox(width: 8),
            Text('$total'),
          ],
        ));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          ...rows,
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Section Total: $sectionTotal', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

Future<pw.Document> _generateReportPdf(BuildContext context, {
  Officer? officer,
  Learner? learner,
  String carLicence = 'N/A',
  String carReg = 'N/A',
  String carTransmission = 'N/A',
  String carWeather = 'N/A',
  Duration fieldTestDuration = Duration.zero,
  Duration roadTestDuration = Duration.zero,
  Duration totalTestDuration = Duration.zero,
}) async {
  final pdf = pw.Document();
  final page2Backend = Provider.of<Page2Backend>(context, listen: false);
  final page3Backend = Provider.of<Page3Backend>(context, listen: false);
  final hillStartBackend = Provider.of<HillStartBackend>(context, listen: false);

  // Helper to build a section table
  pw.Widget sectionTable(String title, dynamic backend, List<String> sectionTitles) {
    List<pw.Widget> rows = [];
    double sectionTotal = 0;
    for (var sectionTitle in sectionTitles) {
      final section = testSections.firstWhere(
        (s) => s.title == sectionTitle,
        orElse: () => TestSection(title: sectionTitle, checks: []),
      );
      if (section.checks.isEmpty) continue;
      rows.add(pw.Padding(
        padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
        child: pw.Text(section.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)),
      ));
      rows.add(pw.Row(
        children: [
          pw.Expanded(child: pw.Text('Check Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(width: 8),
          pw.Text('Penalty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 8),
          pw.Text('Count', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 8),
          pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ));
      for (var check in section.checks) {
        final key = '${section.title}-${check.description}';
        final count = backend.getCheckCount(key);
        final total = check.penaltyValue * count;
        sectionTotal += total;
        rows.add(pw.Row(
          children: [
            pw.Expanded(child: pw.Text(check.description)),
            pw.SizedBox(width: 8),
            pw.Text('${check.penaltyValue}'),
            pw.SizedBox(width: 8),
            pw.Text('$count'),
            pw.SizedBox(width: 8),
            pw.Text('$total'),
          ],
        ));
      }
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 2),
        ...rows,
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8.0),
          child: pw.Text('Section Total: $sectionTotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  // Load the traffic department logo
  final logoImage = await _loadImageFromAssets('assets/transport.png');
  
  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        // Add the traffic department logo
        if (logoImage != null) pw.Image(logoImage),
        pw.SizedBox(height: 8),
        pw.Text('Traffic Department Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 16),
        // Officer, Learner, and Car Details
        pw.Text('Officer/Instructor Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.Text('Name: ${officer?.name ?? 'N/A'}'),
        pw.Text('Infra nr: ${officer?.infraNr ?? 'N/A'}'),
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text('Learner Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.Text('Name: ${learner?.name ?? 'N/A'}'),
        pw.Text('ID: ${learner?.idNumber ?? 'N/A'}'),
        pw.Text('Code: ${learner?.code ?? 'N/A'}'),
        pw.Text('Gender: ${learner?.gender ?? 'N/A'}'),
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text('Car Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.Text('Licence Number: $carLicence'),
        pw.Text('Registration Number: $carReg'),
        pw.Text('Transmission: $carTransmission'),
        pw.Text('Weather: $carWeather'),
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text('Test Times', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.Text('Field Test: ${_formatDuration(fieldTestDuration)}'),
        pw.Text('Road Test: ${_formatDuration(roadTestDuration)}'),
        pw.Text('Total Test: ${_formatDuration(totalTestDuration)}'),
        pw.Divider(),
        pw.SizedBox(height: 24),
        pw.Text('Detailed Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        sectionTable('Pretrip Inspection', page2Backend, ['PRETRIP INTERIOR', 'PRETRIP EXTERIOR']),
        sectionTable('Parallel Parking', page2Backend, ['PARALLEL PARKING (Left)', 'PARALLEL PARKING (Right)']),
        sectionTable('Alley Docking', page3Backend, ['ALLEY DOCKING (Left)', 'ALLEY DOCKING (Right)']),
        sectionTable('Hill Start', hillStartBackend, ['INCLINE START']),
        sectionTable('3 Point Turn', page2Backend, ['TURN IN THE ROAD']),
        sectionTable('Left Turn', page2Backend, ['LEFT TURN']),
        sectionTable('Straight Reverse', page2Backend, ['STRAIGHT REVERSING']),
        sectionTable('Road Trip', page2Backend, [
          'STARTING','MOVING OFF','STEERING','CLUTCH','GEAR CHANGING','SIGNALLING','LANE CHANGING','OVERTAKING','INTERSECTION VEHICLE ENTRY/EXIT','SPEED CONTROL','STOPPING','FREEWAYS ENTRY/EXIT',
        ]),
      ],
    ),
  );
  return pdf;
}

String _formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(d.inMinutes.remainder(60));
  final seconds = twoDigits(d.inSeconds.remainder(60));
  return '${d.inHours > 0 ? '${twoDigits(d.inHours)}:' : ''}$minutes:$seconds';
}

// Function to load image from assets
Future<pw.MemoryImage?> _loadImageFromAssets(String assetPath) async {
  try 
  {
    final ByteData data = await rootBundle.load(assetPath);
    return pw.MemoryImage(data.buffer.asUint8List());
  } catch (e) {
    //print('Error loading image: $e');
    return null;
  }
}

// Function to load image from network
Future<pw.MemoryImage?> _loadImageFromNetwork(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return pw.MemoryImage(response.bodyBytes);
    }
    return null;
  } catch (e) {
    //print('Error loading network image: $e');
    return null;
  }
} 