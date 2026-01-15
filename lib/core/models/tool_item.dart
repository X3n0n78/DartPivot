import 'package:flutter/material.dart';

enum ToolCategory { converters, formatters, generators, text, graphics }

abstract class ToolItem {
  String get id;
  String get name;
  String get description;
  IconData get icon;
  ToolCategory get category;
  String get route;
  WidgetBuilder get builder;
}
