import 'dart:math';

/// The fixed set of category colors and random selection over it.
class CategoryPalette {
  CategoryPalette({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const List<String> colors = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8',
    '#F7DC6F', '#BB8FCE', '#85C1E2', '#F8B739', '#52B788',
    '#E07A5F', '#81B29A', '#F2CC8F', '#A8DADC', '#E63946',
  ];

  String randomColor() => colors[_random.nextInt(colors.length)];
}
