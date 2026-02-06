import 'dart:typed_data';
import '../models/claim_model.dart';
import '../core/utils/pdf_utils.dart';

class PdfService {
  Future<Uint8List> generateClaimReport(ClaimModel claim) async {
    return await PdfUtils.generateClaimSummaryPdf(claim);
  }

  Future<void> printClaimReport(ClaimModel claim) async {
    final pdfBytes = await generateClaimReport(claim);
    await PdfUtils.printPdf(pdfBytes);
  }

  Future<void> shareClaimReport(ClaimModel claim, String fileName) async {
    final pdfBytes = await generateClaimReport(claim);
    await PdfUtils.sharePdf(pdfBytes, fileName);
  }

  Future<void> downloadClaimReport(ClaimModel claim, String fileName) async {
    final pdfBytes = await generateClaimReport(claim);
    await PdfUtils.downloadPdf(pdfBytes, fileName);
  }

  Future<void> previewClaimReport(ClaimModel claim) async {
    final pdfBytes = await generateClaimReport(claim);
    await PdfUtils.previewPdf(pdfBytes);
  }
}
