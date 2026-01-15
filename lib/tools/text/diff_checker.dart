import 'package:flutter/material.dart';
import 'package:diff_match_patch/diff_match_patch.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final diffCheckerTool = ToolItemImpl(
  id: 'diff-checker',
  name: 'Diff Checker',
  description: 'Compare two texts and highlight differences.',
  icon: Icons.difference,
  category: ToolCategory.text,
  route: '/text/diff',
  builder: (context) => const DiffChecker(),
);

class ToolItemImpl implements ToolItem {
  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final IconData icon;
  @override
  final ToolCategory category;
  @override
  final String route;
  @override
  final WidgetBuilder builder;

  ToolItemImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.route,
    required this.builder,
  });
}

class DiffChecker extends StatefulWidget {
  const DiffChecker({super.key});

  @override
  State<DiffChecker> createState() => _DiffCheckerState();
}

class _DiffCheckerState extends State<DiffChecker> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  List<Diff> _diffs = [];

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    super.dispose();
  }

  void _compare() {
    final dmp = DiffMatchPatch();
    final diffs = dmp.diff(_oldController.text, _newController.text);
    dmp.diffCleanupSemantic(diffs);
    setState(() {
      _diffs = diffs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolScaffold(
      title: 'Diff Checker',
      description: 'Compare original and new text.',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          return Column(
            children: [
              Expanded(
                flex: 1,
                child: isWide
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildInput('Original Text', _oldController),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInput('New Text', _newController),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: _buildInput('Original Text', _oldController),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _buildInput('New Text', _newController),
                          ),
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FilledButton.icon(
                  onPressed: _compare,
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('Compare'),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: SingleChildScrollView(
                    child: RichText(
                      text: TextSpan(
                        children: _diffs.map((diff) {
                          final text = diff.text;
                          final style = TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          );

                          if (diff.operation == DIFF_DELETE) {
                            return TextSpan(
                              text: text,
                              style: style.copyWith(
                                backgroundColor: Colors.red.withValues(
                                  alpha: 0.3,
                                ),
                                decoration: TextDecoration.lineThrough,
                              ),
                            );
                          } else if (diff.operation == DIFF_INSERT) {
                            return TextSpan(
                              text: text,
                              style: style.copyWith(
                                backgroundColor: Colors.green.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            );
                          } else {
                            return TextSpan(text: text, style: style);
                          }
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onChanged: (_) =>
                _compare(), // Real-time compare? Or assume manual button.
            // Let's do manual button trigger primarily, but realtime is nice.
            // If realtime, it might be slow for large texts. Let's keep manual button logic mainly but I added listener call.
          ),
        ),
      ],
    );
  }
}
