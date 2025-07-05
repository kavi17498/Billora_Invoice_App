# Invoice Template System Documentation

## Overview
The Invoice Template System provides a comprehensive solution for customizing invoice layouts, colors, and styling. Users can select from predefined templates or create custom templates with their own branding and design preferences.

## Features

### 🎨 **Template Management**
- **Predefined Templates**: 5 professionally designed templates with different color schemes
- **Custom Templates**: Create unlimited custom templates with personalized settings
- **Template Selection**: Easily switch between templates for different invoice styles
- **Template Preview**: Real-time preview of how invoices will look with selected template

### 🎯 **Customization Options**

#### **Color Schemes**
- **Primary Color**: Main accent color for headers and emphasis
- **Secondary Color**: Background color for sections and highlights
- **Accent Color**: Additional accent color for borders and details
- **Text Color**: Main text color throughout the invoice
- **Background Color**: Overall background color of the invoice
- **Border Color**: Color for borders and dividers

#### **Layout Options**
- **Header Styles**:
  - `minimal`: Simple header with company info
  - `centered`: Centered layout with logo and company details
  - `split`: Logo on left, company info on right

- **Table Styles**:
  - `simple`: Clean table without borders
  - `striped`: Alternating row colors for better readability
  - `bordered`: Full borders around all cells

- **Additional Options**:
  - Show/hide company logo
  - Show/hide footer
  - Custom footer text

### 📋 **Predefined Templates**

#### 1. **Classic Blue** (Default)
- Professional blue theme with clean layout
- Split header style with bordered table
- Perfect for corporate invoices

#### 2. **Modern Green**
- Fresh green theme with modern design
- Centered header with striped table
- Great for eco-friendly businesses

#### 3. **Elegant Purple**
- Sophisticated purple theme for premium invoices
- Minimal header with simple table
- Ideal for luxury services

#### 4. **Corporate Orange**
- Bold orange theme for corporate invoices
- Split header with bordered table
- Excellent for energetic brands

#### 5. **Minimal Black**
- Clean black and white minimalist design
- Minimal header with simple table
- Perfect for professional services

## Technical Implementation

### 🗃️ **Database Schema**

#### **invoice_templates Table**
```sql
CREATE TABLE invoice_templates (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  colors TEXT NOT NULL,      -- JSON string of color values
  layout TEXT NOT NULL,      -- JSON string of layout settings
  isDefault INTEGER DEFAULT 0
);
```

#### **template_settings Table**
```sql
CREATE TABLE template_settings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  selected_template_id INTEGER DEFAULT 1,
  FOREIGN KEY (selected_template_id) REFERENCES invoice_templates (id)
);
```

### 🏗️ **Architecture**

#### **Models**
- `InvoiceTemplate`: Main template model with colors and layout
- `TemplateColors`: Color scheme configuration
- `TemplateLayout`: Layout and styling options

#### **Services**
- `TemplateService`: CRUD operations for templates
- Template selection and management
- Database operations and default template setup

#### **Screens**
- `TemplateSettingsScreen`: Main template management interface
- `TemplateEditorScreen`: Create/edit template interface
- `TemplatePreviewScreen`: Real-time template preview

### 🔧 **PDF Generation Integration**

The template system is fully integrated with PDF generation:

#### **Template-Based PDF Building**
- Dynamic header generation based on template settings
- Color-coordinated sections and elements
- Layout-specific table styling
- Conditional logo and footer rendering

#### **Helper Functions**
- `_buildHeader()`: Generates header based on template style
- `_buildInvoiceTitle()`: Title section with template colors
- `_buildBillToSection()`: Customer information section
- `_buildItemsTable()`: Items table with template styling
- `_buildTotal()`: Total section with template colors
- `_buildFooter()`: Optional footer with custom text

## Usage Guide

### 🚀 **Getting Started**

1. **Access Templates**: Navigate to Settings → Invoice Templates
2. **Select Template**: Browse available templates and select one
3. **Preview**: Use the preview option to see how your invoices will look
4. **Create Custom**: Use the "+" button to create a custom template

### ✏️ **Creating Custom Templates**

1. **Basic Information**:
   - Enter template name and description
   - Choose descriptive names for easy identification

2. **Color Customization**:
   - Select colors for each element (primary, secondary, accent, text, background, border)
   - Use the color picker to choose exact colors
   - Preview updates in real-time

3. **Layout Configuration**:
   - Choose header style (minimal, centered, split)
   - Select table style (simple, striped, bordered)
   - Toggle logo and footer visibility
   - Set custom footer text

4. **Save Template**:
   - Review your design in the preview section
   - Save the template for future use

### 🎛️ **Template Management**

#### **Template Selection**
- Templates show current selection with "Selected" badge
- Click "Select" from the menu to choose a different template
- Changes apply immediately to new invoices

#### **Template Operations**
- **Preview**: See how the template looks with sample data
- **Edit**: Modify existing templates (custom templates only)
- **Delete**: Remove custom templates (default templates cannot be deleted)
- **Duplicate**: Create variations of existing templates

### 📱 **User Interface**

#### **Template List**
- Grid view of all available templates
- Color swatches showing template color scheme
- Template type indicators (Default, Selected)
- Quick action menu for each template

#### **Template Editor**
- Sectioned interface for different customization areas
- Real-time preview of changes
- Color picker with preset colors
- Form validation for required fields

#### **Template Preview**
- Full-screen preview of invoice layout
- Sample data to show realistic appearance
- Template information display
- Navigation back to template list

## Best Practices

### 🎨 **Design Guidelines**

1. **Color Harmony**:
   - Use complementary colors for professional appearance
   - Ensure sufficient contrast for readability
   - Consider brand colors for consistency

2. **Layout Consistency**:
   - Choose appropriate header style for your business
   - Use bordered tables for detailed invoices
   - Keep footer text concise and professional

3. **Template Naming**:
   - Use descriptive names that indicate purpose
   - Include color or style indicators
   - Maintain consistent naming conventions

### 🔧 **Technical Considerations**

1. **Performance**:
   - Templates are cached for fast loading
   - Color calculations are optimized
   - PDF generation uses efficient rendering

2. **Storage**:
   - Templates are stored in local SQLite database
   - Minimal storage footprint
   - Backup includes template settings

3. **Compatibility**:
   - Works with all existing invoice features
   - Backward compatible with existing invoices
   - Responsive design for different screen sizes

## Troubleshooting

### 🔍 **Common Issues**

1. **Template Not Applying**:
   - Ensure template is selected in settings
   - Check if template has all required fields
   - Restart app if changes don't appear

2. **PDF Generation Issues**:
   - Verify template colors are valid
   - Check if template has required layout settings
   - Ensure template is not corrupted

3. **Custom Template Problems**:
   - Validate all required fields are filled
   - Check color format compatibility
   - Ensure template name is unique

### 💡 **Tips**

1. **Template Organization**:
   - Create templates for different business types
   - Use consistent naming conventions
   - Keep a backup of important custom templates

2. **Color Selection**:
   - Test colors in different lighting conditions
   - Ensure readability when printed
   - Use brand colors for consistency

3. **Layout Choices**:
   - Choose header style based on logo placement
   - Use striped tables for long item lists
   - Include footer for payment instructions

## Future Enhancements

### 🚀 **Planned Features**

1. **Template Sharing**: Export/import templates between devices
2. **Advanced Layouts**: More header and table style options
3. **Template Categories**: Organize templates by business type
4. **Bulk Operations**: Apply templates to multiple invoices
5. **Template Analytics**: Track template usage and performance

The Invoice Template System provides a complete solution for invoice customization, giving users full control over their invoice appearance while maintaining professional standards and ease of use.
