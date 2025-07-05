import 'package:sqflite/sqflite.dart';
import 'package:invoiceapp/models/invoice_template.dart';
import 'package:invoiceapp/services/database_service.dart';
import 'dart:convert';

class TemplateService {
  static const String _templateTable = 'invoice_templates';
  static const String _settingsTable = 'template_settings';

  // Called from DatabaseService
  static Future<void> createTemplateTable(Database db) async {
    print("Creating template table...");
    await db.execute('''
      CREATE TABLE $_templateTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        colors TEXT NOT NULL,
        layout TEXT NOT NULL,
        isDefault INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $_settingsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        selected_template_id INTEGER DEFAULT 1,
        FOREIGN KEY (selected_template_id) REFERENCES $_templateTable (id)
      )
    ''');

    // Insert default templates
    await _insertDefaultTemplates(db);

    // Insert default settings
    await db.insert(_settingsTable, {'selected_template_id': 1});

    print("Template table created with default templates.");
  }

  static Future<void> _insertDefaultTemplates(Database db) async {
    for (final template in DefaultTemplates.templates) {
      await db.insert(_templateTable, {
        'id': template.id,
        'name': template.name,
        'description': template.description,
        'colors': jsonEncode(template.colors.toMap()),
        'layout': jsonEncode(template.layout.toMap()),
        'isDefault': template.isDefault ? 1 : 0,
      });
    }
  }

  static Future<List<InvoiceTemplate>> getAllTemplates() async {
    final db = await DatabaseService.instance.getdatabase();
    final result = await db.query(_templateTable);

    return result.map((row) {
      return InvoiceTemplate(
        id: row['id'] as int,
        name: row['name'] as String,
        description: row['description'] as String,
        colors: TemplateColors.fromMap(jsonDecode(row['colors'] as String)),
        layout: TemplateLayout.fromMap(jsonDecode(row['layout'] as String)),
        isDefault: (row['isDefault'] as int) == 1,
      );
    }).toList();
  }

  static Future<InvoiceTemplate?> getTemplateById(int id) async {
    final db = await DatabaseService.instance.getdatabase();
    final result = await db.query(
      _templateTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      final row = result.first;
      return InvoiceTemplate(
        id: row['id'] as int,
        name: row['name'] as String,
        description: row['description'] as String,
        colors: TemplateColors.fromMap(jsonDecode(row['colors'] as String)),
        layout: TemplateLayout.fromMap(jsonDecode(row['layout'] as String)),
        isDefault: (row['isDefault'] as int) == 1,
      );
    }
    return null;
  }

  static Future<InvoiceTemplate> getSelectedTemplate() async {
    final db = await DatabaseService.instance.getdatabase();
    final result = await db.query(_settingsTable, limit: 1);

    int selectedId = 1; // Default to template 1
    if (result.isNotEmpty) {
      selectedId = result.first['selected_template_id'] as int;
    }

    final template = await getTemplateById(selectedId);
    return template ?? DefaultTemplates.templates.first;
  }

  static Future<void> setSelectedTemplate(int templateId) async {
    final db = await DatabaseService.instance.getdatabase();

    // Check if settings exist
    final result = await db.query(_settingsTable);
    if (result.isNotEmpty) {
      await db.update(
        _settingsTable,
        {'selected_template_id': templateId},
        where: 'id = ?',
        whereArgs: [result.first['id']],
      );
    } else {
      await db.insert(_settingsTable, {'selected_template_id': templateId});
    }

    print("Selected template updated to ID: $templateId");
  }

  static Future<int> saveCustomTemplate(InvoiceTemplate template) async {
    final db = await DatabaseService.instance.getdatabase();

    final id = await db.insert(_templateTable, {
      'name': template.name,
      'description': template.description,
      'colors': jsonEncode(template.colors.toMap()),
      'layout': jsonEncode(template.layout.toMap()),
      'isDefault': 0,
    });

    print("Custom template saved with ID: $id");
    return id;
  }

  static Future<void> updateTemplate(InvoiceTemplate template) async {
    final db = await DatabaseService.instance.getdatabase();

    await db.update(
      _templateTable,
      {
        'name': template.name,
        'description': template.description,
        'colors': jsonEncode(template.colors.toMap()),
        'layout': jsonEncode(template.layout.toMap()),
      },
      where: 'id = ?',
      whereArgs: [template.id],
    );

    print("Template ID ${template.id} updated.");
  }

  static Future<void> deleteTemplate(int id) async {
    final db = await DatabaseService.instance.getdatabase();

    // Don't delete default templates
    final template = await getTemplateById(id);
    if (template?.isDefault == true) {
      throw Exception('Cannot delete default template');
    }

    await db.delete(
      _templateTable,
      where: 'id = ? AND isDefault = 0',
      whereArgs: [id],
    );

    print("Template ID $id deleted.");
  }

  static Future<void> resetToDefaults() async {
    final db = await DatabaseService.instance.getdatabase();

    // Delete all custom templates
    await db.delete(_templateTable, where: 'isDefault = 0');

    // Reset selected template to default
    await setSelectedTemplate(1);

    print("Templates reset to defaults.");
  }
}
