import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_estimate.dart';
import 'help.dart';
import 'summary.dart';

class EstimateScreen extends StatefulWidget {
  const EstimateScreen({super.key});

  @override
  State<EstimateScreen> createState() => _EstimateScreenState();
}

class _EstimateScreenState extends State<EstimateScreen> {
  bool _isAdvancedMode = false;

  // Controllers for dynamically updated text fields
  late final TextEditingController _boringController;
  late final TextEditingController _trenchSoftscapeController;
  late final TextEditingController _trenchAsphaltController;
  late final TextEditingController _trenchConcreteController;
  late final TextEditingController _cablePriceController;
  late final TextEditingController _testingCostController;

  @override
  void initState() {
    super.initState();
    final estimate = Provider.of<ProjectEstimate>(context, listen: false);

    // Initialize controllers with model's default values
    _boringController = TextEditingController(
      text: estimate.priceBoring.toString(),
    );
    _trenchSoftscapeController = TextEditingController(
      text: estimate.priceTrenchingSoftscape.toString(),
    );
    _trenchAsphaltController = TextEditingController(
      text: estimate.priceTrenchingAsphalt.toString(),
    );
    _trenchConcreteController = TextEditingController(
      text: estimate.priceTrenchingConcrete.toString(),
    );
    _cablePriceController = TextEditingController(
      text: estimate.cablePricePerFoot.toStringAsFixed(2),
    );
    _testingCostController = TextEditingController(
      text: estimate.testingCost.toStringAsFixed(2),
    );

    // Add listeners to update the model when the user types
    _boringController.addListener(
      () => estimate.updateValue(
        'priceBoring',
        double.tryParse(_boringController.text) ?? 0.0,
      ),
    );
    _trenchSoftscapeController.addListener(
      () => estimate.updateValue(
        'priceTrenchingSoftscape',
        double.tryParse(_trenchSoftscapeController.text) ?? 0.0,
      ),
    );
    _trenchAsphaltController.addListener(
      () => estimate.updateValue(
        'priceTrenchingAsphalt',
        double.tryParse(_trenchAsphaltController.text) ?? 0.0,
      ),
    );
    _trenchConcreteController.addListener(
      () => estimate.updateValue(
        'priceTrenchingConcrete',
        double.tryParse(_trenchConcreteController.text) ?? 0.0,
      ),
    );
    _cablePriceController.addListener(
      () => estimate.updateValue(
        'cablePricePerFoot',
        double.tryParse(_cablePriceController.text) ?? 0.0,
      ),
    );
    _testingCostController.addListener(
      () => estimate.updateValue(
        'testingCost',
        double.tryParse(_testingCostController.text) ?? 0.0,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of controllers to prevent memory leaks
    _boringController.dispose();
    _trenchSoftscapeController.dispose();
    _trenchAsphaltController.dispose();
    _trenchConcreteController.dispose();
    _cablePriceController.dispose();
    _testingCostController.dispose();
    super.dispose();
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estimate = Provider.of<ProjectEstimate>(context);

    // Sync controller text with the model state if it hasn't been manually overridden
    if (!estimate.isCablePriceOverridden) {
      _cablePriceController.text = estimate.cablePricePerFoot.toStringAsFixed(
        2,
      );
    }
    if (!estimate.isTestingCostOverridden) {
      _testingCostController.text = estimate.testingCost.toStringAsFixed(2);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cost Estimator',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
          Row(
            children: [
              Text('Advanced', style: TextStyle(color: Colors.grey[600])),
              Switch(
                value: _isAdvancedMode,
                activeColor: Colors.black,
                onChanged: (value) {
                  setState(() {
                    _isAdvancedMode = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF4EFFB),
              const Color(0xFFFCF2F4),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isAdvancedMode) _buildSimpleForm(estimate),
              if (_isAdvancedMode) _buildAdvancedForm(estimate),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SummaryScreen(),
                    ),
                  );
                },
                child: const Text('Calculate Cost'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleForm(ProjectEstimate estimate) {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Installation Lengths (ft)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Softscape',
                  initialValue: estimate.lengthSoftscape.toString(),
                  onChanged: (value) => estimate.updateValue(
                    'lengthSoftscape',
                    double.tryParse(value) ?? 0.0,
                  ),
                ),
                _buildTextField(
                  label: 'Asphalt',
                  initialValue: estimate.lengthAsphalt.toString(),
                  onChanged: (value) => estimate.updateValue(
                    'lengthAsphalt',
                    double.tryParse(value) ?? 0.0,
                  ),
                ),
                _buildTextField(
                  label: 'Concrete',
                  initialValue: estimate.lengthConcrete.toString(),
                  onChanged: (value) => estimate.updateValue(
                    'lengthConcrete',
                    double.tryParse(value) ?? 0.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Fiber Count',
          initialValue: estimate.fiberCount.toString(),
          onChanged: (value) =>
              estimate.updateValue('fiberCount', double.tryParse(value) ?? 0.0),
        ),
        _buildTextField(
          label: 'Number of Handholes/Pull Boxes',
          initialValue: estimate.numberOfHandholes.toString(),
          onChanged: (value) => estimate.updateValue(
            'numberOfHandholes',
            int.tryParse(value) ?? 0,
          ),
        ),
        _buildTextField(
          label: 'Number of Splice Locations',
          initialValue: estimate.numberOfSpliceLocations.toString(),
          onChanged: (value) => estimate.updateValue(
            'numberOfSpliceLocations',
            int.tryParse(value) ?? 0,
          ),
        ),
        const SizedBox(height: 16),
        _buildSwitchField(
          title: 'Include Conduit?',
          subtitle: 'Affects cable type used in calculation',
          value: estimate.includeConduit,
          onChanged: (value) => estimate.updateValue('includeConduit', value),
          tooltip:
              'Using conduit provides protection and allows for cheaper, non-armored cable, but adds cost for the conduit itself.',
        ),
      ],
    );
  }

  Widget _buildAdvancedForm(ProjectEstimate estimate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Primary Inputs'),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Installation Lengths (ft)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  label: 'Softscape',
                  initialValue: estimate.lengthSoftscape.toString(),
                  onChanged: (value) => estimate.updateValue(
                    'lengthSoftscape',
                    double.tryParse(value) ?? 0.0,
                  ),
                ),
                _buildTextField(
                  label: 'Asphalt',
                  initialValue: estimate.lengthAsphalt.toString(),
                  onChanged: (value) => estimate.updateValue(
                    'lengthAsphalt',
                    double.tryParse(value) ?? 0.0,
                  ),
                ),
                _buildTextField(
                  label: 'Concrete',
                  initialValue: estimate.lengthConcrete.toString(),
                  onChanged: (value) => estimate.updateValue(
                    'lengthConcrete',
                    double.tryParse(value) ?? 0.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Fiber Count',
          initialValue: estimate.fiberCount.toString(),
          onChanged: (value) =>
              estimate.updateValue('fiberCount', double.tryParse(value) ?? 0.0),
        ),
        _buildTextField(
          label: 'Number of Handholes',
          initialValue: estimate.numberOfHandholes.toString(),
          onChanged: (value) => estimate.updateValue(
            'numberOfHandholes',
            int.tryParse(value) ?? 0,
          ),
        ),
        _buildTextField(
          label: 'Number of Splice Locations',
          initialValue: estimate.numberOfSpliceLocations.toString(),
          onChanged: (value) => estimate.updateValue(
            'numberOfSpliceLocations',
            double.tryParse(value) ?? 0.0,
          ),
        ),

        const SizedBox(height: 24),
        _buildSectionHeader('Installation Method & Rates (\$)'),
        _buildSwitchField(
          title: 'Use Directional Boring?',
          subtitle: 'Default is Trenching',
          value: estimate.isBoring,
          onChanged: (value) {
            setState(() {
              estimate.updateValue('isBoring', value);
            });
          },
          tooltip:
              'Trenching costs vary by surface and require restoration. Boring has a higher upfront cost but avoids surface restoration fees.',
        ),
        const SizedBox(height: 16),
        if (estimate.isBoring)
          _buildTextField(
            label: 'Price per Foot (Boring)',
            prefix: '\$',
            controller: _boringController,
          )
        else ...[
          _buildTextField(
            label: 'Price per Foot (Trenching - Softscape)',
            prefix: '\$',
            controller: _trenchSoftscapeController,
          ),
          _buildTextField(
            label: 'Price per Foot (Trenching - Asphalt)',
            prefix: '\$',
            controller: _trenchAsphaltController,
          ),
          _buildTextField(
            label: 'Price per Foot (Trenching - Concrete)',
            prefix: '\$',
            controller: _trenchConcreteController,
          ),
        ],

        const SizedBox(height: 24),
        _buildSectionHeader('Other Labor Costs (\$)'),

        if (!estimate.isBoring) ...[
          _buildTextField(
            label: 'Asphalt Restoration per Foot',
            prefix: '\$',
            initialValue: estimate.priceRestoreAsphalt.toString(),
            onChanged: (value) => estimate.updateValue(
              'priceRestoreAsphalt',
              double.tryParse(value) ?? 0.0,
            ),
            tooltip:
                'Cost to repair asphalt after trenching. Not applicable for boring.',
          ),
          _buildTextField(
            label: 'Concrete Restoration per Foot',
            prefix: '\$',
            initialValue: estimate.priceRestoreConcrete.toString(),
            onChanged: (value) => estimate.updateValue(
              'priceRestoreConcrete',
              double.tryParse(value) ?? 0.0,
            ),
            tooltip:
                'Cost to repair concrete after trenching. Not applicable for boring.',
          ),
        ],

        _buildTextField(
          label: 'Mobilization/Setup Cost',
          prefix: '\$',
          initialValue: estimate.pricePerSetup.toString(),
          onChanged: (value) => estimate.updateValue(
            'pricePerSetup',
            double.tryParse(value) ?? 0.0,
          ),
        ),
        _buildTextField(
          label: 'Price per Splice',
          prefix: '\$',
          initialValue: estimate.pricePerSplice.toString(),
          onChanged: (value) => estimate.updateValue(
            'pricePerSplice',
            double.tryParse(value) ?? 0.0,
          ),
        ),
        _buildTextField(
          label: 'Total Testing Cost (Override)',
          prefix: '\$',
          controller: _testingCostController,
        ),

        const SizedBox(height: 24),
        _buildSectionHeader('Material Costs (\$)'),
        _buildTextField(
          label: 'Cable Price per Foot (Override)',
          prefix: '\$',
          controller: _cablePriceController,
        ),
        _buildTextField(
          label: 'Base Price per Fiber (Splice Closure)',
          prefix: '\$',
          initialValue: estimate.basePricePerFiberClosure.toString(),
          onChanged: (value) => estimate.updateValue(
            'basePricePerFiberClosure',
            double.tryParse(value) ?? 0.0,
          ),
        ),
        _buildSwitchField(
          title: 'Include Conduit?',
          subtitle: '',
          value: estimate.includeConduit,
          onChanged: (value) {
            setState(() {
              estimate.updateValue('includeConduit', value);
            });
          },
          tooltip:
              'Using conduit provides protection and allows for cheaper, non-armored cable, but adds cost for the conduit itself.',
        ),
        const SizedBox(height: 16),
        if (estimate.includeConduit)
          _buildTextField(
            label: 'Price per Foot (Conduit)',
            prefix: '\$',
            initialValue: estimate.pricePerFootConduit.toString(),
            onChanged: (value) => estimate.updateValue(
              'pricePerFootConduit',
              double.tryParse(value) ?? 0.0,
            ),
          ),
        _buildTextField(
          label: 'Price per Handhole',
          prefix: '\$',
          initialValue: estimate.pricePerHandhole.toString(),
          onChanged: (value) => estimate.updateValue(
            'pricePerHandhole',
            double.tryParse(value) ?? 0.0,
          ),
        ),

        const SizedBox(height: 24),
        _buildSectionHeader('Ancillary Costs & Contingencies'),
        _buildTextField(
          label: 'Days of Traffic Control',
          initialValue: estimate.trafficDays.toString(),
          onChanged: (value) =>
              estimate.updateValue('trafficDays', int.tryParse(value) ?? 0),
        ),
        _buildTextField(
          label: 'Traffic Control Cost per Day',
          prefix: '\$',
          initialValue: estimate.trafficCostPerDay.toString(),
          onChanged: (value) => estimate.updateValue(
            'trafficCostPerDay',
            double.tryParse(value) ?? 0.0,
          ),
        ),
        _buildTextField(
          label: 'Permit Costs',
          prefix: '\$',
          initialValue: estimate.permitCosts.toString(),
          onChanged: (value) => estimate.updateValue(
            'permitCosts',
            double.tryParse(value) ?? 0.0,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Design Contingency (${(estimate.designContingency * 100).toStringAsFixed(0)}%)',
          style: TextStyle(color: Colors.grey[600]),
        ),
        Slider(
          value: estimate.designContingency,
          min: 0.0,
          max: 0.3,
          divisions: 6,
          label: '${(estimate.designContingency * 100).toStringAsFixed(0)}%',
          activeColor: Colors.black,
          onChanged: (value) =>
              estimate.updateValue('designContingency', value),
        ),
        const SizedBox(height: 8),
        Text(
          'Construction Contingency (${(estimate.constructionContingency * 100).toStringAsFixed(0)}%)',
          style: TextStyle(color: Colors.grey[600]),
        ),
        Slider(
          value: estimate.constructionContingency,
          min: 0.0,
          max: 0.3,
          divisions: 6,
          label:
              '${(estimate.constructionContingency * 100).toStringAsFixed(0)}%',
          activeColor: Colors.black,
          onChanged: (value) =>
              estimate.updateValue('constructionContingency', value),
        ),
      ],
    );
  }

  Widget _buildTextField({
    Key? key,
    required String label,
    String? prefix,
    String? initialValue,
    String? tooltip,
    Function(String)? onChanged,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        key: key,
        initialValue: controller == null ? initialValue : null,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix,
          suffixIcon: tooltip != null
              ? IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () => _showInfoDialog(label, tooltip),
                )
              : null,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: controller == null ? onChanged : null,
      ),
    );
  }

  Widget _buildSwitchField({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: SwitchListTile(
              value: value,
              onChanged: onChanged,
              title: Text(title, style: const TextStyle(fontSize: 16)),
              subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.grey.shade400,
              size: 20,
            ),
            onPressed: () => _showInfoDialog(title, tooltip),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
