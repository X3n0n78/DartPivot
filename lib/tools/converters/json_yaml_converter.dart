import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:yaml/yaml.dart' as yaml_parser;
import 'package:json2yaml/json2yaml.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import '../../core/models/tool_item.dart';
import '../../core/widgets/tool_scaffold.dart';

// Tool Definition
final jsonYamlConverterTool = ToolItemImpl(
  id: 'json-yaml',
  name: 'JSON <> YAML',
  description: 'Convert JSON data to YAML and vice versa.',
  icon: Icons.data_object,
  category: ToolCategory.converters,
  route: '/converters/json-yaml',
  builder: (context) => const JsonYamlConverter(),
);

// Implementation of ToolItem interface
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

class JsonYamlConverter extends ConsumerStatefulWidget {
  const JsonYamlConverter({super.key});

  @override
  ConsumerState<JsonYamlConverter> createState() => _JsonYamlConverterState();
}

class _JsonYamlConverterState extends ConsumerState<JsonYamlConverter> {
  late CodeController _jsonController;
  late CodeController _yamlController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _jsonController = CodeController(language: json);
    _yamlController = CodeController(language: yaml);
  }

  @override
  void dispose() {
    _jsonController.dispose();
    _yamlController.dispose();
    super.dispose();
  }

  void _convertJsonToYaml() {
    setState(() => _error = null);
    try {
      if (_jsonController.text.trim().isEmpty) return;

      final dynamic decoded = jsonDecode(_jsonController.text);
      final yamlString = json2yaml(decoded, yamlStyle: YamlStyle.pubspecYaml);
      _yamlController.text = yamlString;
    } catch (e) {
      setState(() => _error = 'Invalid JSON: $e');
    }
  }

  void _convertYamlToJson() {
    setState(() => _error = null);
    try {
      if (_yamlController.text.trim().isEmpty) return;

      final decoded = yaml_parser.loadYaml(_yamlController.text);
      // loadYaml returns YamlMap/YamlList which converts to JSON nicely via jsonEncode
      final jsonString = const JsonEncoder.withIndent('  ').convert(decoded);
      _jsonController.text = jsonString;
    } catch (e) {
      setState(() => _error = 'Invalid YAML: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMap = isDark ? atomOneDarkTheme : githubTheme;

    return ToolScaffold(
      title: 'JSON <> YAML Converter',
      description: 'Convert JSON data to YAML and vice versa.',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          final children = [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'JSON',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        FilledButton.tonal(
                          onPressed: _convertJsonToYaml,
                          child: const Text(
                            'To YAML ->',
                          ), // Icon converts to down arrow on narrow
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CodeTheme(
                      data: CodeThemeData(styles: themeMap),
                      child: CodeField(
                        controller: _jsonController,
                        expands: true,
                        wrap: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isWide) const VerticalDivider(width: 1),
            if (!isWide) const Divider(height: 1),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!isWide)
                          FilledButton.tonal(
                            onPressed: _convertYamlToJson,
                            child: const Text(
                              'To JSON ->',
                            ), // Up arrow or similar
                          )
                        else
                          const SizedBox(), // Spacer

                        Text(
                          'YAML',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        if (isWide)
                          FilledButton.tonal(
                            onPressed: _convertYamlToJson,
                            child: const Text('<- To JSON'),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CodeTheme(
                      data: CodeThemeData(styles: themeMap),
                      child: CodeField(
                        controller: _yamlController,
                        expands: true,
                        wrap: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];

          return Column(
            children: [
              if (_error != null)
                Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              Expanded(
                child: isWide
                    ? Row(children: children)
                    : Column(children: children),
              ),
            ],
          );
        },
      ),
    );
  }
}
