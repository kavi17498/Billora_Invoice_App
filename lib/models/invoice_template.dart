import 'package:pdf/pdf.dart';

class InvoiceTemplate {
  final int id;
  final String name;
  final String description;
  final TemplateColors colors;
  final TemplateLayout layout;
  final bool isDefault;

  InvoiceTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.colors,
    required this.layout,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'colors': colors.toMap(),
      'layout': layout.toMap(),
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory InvoiceTemplate.fromMap(Map<String, dynamic> map) {
    return InvoiceTemplate(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      colors: TemplateColors.fromMap(map['colors']),
      layout: TemplateLayout.fromMap(map['layout']),
      isDefault: map['isDefault'] == 1,
    );
  }

  InvoiceTemplate copyWith({
    int? id,
    String? name,
    String? description,
    TemplateColors? colors,
    TemplateLayout? layout,
    bool? isDefault,
  }) {
    return InvoiceTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colors: colors ?? this.colors,
      layout: layout ?? this.layout,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class TemplateColors {
  final PdfColor primary;
  final PdfColor secondary;
  final PdfColor accent;
  final PdfColor text;
  final PdfColor background;
  final PdfColor border;

  TemplateColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.text,
    required this.background,
    required this.border,
  });

  Map<String, dynamic> toMap() {
    return {
      'primary': _colorToHex(primary),
      'secondary': _colorToHex(secondary),
      'accent': _colorToHex(accent),
      'text': _colorToHex(text),
      'background': _colorToHex(background),
      'border': _colorToHex(border),
    };
  }

  factory TemplateColors.fromMap(Map<String, dynamic> map) {
    return TemplateColors(
      primary: _hexToColor(map['primary']),
      secondary: _hexToColor(map['secondary']),
      accent: _hexToColor(map['accent']),
      text: _hexToColor(map['text']),
      background: _hexToColor(map['background']),
      border: _hexToColor(map['border']),
    );
  }

  static String _colorToHex(PdfColor color) {
    final r = (color.red * 255).round();
    final g = (color.green * 255).round();
    final b = (color.blue * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }

  static PdfColor _hexToColor(String hex) {
    final hexValue = hex.replaceAll('#', '');
    final r = int.parse(hexValue.substring(0, 2), radix: 16) / 255.0;
    final g = int.parse(hexValue.substring(2, 4), radix: 16) / 255.0;
    final b = int.parse(hexValue.substring(4, 6), radix: 16) / 255.0;
    return PdfColor(r, g, b);
  }
}

class TemplateLayout {
  final String headerStyle; // 'minimal', 'centered', 'split'
  final String tableStyle; // 'simple', 'striped', 'bordered'
  final bool showLogo;
  final bool showFooter;
  final String footerText;

  TemplateLayout({
    required this.headerStyle,
    required this.tableStyle,
    required this.showLogo,
    required this.showFooter,
    required this.footerText,
  });

  Map<String, dynamic> toMap() {
    return {
      'headerStyle': headerStyle,
      'tableStyle': tableStyle,
      'showLogo': showLogo ? 1 : 0,
      'showFooter': showFooter ? 1 : 0,
      'footerText': footerText,
    };
  }

  factory TemplateLayout.fromMap(Map<String, dynamic> map) {
    return TemplateLayout(
      headerStyle: map['headerStyle'],
      tableStyle: map['tableStyle'],
      showLogo: map['showLogo'] == 1,
      showFooter: map['showFooter'] == 1,
      footerText: map['footerText'],
    );
  }
}

// Predefined templates
class DefaultTemplates {
  static List<InvoiceTemplate> get templates => [
        // Classic Blue Template
        InvoiceTemplate(
          id: 1,
          name: 'Classic Blue',
          description: 'Professional blue theme with clean layout',
          colors: TemplateColors(
            primary: PdfColors.blue800,
            secondary: PdfColors.blue100,
            accent: PdfColors.blue600,
            text: PdfColors.blueGrey900,
            background: PdfColors.white,
            border: PdfColors.grey300,
          ),
          layout: TemplateLayout(
            headerStyle: 'split',
            tableStyle: 'bordered',
            showLogo: true,
            showFooter: true,
            footerText: 'Thank you for your business!',
          ),
          isDefault: true,
        ),

        // Modern Green Template
        InvoiceTemplate(
          id: 2,
          name: 'Modern Green',
          description: 'Fresh green theme with modern design',
          colors: TemplateColors(
            primary: PdfColors.green800,
            secondary: PdfColors.green100,
            accent: PdfColors.green600,
            text: PdfColors.grey900,
            background: PdfColors.white,
            border: PdfColors.grey300,
          ),
          layout: TemplateLayout(
            headerStyle: 'centered',
            tableStyle: 'striped',
            showLogo: true,
            showFooter: true,
            footerText: 'We appreciate your business!',
          ),
        ),

        // Elegant Purple Template
        InvoiceTemplate(
          id: 3,
          name: 'Elegant Purple',
          description: 'Sophisticated purple theme for premium invoices',
          colors: TemplateColors(
            primary: PdfColors.purple800,
            secondary: PdfColors.purple100,
            accent: PdfColors.purple600,
            text: PdfColors.grey900,
            background: PdfColors.white,
            border: PdfColors.grey300,
          ),
          layout: TemplateLayout(
            headerStyle: 'minimal',
            tableStyle: 'simple',
            showLogo: true,
            showFooter: true,
            footerText: 'Thank you for choosing us!',
          ),
        ),

        // Corporate Orange Template
        InvoiceTemplate(
          id: 4,
          name: 'Corporate Orange',
          description: 'Bold orange theme for corporate invoices',
          colors: TemplateColors(
            primary: PdfColors.orange800,
            secondary: PdfColors.orange100,
            accent: PdfColors.orange600,
            text: PdfColors.grey900,
            background: PdfColors.white,
            border: PdfColors.grey300,
          ),
          layout: TemplateLayout(
            headerStyle: 'split',
            tableStyle: 'bordered',
            showLogo: true,
            showFooter: true,
            footerText: 'Your trusted business partner!',
          ),
        ),

        // Minimal Black Template
        InvoiceTemplate(
          id: 5,
          name: 'Minimal Black',
          description: 'Clean black and white minimalist design',
          colors: TemplateColors(
            primary: PdfColors.black,
            secondary: PdfColors.grey100,
            accent: PdfColors.grey600,
            text: PdfColors.grey900,
            background: PdfColors.white,
            border: PdfColors.grey400,
          ),
          layout: TemplateLayout(
            headerStyle: 'minimal',
            tableStyle: 'simple',
            showLogo: true,
            showFooter: false,
            footerText: '',
          ),
        ),
      ];
}
