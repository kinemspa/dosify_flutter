import 'package:flutter/material.dart';
import '../../../features/medication/ui/medication_list_screen.dart';
import '../../../features/medication/ui/reconstitution_calculator_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dosify Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  // Medications
                  _DashboardCard(
                    title: 'Medications',
                    color: Colors.blue,
                    icon: Icons.medication,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MedicationListScreen(),
                        ),
                      );
                    },
                  ),
                  // Schedules
                  _DashboardCard(
                    title: 'Schedules',
                    color: Colors.green,
                    icon: Icons.schedule,
                    onPressed: () {
                      // Navigate to schedules screen
                    },
                  ),
                  // Inventory
                  _DashboardCard(
                    title: 'Inventory',
                    color: Colors.orange,
                    icon: Icons.inventory,
                    onPressed: () {
                      // Navigate to inventory screen
                    },
                  ),
                  // Reconstitution Calculator
                  _DashboardCard(
                    title: 'Reconstitution Calculator',
                    color: Colors.purple,
                    icon: Icons.calculate,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ReconstitutionCalculatorScreen(),
                        ),
                      );
                    },
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

class _DashboardCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const _DashboardCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios)
            ],
          ),
        ),
      ),
    );
  }
}
