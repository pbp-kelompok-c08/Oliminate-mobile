import 'package:flutter/material.dart';
import 'package:oliminate_mobile/features/user-profile/auth_repository.dart';
import '../models/merchandise_model.dart'; // Merchandise and CategoryChoice

class MerchandiseFormPage extends StatefulWidget {
  // If editing, this will contain the existing merchandise data. Null for creation.
  final Merchandise? merchandise;
  
  // List of available categories fetched from the list page.
  final List<CategoryChoice> categoryChoices;

  const MerchandiseFormPage({
    super.key,
    required this.merchandise,
    required this.categoryChoices,
  });

  @override
  State<MerchandiseFormPage> createState() => _MerchandiseFormPageState();
}

class _MerchandiseFormPageState extends State<MerchandiseFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool isUpdate = false;

  // Controllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialize form fields if editing an existing merchandise
    if (widget.merchandise != null) {
      _nameController.text = widget.merchandise!.name;
      _descriptionController.text = widget.merchandise!.description;
      _priceController.text = widget.merchandise!.price.toString();
      _stockController.text = widget.merchandise!.stock.toString();
      _imageUrlController.text = widget.merchandise!.imageUrl ?? '';
      _selectedCategory = widget.merchandise!.category;
    } else {
      // Default category to the first non-All option, or null if list is empty/only has All.
      _selectedCategory = widget.categoryChoices.length > 1 ? widget.categoryChoices[1].value : null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // --- API Submission Logic (Create or Update) ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });

    final isUpdate = widget.merchandise != null;
    
    // Determine the target URL based on whether we are creating or updating
    // Create URL: http://localhost:8000/merchandise/create
    // Update URL: http://localhost:8000/merchandise/<id>/edit/
    final String path = isUpdate 
        ? '/merchandise/list/${widget.merchandise!.id}/edit/' 
        : '/merchandise/list/create/';

    try {
      // Data payload - must match the fields expected by MerchandiseForm in Django
      final Map<String, String> body = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': _priceController.text,
        'stock': _stockController.text,
        'category': _selectedCategory!,
        // Django's form expects 'image_url' to be set, though we handle it as a field here.
        'image_url': _imageUrlController.text,
      };

      final response = await AuthRepository.instance.client.postForm(path, body: body);
      // final response = await http.post(
      //   url,
      //   headers: {
      //     'Content-Type': 'application/json',
      //   },
      //   body: json.encode(body),
      // );

      // Check for successful redirection (302) or 200 OK (if Django doesn't redirect)
      if (response.statusCode == 302 || response.statusCode == 200) {
        String action = isUpdate ? 'updated' : 'created';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Merchandise successfully $action!')),
        );
        // Navigate back to the list page
        Navigator.pop(context, true); 
      } else if (response.statusCode == 403) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: You are not authorized to perform this action (403 Forbidden).')),
        );
      } else {
        // Handle form errors or other failures
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit form. Status: ${response.statusCode}')),
        );
        // Optionally, parse the response body for specific Django form errors
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error during submission: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
  
  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    final title = widget.merchandise == null ? 'Create New Merchandise' : 'Edit Merchandise: ${widget.merchandise!.name}';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 1. Name Field
              _buildTextField(_nameController, 'Name', isRequired: true),
              
              // 2. Description Field
              _buildTextField(_descriptionController, 'Description', maxLines: 3),
              
              // 3. Price Field
              _buildTextField(_priceController, 'Price (Rp)', isRequired: true, keyboardType: TextInputType.number),
              
              // 4. Stock Field
              _buildTextField(_stockController, 'Stock', isRequired: true, keyboardType: TextInputType.number),

              // 5. Category Dropdown
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: _selectedCategory,
                items: widget.categoryChoices
                    .where((c) => c.value.isNotEmpty) // Exclude "All Categories" placeholder
                    .map((CategoryChoice category) {
                      return DropdownMenuItem<String>(
                        value: category.value,
                        child: Text(category.label),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Please select a category.' : null,
              ),

              // 6. Image URL Field
              _buildTextField(_imageUrlController, 'Image URL (Optional)', keyboardType: TextInputType.url),
              
              const SizedBox(height: 32),

              // 7. Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitForm,
                icon: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(
                  isUpdate 
                    ? (_isSubmitting ? 'Saving Changes...' : 'Save Changes')
                    : (_isSubmitting ? 'Creating...' : 'Create Merchandise'),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper widget for standard text fields
  Widget _buildTextField(
    TextEditingController controller, 
    String label, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: _getIconForLabel(label),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'The $label field is required.';
          }
          if (keyboardType == TextInputType.number) {
             if (value != null && double.tryParse(value) == null) {
              return 'Must be a valid number.';
            }
          }
          return null;
        },
      ),
    );
  }
  
  // Helper to get an appropriate icon for the field label
  Icon _getIconForLabel(String label) {
    if (label.contains('Name')) return const Icon(Icons.drive_file_rename_outline);
    if (label.contains('Description')) return const Icon(Icons.description);
    if (label.contains('Price')) return const Icon(Icons.attach_money);
    if (label.contains('Stock')) return const Icon(Icons.inventory);
    if (label.contains('URL')) return const Icon(Icons.image);
    return const Icon(Icons.text_fields);
  }
}