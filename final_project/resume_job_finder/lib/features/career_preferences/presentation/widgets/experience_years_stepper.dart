import 'package:material_ui/material_ui.dart';

class ExperienceYearsStepper extends StatelessWidget {
  const ExperienceYearsStepper({
    super.key,
    required this.years,
    required this.unitLabel,
    required this.onIncrement,
    required this.onDecrement,
    this.enabled = true,
  });

  final int years;
  final String unitLabel;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: enabled && years > 0 ? onDecrement : null,
              icon: const Icon(Icons.remove_rounded),
            ),
            Text(
              '$years $unitLabel',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            IconButton.filledTonal(
              onPressed: enabled && years < 25 ? onIncrement : null,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
