import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/red_flag.dart';
import '../models/domain_check_result.dart';
import '../models/company_check_result.dart';
import '../models/image_forensics_result.dart';
import '../services/scam_detector.dart';
import '../services/ocr_service.dart';
import '../services/url_extractor.dart';
import '../services/domain_check_service.dart';
import '../services/company_name_extractor.dart';
import '../services/mca_lookup_service.dart';
import '../services/reverse_image_service.dart';
import '../widgets/domain_check_card.dart';
import '../widgets/company_check_card.dart';
import '../widgets/image_forensics_card.dart';

enum _Stage { idle, ocr, verifying, done }

/// The "no limitations" version: upload a photo of an offer letter and
/// every check runs against it in sequence — OCR extracts the text, then
/// text-pattern scoring, domain age, company registration, and image
/// forensics all run against what was actually found, producing one
/// combined evidence report instead of four separate tools.
class VerifyLetterScreen extends StatefulWidget {
  const VerifyLetterScreen({super.key});

  @override
  State<VerifyLetterScreen> createState() => _VerifyLetterScreenState();
}

class _VerifyLetterScreenState extends State<VerifyLetterScreen> {
  _Stage _stage = _Stage.idle;
  File? _imageFile;
  String? _extractedText;
  List<RedFlag> _textFlags = [];
  int _textRiskScore = 0;
  List<DomainCheckResult> _domainResults = [];
  CompanyCheckResult? _companyResult;
  ImageForensicsResult? _imageResult;
  String? _stageLabel;

  Future<void> _pickAndVerify() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _imageFile = file;
      _stage = _Stage.ocr;
      _stageLabel = 'Reading text from the image...';
      _extractedText = null;
      _textFlags = [];
      _domainResults = [];
      _companyResult = null;
      _imageResult = null;
    });

    // Step 1: OCR
    final text = await OcrService.extractText(file);
    setState(() {
      _extractedText = text;
      _stage = _Stage.verifying;
      _stageLabel = 'Running checks...';
    });

    // Step 2: text pattern scan (instant, local)
    final scanResult = ScamDetector.scan(text);
    setState(() {
      _textFlags = scanResult.flags;
      _textRiskScore = scanResult.riskScore;
    });

    // Step 3, 4, 5: domain check, company check, image forensics —
    // run concurrently since they're independent of each other.
    final domains = UrlExtractor.extractDomains(text);
    final companyName = CompanyNameExtractor.extract(text);
    final imageBytes = await file.readAsBytes();

    final futures = <Future>[];

    futures.add(
      DomainCheckService.checkAll(domains).then((r) {
        if (mounted) setState(() => _domainResults = r);
      }),
    );

    if (companyName != null) {
      futures.add(
        McaLookupService.check(companyName).then((r) {
          if (mounted) setState(() => _companyResult = r);
        }),
      );
    }

    futures.add(
      ReverseImageService.checkImage(imageBytes).then((r) {
        if (mounted) setState(() => _imageResult = r);
      }),
    );

    await Future.wait(futures);
    if (mounted) setState(() => _stage = _Stage.done);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify a Letter')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload a screenshot of an offer letter or job message. '
              'Every check runs against what\'s actually in it.',
            ),
            const SizedBox(height: 12),
            if (_imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, height: 160, fit: BoxFit.cover, width: double.infinity),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _stage == _Stage.ocr || _stage == _Stage.verifying ? null : _pickAndVerify,
                icon: const Icon(Icons.upload_file),
                label: Text(_imageFile == null ? 'Upload Screenshot' : 'Upload a Different Screenshot'),
              ),
            ),
            const SizedBox(height: 16),
            if (_stage == _Stage.ocr || _stage == _Stage.verifying)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Text(_stageLabel ?? 'Working...'),
                  ],
                ),
              ),
            if (_stage == _Stage.verifying || _stage == _Stage.done)
              Expanded(
                child: ListView(
                  children: [
                    if (_textFlags.isNotEmpty) ...[
                      Text('Text patterns (risk score: $_textRiskScore/100)',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      ..._textFlags.map((f) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.flag, color: Colors.red),
                              title: Text(f.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(f.explanation),
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],
                    if (_domainResults.isNotEmpty) ...[
                      Text('Domain verification', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      ..._domainResults.map((d) => DomainCheckCard(result: d)),
                      const SizedBox(height: 16),
                    ],
                    if (_companyResult != null) ...[
                      Text('Company registration', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      CompanyCheckCard(result: _companyResult!),
                      const SizedBox(height: 16),
                    ],
                    if (_imageResult != null) ...[
                      Text('Image forensics', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      ImageForensicsCard(result: _imageResult!),
                      const SizedBox(height: 16),
                    ],
                    if (_stage == _Stage.done &&
                        _textFlags.isEmpty &&
                        _domainResults.isEmpty &&
                        _companyResult == null &&
                        _imageResult == null)
                      const Text(
                        'Couldn\'t extract enough from this image to run checks. '
                        'Try a clearer photo, or use the "Scan Text" tab to paste the text directly.',
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
