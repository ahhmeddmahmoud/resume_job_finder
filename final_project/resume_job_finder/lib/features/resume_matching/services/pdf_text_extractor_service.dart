import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PickedPdfResult {
  const PickedPdfResult({
    required this.fileName,
    required this.extractedText,
    this.fileSizeBytes = 0,
  });

  final String fileName;
  final String extractedText;
  final int fileSizeBytes;
}

/// Picks a PDF CV file and extracts its text locally using Syncfusion PDF.
class PdfTextExtractorService {
  Future<PickedPdfResult?> pickAndExtractPdfText() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }

    if (bytes == null || bytes.isEmpty) {
      throw const FormatException(
        'تعذر قراءة ملف الـ PDF المختار. تأكد من أن الملف غير تالف.',
      );
    }
    if (bytes.length > 10 * 1024 * 1024) {
      throw const FormatException(
        'حجم الملف أكبر من 10 ميجابايت. اختر ملفًا أصغر.',
      );
    }

    PdfDocument? document;
    try {
      document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);
      final text = extractor.extractText().trim();

      if (text.isEmpty || text.length < 20) {
        throw const FormatException(
          'الملف لا يحتوي على نص قابل للاستخراج (قد يكون صورة ممسوحة ضوئيًا أو فارغًا). يرجى اختيار سيرة ذاتية بصيغة PDF نصية.',
        );
      }

      return PickedPdfResult(
        fileName: file.name,
        extractedText: text,
        fileSizeBytes: bytes.length,
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException(
        'تعذر استخراج النص من ملف الـ PDF. تأكد من أن الملف غير محمي بكلمة مرور وغير تالف.',
      );
    } finally {
      document?.dispose();
    }
  }
}
