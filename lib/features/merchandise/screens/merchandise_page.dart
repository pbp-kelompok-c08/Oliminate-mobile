import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/merchandise_model.dart'; // Ensure this path is correct

// --- Main Widget ---

class MerchandisePage extends StatefulWidget {
  // IMPORTANT: Using localhost:8000 as requested for desktop/web testing.
  // If running on a physical mobile device, this must be replaced with your computer's LAN IP address (e.g., http://192.168.1.x:8000).
  final String baseUrl = 'http://localhost:8000';
  final String apiEndpoint = '/merchandise/list/';
  
  const MerchandisePage({super.key});

  @override
  State<MerchandisePage> createState() => _MerchandisePageState();
}

class _MerchandisePageState extends State<MerchandisePage> {
  List<Merchandise> merchandises = [];
  List<CategoryChoice> categoryChoices = [];
  bool isLoading = true;
  String? currentSort; // price_asc, price_desc, or null (default)
  String? currentCategory; // category value or null (all)

  @override
  void initState() {
    super.initState();
    // Initialize category choices to prevent null list errors on first load
    categoryChoices = [CategoryChoice(value: '', label: 'All Categories')];
    fetchMerchandise();
  }

  // Fetches data from the Django API with current filters and sort applied
  Future<void> fetchMerchandise({String? category, String? sort}) async {
    setState(() {
      isLoading = true;
    });

    // 1. Construct the URL with query parameters
    final Map<String, dynamic> queryParams = {};
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (sort != null && sort.isNotEmpty) {
      queryParams['sort_by'] = sort;
    }

    // Combine base URL and endpoint, then append query parameters
    final uri = Uri.parse('${widget.baseUrl}${widget.apiEndpoint}').replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Use utf8.decode(response.bodyBytes) for robust handling of JSON data
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        
        List<Merchandise> fetchedMerch = [];
        List<CategoryChoice> fetchedChoices = [CategoryChoice(value: '', label: 'All Categories')];
        
        // CRITICAL PARSING STEP: Access the list under the 'merchandises' key
        if (data.containsKey('merchandises') && data['merchandises'] is List) {
          for (var item in data['merchandises']) {
            // The item is passed to Merchandise.fromJson which now has robust casting
            fetchedMerch.add(Merchandise.fromJson(item)); 
          }
        }
        
        // Parse category choices
        if (data.containsKey('category_choices') && data['category_choices'] is List) {
          for (var choice in data['category_choices']) {
            fetchedChoices.add(CategoryChoice.fromList(choice));
          }
        }

        setState(() {
          merchandises = fetchedMerch;
          categoryChoices = fetchedChoices;
          // The API returns the current filters, which we use to update the UI state
          currentCategory = data['current_category']?.toString(); 
          currentSort = data['current_sort']?.toString();
          isLoading = false;
        });
      } else {
        // Handle non-200 responses
        print('Failed to load merchandise. Status: ${response.statusCode}, Body: ${response.body}');
        // Provide user feedback about the server connection issue
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      // This is where the 'NetworkError' is caught.
      print('Error fetching merchandise: $e');
      setState(() {
        isLoading = false;
        // Optionally, show a snakbar or error message in the UI here
      });
      // Re-throw the exception to make it visible
      rethrow; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchandise List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => fetchMerchandise(),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // TODO: Navigate to Cart Page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to Cart (TODO)')),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : merchandises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No merchandise found.', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => fetchMerchandise(),
                        child: const Text('Try Again'),
                      ),
                      // Add troubleshooting info for the user
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'If you see an error like "NetworkError" or "Failed Host Check", make sure your Django server is running and configured for CORS.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildFilterAndSortBar(context),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7, // Adjust to fit card content
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                        ),
                        itemCount: merchandises.length,
                        itemBuilder: (context, index) {
                          return _buildMerchandiseCard(merchandises[index]);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
  
  Widget _buildFilterAndSortBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Category Dropdown
          DropdownButton<String>(
            value: currentCategory ?? '',
            items: categoryChoices.map((choice) {
              return DropdownMenuItem<String>(
                value: choice.value,
                child: Text(choice.label),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                fetchMerchandise(category: newValue, sort: currentSort);
              }
            },
          ),
          
          // Sort Dropdown
          DropdownButton<String>(
            value: currentSort,
            hint: const Text('Sort By'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Default (Name)')),
              DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
              DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
            ],
            onChanged: (String? newValue) {
              fetchMerchandise(category: currentCategory, sort: newValue);
            },
          ),
        ],
      ),
    );
  }

  // Card Widget
  Widget _buildMerchandiseCard(Merchandise merch) {
    final isStockAvailable = merch.stock > 0;
    
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Image/Placeholder
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
              child: merch.imageUrl != null && merch.imageUrl!.isNotEmpty
                  ? Image.network(
                      merch.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ),
          
          // Details and Actions
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merch.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${merch.price}',
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Stock: ${merch.stock}',
                        style: TextStyle(fontSize: 12, color: isStockAvailable ? Colors.grey[600] : Colors.red),
                      ),
                    ],
                  ),
                  
                  // Buttons
                  Column(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          // TODO: Navigate to Detail Page (pass merch.id)
                        },
                        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 36)),
                        child: const Text('Detail'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: isStockAvailable ? () {
                          // TODO: Implement Add to Cart API call
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added ${merch.name} to cart!')
                            ),
                          );
                        } : null, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isStockAvailable ? Colors.blue : Colors.grey[400],
                          minimumSize: const Size(double.infinity, 36),
                        ),
                        child: Text(
                          isStockAvailable ? 'Tambah ke Keranjang' : 'Stok Habis',
                          style: TextStyle(color: isStockAvailable ? Colors.white : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder for missing image
  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported, 
          color: Colors.grey[400], 
          size: 50
        ),
      ),
    );
  }
}