// lib/utils/ingredient_translator.dart
// Kamus terjemahan bahan-bahan kopi.
// Istilah kopi universal (steamed milk, microfoam, espresso, dll) dibiarkan asli.
// Hanya bahan umum & bahasa Swedia yang diterjemahkan ke Indonesia.

class IngredientTranslator {
  static const Map<String, String> _dict = {
    // === ISTILAH KOPI UNIVERSAL — dibiarkan asli ===
    // (espresso, latte, cappuccino, macchiato, dll tidak perlu diterjemahkan)

    // === SWEDIA → INDONESIA / ISTILAH KOPI ===
    'is': 'Es Batu',
    'mjölk': 'Susu',
    'ångad mjölk': 'Steamed Milk',       // istilah kopi
    'karamellsirap': 'Caramel Syrup',    // istilah kopi
    'karamellsås': 'Caramel Drizzle',   // istilah kopi
    'vispgrädde': 'Whipped Cream',       // istilah kopi
    'vispgrädde*': 'Whipped Cream*',
    'socker': 'Gula',
    'socker*': 'Gula*',
    'citronsaft': 'Air Lemon',
    'te': 'Teh',
    'choklad': 'Cokelat',
    'kaffe': 'Kopi',
    'matcha-pulver': 'Matcha Powder',    // istilah kopi
    'sirap': 'Syrup',

    // === INGGRIS — hanya bahan umum yang diterjemahkan ===
    'coffee': 'Kopi',
    'ice': 'Es Batu',
    'milk': 'Susu',
    'sugar': 'Gula',
    'sugar*': 'Gula*',
    'water': 'Air',
    'hot water': 'Air Panas',
    'cold water': 'Air Dingin',
    'lemon': 'Lemon',
    'rum': 'Rum',
    'rum*': 'Rum*',
    'chocolate': 'Cokelat',

    // === ISTILAH KOPI INGGRIS — dibiarkan asli / distandarisasi ===
    'espresso': 'Espresso',
    'steamed milk': 'Steamed Milk',
    'foam': 'Milk Foam',
    ' foam': 'Milk Foam',               // ada spasi di depan dari API
    'microfoam': 'Microfoam',
    'cream': 'Cream',
    'cream*': 'Cream*',
    'whip': 'Whipped Cream',
    'whip*': 'Whipped Cream*',
    'whipped cream': 'Whipped Cream',
    'caramel': 'Caramel',
    'caramel syrup': 'Caramel Syrup',
    'cocoa': 'Cocoa Powder',
    'matcha': 'Matcha',
    'matcha powder': 'Matcha Powder',
    'vanilla': 'Vanilla',
    'nitrogen bubbles': 'Nitrogen Bubbles',
    'long steeped coffee': 'Long-steeped Coffee',
    'blended ice': 'Blended Ice',
    'syrup': 'Syrup',
    'sweetened condensed milk': 'Susu Kental Manis',
    'ceremonial matcha latte': 'Ceremonial Matcha',
    'caramel macchiato': 'Caramel Macchiato',
  };

  /// Terjemahkan satu bahan.
  static String translate(String ingredient) {
    final key = ingredient.trim().toLowerCase();
    return _dict[key] ?? _capitalize(ingredient.trim());
  }

  /// Terjemahkan seluruh list bahan.
  static List<String> translateAll(List<String> ingredients) {
    return ingredients.map((e) => translate(e)).toList();
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
