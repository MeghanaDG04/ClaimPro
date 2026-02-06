import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../models/claim_model.dart';
import '../../models/bill_model.dart';
import '../../models/advance_model.dart';
import '../../models/settlement_model.dart';
import '../constants/app_constants.dart';
import '../constants/status_constants.dart';

class PdfUtils {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat(AppConstants.displayDateFormat);

  static final PdfColor _primaryColor = PdfColor.fromHex('#1E3A5F');
  static final PdfColor _secondaryColor = PdfColor.fromHex('#0D9488');
  static final PdfColor _accentColor = PdfColor.fromHex('#F59E0B');
  static final PdfColor _lightGray = PdfColor.fromHex('#F3F4F6');
  static final PdfColor _darkGray = PdfColor.fromHex('#374151');
  static final PdfColor _successColor = PdfColor.fromHex('#10B981');

  static Future<Uint8List> generateClaimSummaryPdf(ClaimModel claim) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();
    final fontMedium = await PdfGoogleFonts.poppinsMedium();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(claim, fontBold, fontMedium),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildClaimInfoSection(claim, font, fontBold, fontMedium),
          pw.SizedBox(height: 20),
          _buildPatientDetailsSection(claim, font, fontBold, fontMedium),
          pw.SizedBox(height: 20),
          _buildHospitalDetailsSection(claim, font, fontBold, fontMedium),
          pw.SizedBox(height: 20),
          if (claim.bills.isNotEmpty) ...[
            _buildBillsSection(claim, font, fontBold, fontMedium),
            pw.SizedBox(height: 20),
          ],
          if (claim.advances.isNotEmpty) ...[
            _buildAdvancesSection(claim, font, fontBold, fontMedium),
            pw.SizedBox(height: 20),
          ],
          if (claim.settlements.isNotEmpty) ...[
            _buildSettlementsSection(claim, font, fontBold, fontMedium),
            pw.SizedBox(height: 20),
          ],
          _buildFinancialSummary(claim, font, fontBold, fontMedium),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(
    ClaimModel claim,
    pw.Font fontBold,
    pw.Font fontMedium,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _primaryColor, width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                AppConstants.appName,
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 24,
                  color: _primaryColor,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Insurance Claim Summary',
                style: pw.TextStyle(
                  font: fontMedium,
                  fontSize: 14,
                  color: _darkGray,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: _getStatusColor(claim.status),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  claim.status.displayName.toUpperCase(),
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Claim #: ${claim.claimNumber}',
                style: pw.TextStyle(
                  font: fontMedium,
                  fontSize: 12,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: _lightGray, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
            style: pw.TextStyle(font: font, fontSize: 9, color: _darkGray),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: font, fontSize: 9, color: _darkGray),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildClaimInfoSection(
    ClaimModel claim,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontMedium,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _lightGray,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: _buildInfoItem(
              'Policy Number',
              claim.policyNumber,
              font,
              fontMedium,
            ),
          ),
          pw.Expanded(
            child: _buildInfoItem(
              'Claim Type',
              claim.claimType.displayName,
              font,
              fontMedium,
            ),
          ),
          pw.Expanded(
            child: _buildInfoItem(
              'Insurer',
              claim.insurerName,
              font,
              fontMedium,
            ),
          ),
          pw.Expanded(
            child: _buildInfoItem(
              'TPA',
              claim.tpaName ?? 'N/A',
              font,
              fontMedium,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPatientDetailsSection(
    ClaimModel claim,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontMedium,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _lightGray, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _primaryColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(7),
                topRight: pw.Radius.circular(7),
              ),
            ),
            child: pw.Text(
              'Patient Details',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Name', claim.patientName, font, fontMedium),
                      _buildInfoRow('Patient ID', claim.patientId, font, fontMedium),
                      _buildInfoRow('Gender', claim.gender.displayName, font, fontMedium),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Date of Birth',
                        claim.dateOfBirth != null
                            ? _dateFormat.format(claim.dateOfBirth!)
                            : 'N/A',
                        font,
                        fontMedium,
                      ),
                      _buildInfoRow('Contact', claim.contactNumber, font, fontMedium),
                      _buildInfoRow('Email', claim.email ?? 'N/A', font, fontMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHospitalDetailsSection(
    ClaimModel claim,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontMedium,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _lightGray, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _secondaryColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(7),
                topRight: pw.Radius.circular(7),
              ),
            ),
            child: pw.Text(
              'Hospital Details',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Hospital', claim.hospitalName, font, fontMedium),
                      _buildInfoRow('Department', claim.department ?? 'N/A', font, fontMedium),
                      _buildInfoRow('Doctor', claim.treatingDoctor ?? 'N/A', font, fontMedium),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Admission',
                        _dateFormat.format(claim.admissionDate),
                        font,
                        fontMedium,
                      ),
                      _buildInfoRow(
                        'Discharge',
                        claim.dischargeDate != null
                            ? _dateFormat.format(claim.dischargeDate!)
                            : 'N/A',
                        font,
                        fontMedium,
                      ),
                      _buildInfoRow(
                        'Diagnosis',
                        claim.diagnosisDetails ?? 'N/A',
                        font,
                        fontMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBillsSection(
    ClaimModel claim,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontMedium,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _lightGray, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _accentColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(7),
                topRight: pw.Radius.circular(7),
              ),
            ),
            child: pw.Text(
              'Bills',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(font: fontBold, fontSize: 10),
              cellStyle: pw.TextStyle(font: font, fontSize: 9),
              headerDecoration: pw.BoxDecoration(color: _lightGray),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
              },
              headers: ['Bill No', 'Date', 'Type', 'Description', 'Amount', 'Approved'],
              data: claim.bills.map((bill) {
                return [
                  bill.billNumber,
                  _dateFormat.format(bill.billDate),
                  bill.billType.displayName,
                  bill.description.length > 30
                      ? '${bill.description.substring(0, 30)}...'
                      : bill.description,
                  _currencyFormat.format(bill.amount),
                  bill.approvedAmount != null
                      ? _currencyFormat.format(bill.approvedAmount)
                      : '-',
                ];
              }).toList(),
            ),
          ),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _lightGray,
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(7),
                bottomRight: pw.Radius.circular(7),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total Bills: ',
                  style: pw.TextStyle(font: fontMedium, fontSize: 11),
                ),
                pw.Text(
                  _currencyFormat.format(claim.totalBillAmount),
                  style: pw.TextStyle(font: fontBold, fontSize: 12, color: _primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAdvancesSection(
    ClaimModel claim,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontMedium,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _lightGray, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _secondaryColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(7),
                topRight: pw.Radius.circular(7),
              ),
            ),
            child: pw.Text(
              'Advances',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(font: fontBold, fontSize: 10),
              cellStyle: pw.TextStyle(font: font, fontSize: 9),
              headerDecoration: pw.BoxDecoration(color: _lightGray),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.center,
                4: pw.Alignment.centerLeft,
              },
              headers: ['Advance No', 'Date', 'Amount', 'Mode', 'Paid To'],
              data: claim.advances.map((adv) {
                return [
                  adv.advanceNumber,
                  _dateFormat.format(adv.advanceDate),
                  _currencyFormat.format(adv.amount),
                  adv.paymentMode.displayName,
                  adv.paidTo,
                ];
              }).toList(),
            ),
          ),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _lightGray,
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(7),
                bottomRight: pw.Radius.circular(7),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total Advances: ',
                  style: pw.TextStyle(font: fontMedium, fontSize: 11),
                ),
                pw.Text(
                  _currencyFormat.format(claim.totalAdvanceAmount),
                  style: pw.TextStyle(font: fontBold, fontSize: 12, color: _primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSettlementsSection(
    ClaimModel claim,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontMedium,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _lightGray, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _successColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(7),
                topRight: pw.Radius.circular(7),
              ),
            ),
            child: pw.Text(
              'Settlements',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(font: fontBold, fontSize: 10),
              cellStyle: pw.TextStyle(font: font, fontSize: 9),
              headerDecoration: pw.BoxDecoration(color: _lightGray),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
              },
              headers: ['Settlement No', 'Date', 'Type', 'Amount', 'Deductions', 'Net Amount'],
              data: claim.settlements.map((stl) {
                return [
                  stl.settlementNumber,
                  _dateFormat.format(stl.settlementDate),
                  stl.settlementType.displayName,
                  _currencyFormat.format(stl.settledAmount),
                  _currencyFormat.format(stl.deductions),
                  _currencyFormat.format(stl.netAmount),
                ];
              }).toList(),
            ),
          ),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _lightGray,
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(7),
                bottomRight: pw.Radius.circular(7),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total Settled: ',
                  style: pw.TextStyle(font: fontMedium, fontSize: 11),
                ),
                pw.Text(
                  _currencyFormat.format(claim.totalSettledAmount),
                  style: pw.TextStyle(font: fontBold, fontSize: 12, color: _successColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFinancialSummary(
    ClaimModel claim,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontMedium,
  ) {
    final approvedAmount = claim.approvedAmount ?? claim.estimatedAmount;

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _primaryColor, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _primaryColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(6),
                topRight: pw.Radius.circular(6),
              ),
            ),
            child: pw.Text(
              'Financial Summary',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              children: [
                _buildSummaryRow('Estimated Amount', claim.estimatedAmount, font, fontMedium),
                _buildSummaryRow('Approved Amount', approvedAmount, font, fontMedium),
                pw.Divider(color: _lightGray),
                _buildSummaryRow('Total Bills', claim.totalBillAmount, font, fontMedium),
                _buildSummaryRow('Total Advances', claim.totalAdvanceAmount, font, fontMedium),
                _buildSummaryRow('Total Settled', claim.totalSettledAmount, font, fontMedium),
                pw.Divider(color: _primaryColor, thickness: 2),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Pending Amount',
                      style: pw.TextStyle(font: fontBold, fontSize: 14, color: _primaryColor),
                    ),
                    pw.Text(
                      _currencyFormat.format(claim.pendingAmount),
                      style: pw.TextStyle(font: fontBold, fontSize: 16, color: _primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoItem(
    String label,
    String value,
    pw.Font font,
    pw.Font fontMedium,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(font: font, fontSize: 9, color: _darkGray),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(font: fontMedium, fontSize: 11, color: _primaryColor),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(
    String label,
    String value,
    pw.Font font,
    pw.Font fontMedium,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(font: font, fontSize: 10, color: _darkGray),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: fontMedium, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryRow(
    String label,
    double amount,
    pw.Font font,
    pw.Font fontMedium,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(font: font, fontSize: 11, color: _darkGray),
          ),
          pw.Text(
            _currencyFormat.format(amount),
            style: pw.TextStyle(font: fontMedium, fontSize: 11),
          ),
        ],
      ),
    );
  }

  static PdfColor _getStatusColor(dynamic status) {
    final statusName = status.toString().split('.').last;
    switch (statusName) {
      case 'draft':
        return PdfColor.fromHex('#6B7280');
      case 'submitted':
        return PdfColor.fromHex('#3B82F6');
      case 'underReview':
        return PdfColor.fromHex('#F59E0B');
      case 'approved':
        return PdfColor.fromHex('#10B981');
      case 'rejected':
        return PdfColor.fromHex('#EF4444');
      case 'partiallySettled':
        return PdfColor.fromHex('#8B5CF6');
      case 'fullySettled':
        return PdfColor.fromHex('#059669');
      case 'closed':
        return PdfColor.fromHex('#374151');
      default:
        return PdfColor.fromHex('#6B7280');
    }
  }

  static Future<void> downloadPdf(Uint8List pdfBytes, String fileName) async {
    if (kIsWeb) {
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    } else {
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    }
  }

  static Future<void> sharePdf(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }

  static Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }

  static Future<void> previewPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }
}
