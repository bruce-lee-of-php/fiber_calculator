import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Information'),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          HelpSection1(),
          SizedBox(height: 16),
          HelpSection2(),
          SizedBox(height: 16),
          HelpSection3(),
        ],
      ),
    );
  }
}

// Section 1: Inputs Explained (Now with Icons)
class HelpSection1 extends StatelessWidget {
  const HelpSection1({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Inputs Explained',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: const Text('Understanding each field and its impact.'),
      initiallyExpanded: true,
      children: [
        _buildInputExplanation(
          icon: Icons.straighten,
          title: 'Installation Length',
          description:
              'The total distance in feet for the new fiber route from start to finish.',
          impact:
              'This is a primary driver of cost, affecting the total amount of cable/conduit needed and the linear installation labor.',
        ),
        _buildInputExplanation(
          icon: Icons.lan_outlined,
          title: 'Fiber Count',
          description:
              'The number of individual glass fibers in the cable. Common counts are 12, 48, 144, etc. Our default is 48.',
          impact:
              'Increasing the fiber count directly raises the cost of the cable and splice closures, as well as the labor cost for splicing.',
        ),
        _buildInputExplanation(
          icon: Icons.inbox_outlined,
          title: 'Number of Handholes/Pull Boxes',
          description:
              'Access points installed underground, used for pulling cable through conduit and for maintenance. Not all handholes contain splices.',
          impact:
              'Increases the material cost for the handholes and the labor cost for excavating each location.',
        ),
        _buildInputExplanation(
          icon: Icons.alt_route,
          title: 'Number of Splice Locations',
          description:
              'The number of points along the route where fiber cables are fused together (spliced). This is often, but not always, the same as the number of handholes.',
          impact:
              'Directly impacts the cost of splice closures and the total labor for splicing.',
        ),
        _buildInputExplanation(
          icon: Icons.construction,
          title: 'Installation Method (Boring vs. Trenching)',
          description:
              'Trenching involves digging an open trench, while Directional Boring is a trenchless method used to go under obstacles like roads. Boring is typically more expensive per foot.',
          impact:
              'This toggle determines which per-foot labor rate is used for the installation, a major factor in the total labor cost.',
        ),
        _buildInputExplanation(
          icon: Icons.attach_money,
          title: 'Base Price per Fiber-Foot (Cable)',
          description:
              'A "per-fiber, per-foot" cost used to model cable pricing. We use separate, higher prices for armored cable (for direct burial) vs. non-armored (for use in conduit).',
          impact:
              'The total cable cost is this base price multiplied by both the fiber count and the installation length.',
          sourceUrl:
              'https://www.broadbandsearch.net/blog/cost-install-fiber-optic-internet',
        ),
        _buildInputExplanation(
          icon: Icons.merge_type,
          title: 'Price per Splice',
          description:
              'The labor cost to fuse one individual fiber strand to another. Our default of \$30 is a common industry average for a single fusion splice.',
          impact:
              'This cost is multiplied by the total number of splices (Fiber Count x Splice Locations), so it can have a significant impact on larger projects.',
          sourceUrl: 'https://bityi.co/S1tB',
        ),
        _buildInputExplanation(
          icon: Icons.local_shipping,
          title: 'Mobilization/Setup Cost',
          description:
              'A fixed cost to cover transporting heavy equipment (excavator, drill rig) and a crew to the job site.',
          impact:
              'This is a significant fixed cost, especially for smaller projects where it represents a larger percentage of the total.',
        ),
        _buildInputExplanation(
          icon: Icons.task_alt,
          title: 'Total Testing Cost',
          description:
              'The cost to test the installed fiber to ensure it meets performance standards. The app calculates a default based on fiber count and splice locations, but you can override it.',
          impact: 'This is a direct addition to the total labor cost.',
        ),
        _buildInputExplanation(
          icon: Icons.percent,
          title: 'Contingency Rate',
          description:
              'A buffer amount added to the total cost to cover unforeseen problems, scope changes, or inaccuracies in the estimate. A 10-20% contingency is standard practice in construction.',
          impact:
              'This percentage is applied to the subtotal of all other costs to determine the final estimated project price.',
        ),
      ],
    );
  }

  // MODIFIED: Added IconData parameter
  Widget _buildInputExplanation({
    required IconData icon,
    required String title,
    required String description,
    required String impact,
    String? sourceUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MODIFIED: Title is now a Row with an Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(description),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Impact: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: impact),
              ],
            ),
          ),
          if (sourceUrl != null) ...[
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                text: 'View Source',
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _launchURL(sourceUrl),
              ),
            ),
          ],
          const Divider(height: 24),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// Section 2: Calculation Formulas (Unchanged)
class HelpSection2 extends StatelessWidget {
  const HelpSection2({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Calculation Formulas',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: const Text('The math used to generate the summary.'),
      children: [
        _buildFormula(
          'Cable Cost',
          r'Length \times FiberCount \times BasePrice_{cable}',
        ),
        _buildFormula(
          'Splicing Cost',
          r'SpliceLocations \times FiberCount \times Price_{splice}',
        ),
        _buildFormula(
          'Total Material Cost',
          r'Cost_{cable} + Cost_{conduit} + Cost_{handholes} + ...',
        ),
        _buildFormula(
          'Total Labor Cost',
          r'Cost_{setup} + Cost_{install} + Cost_{splicing} + ...',
        ),
        _buildFormula(
          'Final Cost',
          r'(Materials + Labor + Other) \times (1 + Contingency\%)',
        ),
      ],
    );
  }

  Widget _buildFormula(String title, String formula) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Center(
            child: Math.tex(formula, textStyle: const TextStyle(fontSize: 16)),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }
}

// Section 3: Caveats & Blindspots (Unchanged)
class HelpSection3 extends StatelessWidget {
  const HelpSection3({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Caveats & Blindspots',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: const Text('Important factors not included in this estimate.'),
      children: [
        _buildCaveat(
          'Ground Conditions',
          'This estimator assumes standard soil conditions. The presence of rock, clay, high water tables, or extensive tree roots can significantly increase trenching and boring costs.',
        ),
        _buildCaveat(
          'Permits & Fees',
          'Permitting costs vary dramatically between municipalities. Fees for road crossings, environmental impact studies, and traffic control can be substantial and are not fully captured here.',
        ),
        _buildCaveat(
          'Aerial "Make-Ready"',
          'For aerial installations on utility poles, this calculator does not include "make-ready" costs. This is the expensive process of moving existing electrical and communications lines to make room for the new fiber cable.',
        ),
        _buildCaveat(
          'Inside Plant (ISP) Costs',
          'This is an Outside Plant (OSP) estimator. It does not account for any costs associated with bringing the fiber inside a building, such as core drilling, installing racks, or running cable to individual units.',
        ),
      ],
    );
  }

  Widget _buildCaveat(String title, String description) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      dense: true,
    );
  }
}
