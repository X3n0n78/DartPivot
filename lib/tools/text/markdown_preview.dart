import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

final markdownPreviewTool = ToolItemImpl(
  id: 'markdown-preview',
  name: 'Markdown Preview',
  description: 'Write and preview Markdown text.',
  icon: Icons.preview,
  category: ToolCategory.text,
  route: '/text/markdown',
  builder: (context) => const MarkdownPreview(),
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

class MarkdownPreview extends StatefulWidget {
  const MarkdownPreview({super.key});

  @override
  State<MarkdownPreview> createState() => _MarkdownPreviewState();
}

class _MarkdownPreviewState extends State<MarkdownPreview> {
  late CodeController _controller;
  String _markdownData = '';

  @override
  void initState() {
    super.initState();
    _controller = CodeController(language: markdown);
    _controller.addListener(_updatePreview);
    _markdownData = _controller.text;
  }

  @override
  void dispose() {
    _controller.removeListener(_updatePreview);
    _controller.dispose();
    super.dispose();
  }

  void _updatePreview() {
    setState(() {
      _markdownData = _controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ToolScaffold(
      title: 'Markdown Preview',
      description: 'Write and preview Markdown.',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          if (isWide) {
            return Row(
              children: [
                Expanded(child: _buildEditor(isDark)),
                const VerticalDivider(width: 1),
                Expanded(child: _buildPreview()),
              ],
            );
          } else {
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Editor'),
                      Tab(text: 'Preview'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [_buildEditor(isDark), _buildPreview()],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEditor(bool isDark) {
    return CodeTheme(
      data: CodeThemeData(styles: isDark ? atomOneDarkTheme : githubTheme),
      child: CodeField(controller: _controller, expands: true, wrap: true),
    );
  }

  Widget _buildPreview() {
    return Container(
      color: Theme.of(context).cardColor,
      child: Markdown(
        data: _markdownData,
        selectable: true,
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
