import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oliminate_mobile/features/merchandise/screens/merchandise_form_page.dart';
import 'package:oliminate_mobile/features/user-profile/auth_repository.dart';
import 'package:oliminate_mobile/left_drawer.dart';
import 'dart:convert';
import '../models/merchandise_model.dart'; // Import the new model file
import 'cart_page.dart';
import 'merchandise_detail.dart'; // Import the CartPage

// --- Main Widget ---

class MerchandisePage extends StatefulWidget {
  final String apiUrl = 'http://localhost:8000/merchandise/list/'; 
  
  const MerchandisePage({super.key});

  @override
  State<MerchandisePage> createState() => _MerchandisePageState();
}

class _MerchandisePageState extends State<MerchandisePage> {
  List<Merchandise> merchandises = [];
  List<CategoryChoice> categoryChoices = [];
  bool isLoading = true;
  String? currentSort; 
  String? currentCategory; 
  final _authRepo = AuthRepository.instance;
  bool isLoggedIn = false;
  String? userRole;
  String? userName;
  
  // PLACEHOLDER: Set this to true to see the Edit/Delete buttons.
  // In a real app, this should be set after checking the user's role post-login.
  // final bool _isOrganizer = true; 

  @override
  void initState() {
    super.initState();
    categoryChoices = [CategoryChoice(value: '', label: 'All Categories')];
    _loadAuthState().then((_) => fetchMerchandise());
  }

  Future<void> _loadAuthState() async {
    await _authRepo.init(); // restores cookies
    final ok = await _authRepo.validateSession(); // sets cachedProfile on success
    if (!mounted) return;
    if (!ok) {
      setState(() {
        isLoggedIn = false;
        userRole = null;
      });
      return;
    }
    // cachedProfile should now be available (validateSession calls _parseProfile)
    final p = _authRepo.cachedProfile ?? await _authRepo.fetchProfile();
    if (!mounted) return;
    setState(() {
      isLoggedIn = p != null;
      userRole = p?.role?.trim();
      userName = p?.username?.trim();
    });
  }

  // Fetches data from the Django API with current filters and sort applied
  Future<void> fetchMerchandise() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Build query parameters
      Map<String, String> queryParams = {};
      if (currentCategory != null && currentCategory!.isNotEmpty) {
        queryParams['category'] = currentCategory!;
      }
      if (currentSort != null) {
        queryParams['sort_by'] = currentSort!;
      }

      final uri = Uri.parse(widget.apiUrl).replace(queryParameters: queryParams);
      
      final response = await http.get(uri); 
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        List<Merchandise> fetchedMerch = (data['merchandises'] as List)
            .map((json) => Merchandise.fromJson(json))
            .toList();

        List<CategoryChoice> fetchedCategories = (data['category_choices'] as List)
            .map((json) => CategoryChoice.fromList(json))
            .toList();
        
        fetchedCategories.insert(0, CategoryChoice(value: '', label: 'All Categories'));

        setState(() {
          merchandises = fetchedMerch;
          categoryChoices = fetchedCategories;
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load merchandise: ${response.statusCode}')),
        );
        setState(() { isLoading = false; });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
      setState(() { isLoading = false; });
    }
  }

  void _onCategoryChanged(String? newValue) {
    if (newValue != null && newValue != currentCategory) {
      setState(() {
        currentCategory = newValue.isEmpty ? null : newValue;
        fetchMerchandise();
      });
    }
  }

  void _onSortChanged(String? newValue) {
    if (newValue != null && newValue != currentSort) {
      setState(() {
        currentSort = newValue;
        fetchMerchandise();
      });
    }
  }

  // --- NEW: Management API Calls ---

  // Function to simulate navigation to an edit form (not implemented here)
  void _editMerchandise(Merchandise merch) {
    // Navigate to Detail Page and pass the current Merchandise object
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MerchandiseFormPage(merchandise: merch, categoryChoices: categoryChoices),
      ),
    );
  }


  Future<void> _deleteMerchandise(String merchandiseId, String name) async {
    // 1. Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "$name"? This cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // 2. Perform API call
    final baseUrl = widget.apiUrl.substring(0, widget.apiUrl.indexOf('/merchandise'));
    // URL: /merchandise/<uuid:id>/delete/
    final url = Uri.parse('$baseUrl/merchandise/$merchandiseId/delete/');

    try {
      final response = await http.post(
        url,
      );

      if (response.statusCode == 302 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Merchandise "$name" deleted successfully.')),
        );
        // Refresh the list after successful deletion
        fetchMerchandise();
      } else if (response.statusCode == 403) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Only Organizers can delete merchandise (403 Forbidden).')),
        );
      } 
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete merchandise. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error during deletion: $e')),
      );
    }
  }

  // ---------------------------------


  @override
  Widget build(BuildContext context) {
    final baseUrl = widget.apiUrl.substring(0, widget.apiUrl.indexOf('/merchandise'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchandise Catalog'),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (isLoggedIn && userRole?.toLowerCase() == 'organizer') // Add a button for creating new items if the user is an organizer
            IconButton(
              icon: const Icon(Icons.add_box),
              tooltip: 'Add New Merchandise',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MerchandiseFormPage(merchandise: null, categoryChoices: categoryChoices),
                  ),
                );
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CartPage(),
                  ),
                );
              },
            ),
        ],
      ),
      drawer: LeftDrawer(),
      body: Column(
        children: <Widget>[
          // Filter and Sort Controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    value: currentCategory ?? '',
                    items: categoryChoices.map((CategoryChoice category) {
                      return DropdownMenuItem<String>(
                        value: category.value,
                        child: Text(category.label),
                      );
                    }).toList(),
                    onChanged: _onCategoryChanged,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Sort By',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    value: currentSort,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Default')),
                      const DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                      const DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                    ],
                    onChanged: _onSortChanged,
                  ),
                ),
              ],
            ),
          ),
          
          // Merchandise Grid
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : merchandises.isEmpty
                    ? Center(child: Text('No merchandise found for category: ${currentCategory ?? "All"}'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.65, // Adjusted ratio for management buttons
                        ),
                        itemCount: merchandises.length,
                        itemBuilder: (context, index) {
                          return _MerchandiseCard(
                            merch: merchandises[index],
                            baseUrl: baseUrl,
                            isLoggedIn: isLoggedIn,
                            userRole: userRole,
                            userName: userName,
                            onEdit: _editMerchandise, // Pass edit function
                            onDelete: _deleteMerchandise, // Pass delete function
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// --- Individual Card Widget (Stateful for loading state) ---

class _MerchandiseCard extends StatefulWidget {
  final Merchandise merch;
  final String baseUrl; 
  final bool isLoggedIn; 
  final String? userRole;
  final String? userName;
  final Function(Merchandise) onEdit; // NEW: Callback for editing
  final Function(String, String) onDelete; // NEW: Callback for deleting

  const _MerchandiseCard({
    required this.merch, 
    required this.baseUrl, 
    required this.isLoggedIn,
    required this.userRole,
    required this.userName,
    required this.onEdit, 
    required this.onDelete,
  });

  @override
  State<_MerchandiseCard> createState() => _MerchandiseCardState();
}

class _MerchandiseCardState extends State<_MerchandiseCard> {
  bool _isAddingToCart = false; // Local state for loading indicator

  String? _getResolvedImageUrl(String? url) {
    // if (url == null || url.isEmpty) {
    //   return null;
    // }
    // if (url.startsWith('http://') || url.startsWith('https://')) {
    //   return url;
    // }
    // try {
    //   Uri baseUri = Uri.parse(widget.baseUrl);
    //   Uri resolvedUri = baseUri.resolve(url);
    //   return resolvedUri.toString();
    // } catch (e) {
    //   return '${widget.baseUrl}$url';
    // }
    return 'http://localhost:8000/merchandise/proxy-image/?url=${Uri.encodeComponent(widget.merch.imageUrl.toString())}';
  }
  
  // --- Add to Cart API Implementation ---
  Future<void> _addToCart() async {
    if (widget.merch.stock == 0) return;

    setState(() {
      _isAddingToCart = true;
    });
    
    // Construct the full URL for the cart_add_item endpoint 
    final url = Uri.parse(
        '${widget.baseUrl}/merchandise/cart/add/${widget.merch.id}/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'quantity': 1, 
        }),
      );

      if (response.statusCode == 302 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil menambahkan 1x ${widget.merch.name} ke keranjang!')),
        );
      } else {
        String message = response.statusCode == 403 
            ? 'Gagal: Sesi login tidak valid (403 Forbidden). Cek sessionid dan csrftoken.' 
            : 'Gagal menambahkan ke keranjang. Status: ${response.statusCode}';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
      );
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image_not_supported, 
          color: Colors.grey, 
          size: 50
        ),
      ),
    );
  }

  Widget _imageLoadingIndicator() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isStockAvailable = widget.merch.stock > 0;
    final resolvedImageUrl = _getResolvedImageUrl(widget.merch.imageUrl);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Image Container
          Container(
            width: double.infinity,
            height: 300, 
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: resolvedImageUrl != null 
                ? Image.network(
                    resolvedImageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                       return _imagePlaceholder();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _imageLoadingIndicator();
                    },
                  )
                : _imagePlaceholder(),
          ),
          
          // Details
          Expanded( // Use Expanded to ensure the remaining space is filled
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.merch.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${widget.merch.price.toString()}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stock: ${widget.merch.stock}',
                        style: TextStyle(
                          color: isStockAvailable ? Colors.grey[600] : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.merch.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // Action Buttons (Management or User)
                  Column(
                    children: [
                      if (widget.isLoggedIn)
                        if (widget.userRole?.toLowerCase() == 'user') // Show regular user button
                          ElevatedButton(
                            onPressed: isStockAvailable && !_isAddingToCart ? _addToCart : null, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isStockAvailable ? Colors.blue : Colors.grey[400],
                              minimumSize: const Size(double.infinity, 36),
                            ),
                            child: _isAddingToCart
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isStockAvailable ? 'Tambah ke Keranjang' : 'Stok Habis',
                                    style: TextStyle(color: isStockAvailable ? Colors.white : Colors.black54),
                                  ),
                          )
                        else if (widget.userRole?.toLowerCase() == 'organizer' && widget.userName == widget.merch.organizerUsername)// Show management buttons if organizer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit', style: TextStyle(fontSize: 12)),
                                  onPressed: () => widget.onEdit(widget.merch),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete', style: TextStyle(fontSize: 12)),
                                  onPressed: () => widget.onDelete(widget.merch.id, widget.merch.name),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        
                        const SizedBox(height: 8),
                        // Detail Button (always present)
                        OutlinedButton(
                          onPressed: () {
                            // Navigate to Detail Page and pass the current Merchandise object
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MerchandiseDetailScreen(merchandise: widget.merch, userRole: widget.userRole,),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 36)),
                          child: const Text('Detail'),
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
}