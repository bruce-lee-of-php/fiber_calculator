import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/project_estimate.dart';

class PdfExporter {
  static Future<void> generateAndSharePdf(ProjectEstimate estimate) async {
    final doc = pw.Document();
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final numberFormat = NumberFormat.decimalPattern('en_US');

    const primaryColor = PdfColors.black;
    final secondaryColor = PdfColor.fromHex('#888888');
    final accentColor = PdfColor.fromHex('#EFE8FC');
    final lightGreyColor = PdfColor.fromHex('#EEEEEE');

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.letter,
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.latoRegular(),
        bold: await PdfGoogleFonts.latoBold(),
      ),
      buildBackground: (pw.Context context) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [
                  accentColor,
                  PdfColor.fromHex('#FCF2F4'),
                  PdfColors.white,
                ],
                begin: pw.Alignment.topCenter,
                end: pw.Alignment.bottomCenter,
              ),
            ),
          ),
        );
      },
    );

    doc.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (pw.Context context) => [
          _buildHeader(estimate, primaryColor),
          pw.SizedBox(height: 20),
          _buildSectionHeader('Itemized Material Costs', secondaryColor),
          _buildMaterialTable(
            estimate,
            currencyFormat,
            numberFormat,
            lightGreyColor,
          ),
          pw.SizedBox(height: 20),
          _buildSectionHeader('Itemized Labor Costs', secondaryColor),
          _buildLaborTable(
            estimate,
            currencyFormat,
            numberFormat,
            lightGreyColor,
          ),
          pw.SizedBox(height: 20),
          _buildSectionHeader('Other Direct Costs', secondaryColor),
          _buildOtherCostsTable(
            estimate,
            currencyFormat,
            numberFormat,
            lightGreyColor,
          ),
          pw.SizedBox(height: 20),
          _buildTotals(estimate, currencyFormat, primaryColor),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'fiber_optic_estimate_${DateTime.now().toIso8601String()}.pdf',
    );
  }

  static pw.Widget _buildHeader(
    ProjectEstimate estimate,
    PdfColor primaryColor,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Fiber Optic Installation Cost Estimate',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 22,
            color: primaryColor,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Date: ${DateFormat.yMMMd().format(DateTime.now())}'),
        pw.Text(
          'Total Project Length: ${estimate.totalLength.toStringAsFixed(0)} ft',
        ),
        pw.Text('Fiber Count: ${estimate.fiberCount.toInt()}f'),
      ],
    );
  }

  static pw.Widget _buildSectionHeader(String title, PdfColor secondaryColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 16,
          color: secondaryColor,
        ),
      ),
    );
  }

  static pw.Widget _buildMaterialTable(
    ProjectEstimate estimate,
    NumberFormat currencyFormat,
    NumberFormat numberFormat,
    PdfColor borderColor,
  ) {
    final headers = ['Description', 'Quantity', 'Unit', 'Cost'];
    final data = [
      [
        "${estimate.fiberCount.toInt()}f Cable",
        numberFormat.format(estimate.totalLength),
        "ft",
        currencyFormat.format(estimate.cableCost),
      ],
      if (estimate.includeConduit)
        [
          "Conduit",
          numberFormat.format(estimate.totalLength),
          "ft",
          currencyFormat.format(estimate.conduitCost),
        ],
      [
        "Handholes/Vaults",
        numberFormat.format(estimate.numberOfHandholes),
        "each",
        currencyFormat.format(estimate.handholeCost),
      ],
      [
        "${estimate.fiberCount.toInt()}f Splice Closures",
        numberFormat.format(estimate.numberOfSpliceLocations),
        "each",
        currencyFormat.format(estimate.closureCost),
      ],
      [
        "Termination Hardware",
        "1",
        "lot",
        currencyFormat.format(estimate.terminationHardwareCost),
      ],
    ];

    return _buildTable(headers, data, borderColor);
  }

  static pw.Widget _buildLaborTable(
    ProjectEstimate estimate,
    NumberFormat currencyFormat,
    NumberFormat numberFormat,
    PdfColor borderColor,
  ) {
    final headers = ['Description', 'Quantity', 'Unit', 'Cost'];
    var data = [
      [
        "Mobilization & Setup",
        "1",
        "each",
        currencyFormat.format(estimate.setupCost),
      ],
      if (estimate.isBoring)
        [
          "Directional Boring",
          numberFormat.format(estimate.totalLength),
          "ft",
          currencyFormat.format(estimate.installationCost),
        ]
      else ...[
        if (estimate.lengthSoftscape > 0)
          [
            "Trenching (Softscape)",
            numberFormat.format(estimate.lengthSoftscape),
            "ft",
            currencyFormat.format(
              estimate.lengthSoftscape * estimate.priceTrenchingSoftscape,
            ),
          ],
        if (estimate.lengthAsphalt > 0)
          [
            "Trenching (Asphalt)",
            numberFormat.format(estimate.lengthAsphalt),
            "ft",
            currencyFormat.format(
              estimate.lengthAsphalt * estimate.priceTrenchingAsphalt,
            ),
          ],
        if (estimate.lengthConcrete > 0)
          [
            "Trenching (Concrete)",
            numberFormat.format(estimate.lengthConcrete),
            "ft",
            currencyFormat.format(
              estimate.lengthConcrete * estimate.priceTrenchingConcrete,
            ),
          ],
      ],
      [
        "Handhole Excavation",
        numberFormat.format(estimate.numberOfHandholes),
        "each",
        currencyFormat.format(estimate.excavationCost),
      ],
      [
        "Splicing",
        numberFormat.format(
          estimate.numberOfSpliceLocations * estimate.fiberCount,
        ),
        "splices",
        currencyFormat.format(estimate.splicingCost),
      ],
      if (estimate.restorationCost > 0)
        [
          "Site Restoration",
          numberFormat.format(estimate.lengthAsphalt + estimate.lengthConcrete),
          "ft",
          currencyFormat.format(estimate.restorationCost),
        ],
      [
        "Testing & Commissioning",
        "1",
        "lot",
        currencyFormat.format(estimate.testingCost),
      ],
    ];

    return _buildTable(headers, data, borderColor);
  }

  static pw.Widget _buildOtherCostsTable(
    ProjectEstimate estimate,
    NumberFormat currencyFormat,
    NumberFormat numberFormat,
    PdfColor borderColor,
  ) {
    final headers = ['Description', 'Quantity', 'Unit', 'Cost'];
    final data = [
      ["Permit Costs", "1", "lot", currencyFormat.format(estimate.permitCosts)],
      [
        "Traffic Control",
        numberFormat.format(estimate.trafficDays),
        "days",
        currencyFormat.format(estimate.trafficControlCost),
      ],
    ];

    return _buildTable(headers, data, borderColor);
  }

  static pw.Widget _buildTotals(
    ProjectEstimate estimate,
    NumberFormat currencyFormat,
    PdfColor primaryColor,
  ) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 250,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Divider(color: PdfColors.grey400),
            _buildTotalRow(
              'Subtotal:',
              currencyFormat.format(estimate.subTotal),
              primaryColor,
            ),
            _buildTotalRow(
              'Contingency (${(estimate.totalContingencyRate * 100).toStringAsFixed(0)}%):',
              currencyFormat.format(estimate.contingencyAmount),
              primaryColor,
            ),
            pw.Divider(color: PdfColors.grey400),
            _buildTotalRow(
              'Final Estimated Cost:',
              currencyFormat.format(estimate.finalCost),
              primaryColor,
              isBold: true,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTotalRow(
    String title,
    String value,
    PdfColor color, {
    bool isBold = false,
    double fontSize = 12,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: fontSize,
              color: color,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: fontSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(
    List<String> headers,
    List<List<String>> data,
    PdfColor borderColor,
  ) {
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: borderColor, width: 1),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#F0F0F0')),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
      },
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }
}
