import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tool_item.dart';
import '../../tools/converters/json_yaml_converter.dart';
import '../../tools/converters/number_base_converter.dart';
import '../../tools/converters/base64_converter.dart';
import '../../tools/formatters/json_formatter.dart';
import '../../tools/formatters/sql_formatter.dart';
import '../../tools/formatters/xml_formatter.dart';
import '../../tools/generators/uuid_generator.dart';
import '../../tools/generators/hash_generator.dart';
import '../../tools/generators/lorem_ipsum_generator.dart';
import '../../tools/generators/password_generator.dart';
import '../../tools/text/diff_checker.dart';
import '../../tools/text/regex_tester.dart';
import '../../tools/text/markdown_preview.dart';
import '../../tools/graphics/image_resizer.dart';
import '../../tools/graphics/png_to_jpg_converter.dart';
import '../../tools/graphics/color_tools.dart';

final toolRegistryProvider = Provider<List<ToolItem>>((ref) {
  return [
    jsonYamlConverterTool,
    numberBaseConverterTool,
    base64ConverterTool,
    jsonFormatterTool,
    sqlFormatterTool,
    xmlFormatterTool,
    uuidGeneratorTool,
    hashGeneratorTool,
    loremIpsumGeneratorTool,
    passwordGeneratorTool,
    diffCheckerTool,
    regexTesterTool,
    markdownPreviewTool,
    imageResizerTool,
    pngToJpgConverterTool,
    colorTools,
  ];
});

final toolsByCategoryProvider = Provider<Map<ToolCategory, List<ToolItem>>>((
  ref,
) {
  final tools = ref.watch(toolRegistryProvider);
  final map = <ToolCategory, List<ToolItem>>{};

  for (var category in ToolCategory.values) {
    map[category] = tools.where((t) => t.category == category).toList();
  }

  return map;
});
