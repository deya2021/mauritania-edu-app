import 'package:flutter/material.dart';
import '../models/models.dart';
import '../l10n/app_localizations.dart';

class ExerciseWidget extends StatefulWidget {
  final Exercise exercise;
  final int index;
  final Function(bool isCorrect) onSubmit;
  final bool? previousResult;
  
  const ExerciseWidget({
    Key? key,
    required this.exercise,
    required this.index,
    required this.onSubmit,
    this.previousResult,
  }) : super(key: key);
  
  @override
  State<ExerciseWidget> createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget> {
  String? _selectedAnswer;
  bool? _isCorrect;
  
  @override
  void initState() {
    super.initState();
    _isCorrect = widget.previousResult;
  }
  
  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    
    final isCorrect = _selectedAnswer == widget.exercise.correctAnswer;
    
    setState(() {
      _isCorrect = isCorrect;
    });
    
    widget.onSubmit(isCorrect);
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${l10n.question} ${widget.index}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (_isCorrect != null)
                  Icon(
                    _isCorrect! ? Icons.check_circle : Icons.cancel,
                    color: _isCorrect! ? Colors.green : Colors.red,
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Question text
            Text(
              widget.exercise.question,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Answer options
            if (widget.exercise.type == 'mcq' && widget.exercise.options != null)
              ..._buildMCQOptions()
            else if (widget.exercise.type == 'true_false')
              ..._buildTrueFalseOptions(l10n),
            
            const SizedBox(height: 16),
            
            // Submit button
            if (_isCorrect == null)
              ElevatedButton(
                onPressed: _selectedAnswer == null ? null : _submitAnswer,
                child: Text(l10n.submit),
              ),
            
            // Result feedback
            if (_isCorrect != null) ...[
              const Divider(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isCorrect!
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCorrect! ? l10n.correct : l10n.incorrect,
                      style: TextStyle(
                        color: _isCorrect! ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.exercise.explanation != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.explanation}: ${widget.exercise.explanation}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildMCQOptions() {
    return widget.exercise.options!.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final optionValue = index.toString();
      final isSelected = _selectedAnswer == optionValue;
      
      return RadioListTile<String>(
        value: optionValue,
        groupValue: _selectedAnswer,
        onChanged: _isCorrect == null
            ? (value) {
                setState(() {
                  _selectedAnswer = value;
                });
              }
            : null,
        title: Text(option),
        activeColor: Theme.of(context).primaryColor,
        selected: isSelected,
      );
    }).toList();
  }
  
  List<Widget> _buildTrueFalseOptions(AppLocalizations l10n) {
    return [
      RadioListTile<String>(
        value: 'true',
        groupValue: _selectedAnswer,
        onChanged: _isCorrect == null
            ? (value) {
                setState(() {
                  _selectedAnswer = value;
                });
              }
            : null,
        title: Text(l10n.trueText),
        activeColor: Theme.of(context).primaryColor,
      ),
      RadioListTile<String>(
        value: 'false',
        groupValue: _selectedAnswer,
        onChanged: _isCorrect == null
            ? (value) {
                setState(() {
                  _selectedAnswer = value;
                });
              }
            : null,
        title: Text(l10n.falseText),
        activeColor: Theme.of(context).primaryColor,
      ),
    ];
  }
}
