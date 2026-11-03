import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../app_state.dart';
import '../models.dart';
import '../widgets/common.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key, required this.course});
  final Course course;

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final _boundary = GlobalKey();
  late final TextEditingController _name = TextEditingController(text: context.read<AppState>().name);
  bool _sharing = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _share(Certificate cert) async {
    setState(() => _sharing = true);
    try {
      final boundary = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1600 / boundary.size.width);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/certificate-${cert.id}.png');
      await file.writeAsBytes(data!.buffer.asUint8List(), flush: true);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'I completed ${widget.course.name} on CodeMentor AI!',
        sharePositionOrigin: box != null && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not share: $e')));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cert = s.certs[widget.course.id];
    return Scaffold(
      appBar: AppBar(title: Text(s.t(const T('Certificate', 'सर्टिफ़िकेट'))), actions: const [LangToggle()]),
      body: SafeArea(
        child: Body(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (cert == null) ...[
                Text(
                  s.t(const T('Congratulations! Enter your name exactly as it should appear on the certificate.',
                      'बधाई हो! सर्टिफ़िकेट पर जैसा नाम चाहिए वैसा दर्ज करें।')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: s.t(const T('Full name', 'पूरा नाम')),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _name.text.trim().isEmpty ? null : () => s.issueCertificate(widget.course, _name.text),
                  icon: const Icon(Icons.workspace_premium),
                  label: Text(s.t(const T('Generate certificate (+50 XP)', 'सर्टिफ़िकेट बनाएँ (+50 XP)'))),
                ),
              ] else ...[
                RepaintBoundary(
                  key: _boundary,
                  child: FittedBox(
                    child: _CertificateCard(course: widget.course, cert: cert),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _sharing ? null : () => _share(cert),
                  icon: _sharing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.share),
                  label: Text(s.t(const T('Share certificate', 'सर्टिफ़िकेट शेयर करें'))),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Fixed-size (800x566) so the exported image looks identical on every device.
class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.course, required this.cert});
  final Course course;
  final Certificate cert;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF1E1B4B);
    return Container(
      width: 800,
      height: 566,
      padding: const EdgeInsets.all(18),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFF4F46E5), width: 6)),
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF59E0B), width: 2)),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
          child: DefaultTextStyle(
            style: const TextStyle(color: ink),
            textAlign: TextAlign.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CODEMENTOR AI', style: TextStyle(fontSize: 18, letterSpacing: 4, fontWeight: FontWeight.w700)),
                const Text('Certificate of Completion', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
                const Text('This is to certify that', style: TextStyle(fontSize: 18)),
                Text(cert.name, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Color(0xFF4F46E5))),
                const Text('has successfully completed the course', style: TextStyle(fontSize: 18)),
                Text('${course.name} Programming', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date: ${cert.date}', style: const TextStyle(fontSize: 15)),
                    const Icon(Icons.workspace_premium, size: 56, color: Color(0xFFF59E0B)),
                    Text('ID: ${cert.id}', style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
