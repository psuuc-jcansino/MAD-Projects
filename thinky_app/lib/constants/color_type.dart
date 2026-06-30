import 'package:flutter/material.dart';

enum ColorType {
  red(Colors.red),
  blue(Colors.blue),
  green(Colors.green),
  yellow(Colors.yellow),
  orange(Colors.orange),
  purple(Colors.purple),
  pink(Colors.pink),
  brown(Colors.brown),
  black(Colors.black);

  final Color value;
  const ColorType(this.value);
}
