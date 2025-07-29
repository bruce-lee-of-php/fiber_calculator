import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/project_estimate.dart';
import '../services/pdf_exporter.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final estimate = Provider.of<ProjectEstimate>(context, listen: false);
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final numberFormat = NumberFormat.decimalPattern('en_US');

    final materialLineItems = [
      {
        "name": "${estimate.fiberCount.toInt()}f Cable",
        "qty": estimate.totalLength,
        "unit": "ft",
        "cost": estimate.cableCost,
      },
      if (estimate.includeConduit)
        {
          "name": "Conduit",
          "qty": estimate.totalLength,
          "unit": "ft",
          "cost": estimate.conduitCost,
        },
      {
        "name": "Handholes/Vaults",
        "qty": estimate.numberOfHandholes,
        "unit": "each",
        "cost": estimate.handholeCost,
      },
      {
        "name": "${estimate.fiberCount.toInt()}f Splice Closures",
        "qty": estimate.numberOfSpliceLocations,
        "unit": "each",
        "cost": estimate.closureCost,
      },
      {
        "name": "Termination Hardware",
        "qty": 1,
        "unit": "lot",
        "cost": estimate.terminationHardwareCost,
      },
    ];

    final laborLineItems = [
      {
        "name": "Mobilization & Setup",
        "qty": 1,
        "unit": "each",
        "cost": estimate.setupCost,
      },
      if (estimate.isBoring)
        {
          "name": "Directional Boring",
          "qty": estimate.totalLength,
          "unit": "ft",
          "cost": estimate.installationCost,
        }
      else ...[
        if (estimate.lengthSoftscape > 0)
          {
            "name": "Trenching (Softscape)",
            "qty": estimate.lengthSoftscape,
            "unit": "ft",
            "cost": estimate.lengthSoftscape * estimate.priceTrenchingSoftscape,
          },
        if (estimate.lengthAsphalt > 0)
          {
            "name": "Trenching (Asphalt)",
            "qty": estimate.lengthAsphalt,
            "unit": "ft",
            "cost": estimate.lengthAsphalt * estimate.priceTrenchingAsphalt,
          },
        if (estimate.lengthConcrete > 0)
          {
            "name": "Trenching (Concrete)",
            "qty": estimate.lengthConcrete,
            "unit": "ft",
            "cost": estimate.lengthConcrete * estimate.priceTrenchingConcrete,
          },
      ],
      {
        "name": "Handhole Excavation",
        "qty": estimate.numberOfHandholes,
        "unit": "each",
        "cost": estimate.excavationCost,
      },
      {
        "name": "Splicing",
        "qty": (estimate.numberOfSpliceLocations * estimate.fiberCount),
        "unit": "splices",
        "cost": estimate.splicingCost,
      },
      if (estimate.restorationCost > 0)
        {
          "name": "Site Restoration",
          "qty": (estimate.lengthAsphalt + estimate.lengthConcrete),
          "unit": "ft",
          "cost": estimate.restorationCost,
        },
      {
        "name": "Testing & Commissioning",
        "qty": 1,
        "unit": "lot",
        "cost": estimate.testingCost,
      },
    ];

    final otherLineItems = [
      {
        "name": "Permit Costs",
        "qty": 1,
        "unit": "lot",
        "cost": estimate.permitCosts,
      },
      {
        "name": "Traffic Control",
        "qty": estimate.trafficDays,
        "unit": "days",
        "cost": estimate.trafficControlCost,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Cost Summary')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          PdfExporter.generateAndSharePdf(estimate);
        },
        child: const Icon(Icons.share),
        tooltip: 'Export as PDF',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(context, 'Itemized Material Costs'),
            Card(
              child: Column(
                children: [
                  ...materialLineItems.map(
                    (item) => _buildItemRow(
                      context,
                      item['name'].toString(),
                      '${numberFormat.format(item['qty'])} ${item['unit']}',
                      currencyFormat.format(item['cost']),
                    ),
                  ),
                  const Divider(thickness: 1.5),
                  _buildTotalRow(
                    context,
                    'Total Materials:',
                    currencyFormat.format(estimate.materialCost),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Itemized Labor Costs'),
            Card(
              child: Column(
                children: [
                  ...laborLineItems.map(
                    (item) => _buildItemRow(
                      context,
                      item['name'].toString(),
                      '${numberFormat.format(item['qty'])} ${item['unit']}',
                      currencyFormat.format(item['cost']),
                    ),
                  ),
                  const Divider(thickness: 1.5),
                  _buildTotalRow(
                    context,
                    'Total Labor:',
                    currencyFormat.format(estimate.laborCost),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Other Costs'),
            Card(
              child: Column(
                children: [
                  ...otherLineItems.map(
                    (item) => _buildItemRow(
                      context,
                      item['name'].toString(),
                      '${numberFormat.format(item['qty'])} ${item['unit']}',
                      currencyFormat.format(item['cost']),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Project Totals'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFinalTotalRow(
                      'Subtotal',
                      currencyFormat.format(estimate.subTotal),
                    ),
                    const SizedBox(height: 8),
                    _buildFinalTotalRow(
                      'Contingency (${(estimate.totalContingencyRate * 100).toStringAsFixed(0)}%)',
                      currencyFormat.format(estimate.contingencyAmount),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Final Estimated Cost',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(estimate.finalCost),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Provider.of<ProjectEstimate>(context, listen: false).reset();
                Navigator.pop(context);
              },
              child: const Text('Start New Estimate'),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildItemRow(
    BuildContext context,
    String name,
    String qty,
    String cost,
  ) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Text(name),
      trailing: Text(
        cost,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(qty),
    );
  }

  Widget _buildTotalRow(BuildContext context, String title, String cost) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        cost,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFinalTotalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
