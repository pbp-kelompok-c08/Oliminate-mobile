import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oliminate_mobile/features/merchandise/models/order_summary_model.dart';
import 'package:oliminate_mobile/features/merchandise/screens/cart_paid.dart';
import 'package:oliminate_mobile/features/merchandise/screens/merchandise_form_page.dart';
import 'package:oliminate_mobile/features/user-profile/auth_repository.dart';
import 'package:oliminate_mobile/features/user-profile/main_profile.dart';
import 'dart:convert';
import '../models/merchandise_model.dart';
import 'cart_page.dart';
import 'merchandise_detail.dart';

// --- Main Widget ---

class MerchandisePage extends StatefulWidget {
  final String apiUrl = 'https://adjie-m-oliminate.pbp.cs.ui.ac.id/merchandise/list/'; 
  
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
      userRole = p?.role.trim();
      userName = p?.username.trim();
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
  void _editMerchandise(Merchandise merch) async {
    // Navigate to Detail Page and pass the current Merchandise object
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MerchandiseFormPage(merchandise: merch, categoryChoices: categoryChoices),
      ),
    );
    if (result == true) {
      fetchMerchandise();
    }
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

    // URL: /merchandise/<uuid:id>/delete/
    final url = Uri.parse('/merchandise/list/$merchandiseId/delete/').toString();

    try {
      final response = await _authRepo.client.postForm(url, body:{});

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

  // Color palette matching ticketing design
  static const Color _primaryDark = Color(0xFF113352);
  static const Color _primaryBlue = Color(0xFF3293EC);
  static const Color _accentTeal = Color(0xFF0D9488);
  static const Color _primaryRed = Color(0xFFEA3C43);
  static const Color _neutralBg = Color(0xFFF5F5F5);
  static const Color _textDark = Color(0xFF113352);
  static const Color _textGrey = Color(0xFF3D3D3D);
  static const Color _borderLight = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final baseUrl = widget.apiUrl.substring(0, widget.apiUrl.indexOf('/merchandise'));

    return Scaffold(
      backgroundColor: _neutralBg,
      appBar: AppBar(
        title: const Text(
          'Merchandise',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          // Cart icon for users
          if (isLoggedIn && userRole?.toLowerCase() != 'organizer')
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: 'Keranjang',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
                if (result is Map<String, dynamic> && result.containsKey('order_summary')) {
                  final OrderSummary orderSummary = result['order_summary'];
                  await fetchMerchandise();
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPaidPage(orderSummary: orderSummary)),
                    );
                  }
                }
              },
            ),
          // Profile icon
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      // FAB for Add Merchandise (organizer only)
      floatingActionButton: (isLoggedIn && userRole?.toLowerCase() == 'organizer')
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _accentTeal.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                backgroundColor: _accentTeal,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MerchandiseFormPage(merchandise: null, categoryChoices: categoryChoices),
                    ),
                  );
                  if (result == true) {
                    fetchMerchandise();
                  }
                },
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  'Tambah Produk',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            )
          : null,
      body: Column(
        children: <Widget>[
          // Filter and Sort Controls - Modern styling
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Category Filter
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borderLight),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
                      ]
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentCategory ?? '',
                        isExpanded: true,
                        icon: Icon(Icons.category_rounded, color: _primaryBlue, size: 18),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        style: TextStyle(color: _textDark, fontSize: 13, fontWeight: FontWeight.w600),
                        items: categoryChoices.map((CategoryChoice category) {
                          return DropdownMenuItem<String>(
                            value: category.value,
                            child: Text(category.label),
                          );
                        }).toList(),
                        onChanged: _onCategoryChanged,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Sort Filter
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _borderLight),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
                      ]
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentSort,
                        isExpanded: true,
                        icon: Icon(Icons.sort_rounded, color: _primaryBlue, size: 18),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        style: TextStyle(color: _textDark, fontSize: 13, fontWeight: FontWeight.w600),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Default')),
                          DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                          DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                        ],
                        onChanged: _onSortChanged,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Merchandise Grid
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: _primaryBlue))
                : merchandises.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 0.52,
                        ),
                        itemCount: merchandises.length,
                        itemBuilder: (context, index) {
                          return _MerchandiseCard(
                            merch: merchandises[index],
                            baseUrl: baseUrl,
                            isLoggedIn: isLoggedIn,
                            userRole: userRole,
                            userName: userName,
                            onEdit: _editMerchandise,
                            onDelete: _deleteMerchandise,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_bag_outlined, size: 48, color: _primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(
            "Tidak Ada Merchandise",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark),
          ),
          const SizedBox(height: 8),
          Text(
            "Kategori: ${currentCategory ?? 'Semua'}",
            style: TextStyle(color: _textGrey, fontSize: 13),
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
    return 'https://adjie-m-oliminate.pbp.cs.ui.ac.id/merchandise/proxy-image/?url=${Uri.encodeComponent(widget.merch.imageUrl.toString())}';
  }
  
  // --- Add to Cart API Implementation ---
  Future<void> _addToCart() async {
    if (widget.merch.stock == 0) return;

    setState(() {
      _isAddingToCart = true;
    });
    
    // Construct the full URL for the cart_add_item endpoint 
    final url = Uri.parse(
        '/merchandise/api/cart/add/${widget.merch.id}/').toString();

    try {
      final response = await AuthRepository.instance.client.postForm(url, body: {});

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

  // Color palette matching ticketing design  
  static const Color _primaryDark = Color(0xFF113352);
  static const Color _primaryBlue = Color(0xFF3293EC);
  static const Color _accentTeal = Color(0xFF0D9488);
  static const Color _primaryRed = Color(0xFFEA3C43);
  static const Color _textGrey = Color(0xFF3D3D3D);
  static const Color _borderLight = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final isStockAvailable = widget.merch.stock > 0;
    final resolvedImageUrl = _getResolvedImageUrl(widget.merch.imageUrl);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Image Container
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            child: Container(
              width: double.infinity,
              height: 140, 
              color: Colors.grey[100],
              child: resolvedImageUrl != null 
                  ? Image.network(
                      resolvedImageUrl,
                      fit: BoxFit.cover,
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