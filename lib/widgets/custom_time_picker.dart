import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;

  const CustomTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late TimeOfDay selectedTime;
  bool isAM = true;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
    isAM = selectedTime.hour < 12;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Time',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeSection(
                    selectedTime.hourOfPeriod.toString().padLeft(2, '0'),
                    'Hour',
                    (value) {
                      final newHour = (value % 12) + (isAM ? 0 : 12);
                      setState(() {
                        selectedTime = TimeOfDay(
                          hour: newHour,
                          minute: selectedTime.minute,
                        );
                      });
                    },
                    1,
                    12,
                    selectedTime.hourOfPeriod,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      ':',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildTimeSection(
                    selectedTime.minute.toString().padLeft(2, '0'),
                    'Minute',
                    (value) {
                      setState(() {
                        selectedTime = TimeOfDay(
                          hour: selectedTime.hour,
                          minute: value,
                        );
                      });
                    },
                    0,
                    59,
                    selectedTime.minute,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAmPmButton('AM', true),
                const SizedBox(width: 16),
                _buildAmPmButton('PM', false),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    widget.onTimeSelected(selectedTime);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(
    String value,
    String label,
    Function(int) onChanged,
    int min,
    int max,
    int current,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_drop_up, color: Colors.white, size: 36),
          onPressed: () {
            onChanged(current < max ? current + 1 : min);
          },
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon:
              const Icon(Icons.arrow_drop_down, color: Colors.white, size: 36),
          onPressed: () {
            onChanged(current > min ? current - 1 : max);
          },
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildAmPmButton(String text, bool isAm) {
    final isSelected = isAM == isAm;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          isAM = isAm;
          final newHour = selectedTime.hour % 12 + (isAM ? 0 : 12);
          selectedTime = TimeOfDay(hour: newHour, minute: selectedTime.minute);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
