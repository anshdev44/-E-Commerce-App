import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:async';


class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int inStock;
  final String imageUrl; 

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.inStock,
    required this.imageUrl, 
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      inStock: json['in_stock'] ?? 0,
      imageUrl: json['image_url'] ?? '', 
    );
  }
}

class ElectronicsProduct extends Product {
  final String brand;
  final String model;

  ElectronicsProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String category,
    required int inStock,
    required String imageUrl, 
    required this.brand,
    required this.model,
  }) : super(
          id: id,
          name: name,
          description: description,
          price: price,
          category: category,
          inStock: inStock,
          imageUrl: imageUrl, 
        );

  factory ElectronicsProduct.fromJson(Map<String, dynamic> json) {
    return ElectronicsProduct(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      inStock: json['in_stock'] ?? 0,
      imageUrl: json['image_url'] ?? '', 
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
    );
  }
}

String? currentUserEmail;

void main() {
  runApp(const MyApp());
}

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF6C63FF),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color(0xFF6C63FF),
    secondary: const Color(0xFFFF6584),
    background: const Color(0xFFF8F8FF),
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFFF8F8FF),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 10,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
    filled: true,
    fillColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF6C63FF),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Color(0xFF6C63FF),
      side: const BorderSide(color: Color(0xFF6C63FF), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
    ),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF6C63FF)),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF6C63FF),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF22223B)),
    bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF4A4E69)),
    titleMedium: TextStyle(fontSize: 14, color: Color(0xFF6C63FF)),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce Auth',
      theme: appTheme,
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/products': (context) => const ProductListPage(),
      },
    );
  }
}


class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({Key? key, required this.product, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700])),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(product.category, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
                    ),
                    Row(
                      children: [
                        Icon(Icons.inventory_2, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${product.inStock}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ProductCatalog extends StatelessWidget {
  final List<Product> products;
  final void Function(Product)? onProductTap;

  const ProductCatalog({Key? key, required this.products, this.onProductTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          onTap: onProductTap != null ? () => onProductTap!(products[index]) : null,
        );
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await http.post(
          Uri.parse('${getBackendUrl()}/login'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: 'username=${Uri.encodeComponent(_emailController.text.trim())}&password=${Uri.encodeComponent(_passwordController.text)}',
        );
        setState(() => _isLoading = false);
        if (response.statusCode == 200) {
          final token = jsonDecode(response.body);
          currentUserEmail = _emailController.text.trim();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );
          Navigator.pushReplacementNamed(context, '/products');
        } else {
          final error = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['detail'] ?? 'Login failed')),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7F9FC), Color(0xFFEFF3F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 10,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(Icons.shopping_bag_outlined, size: 28, color: Colors.blue.shade600),
                      ),
                      const SizedBox(height: 16),
                      const Text('Welcome Back', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter your email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter your password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Login', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No account? ', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await http.post(
          Uri.parse('${getBackendUrl()}/signup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          }),
        );
        setState(() => _isLoading = false);
        if (response.statusCode == 200) {
          currentUserEmail = _emailController.text.trim();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup successful! Please log in.')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          final error = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['detail'] ?? 'Signup failed')),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7F9FC), Color(0xFFEFF3F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 10,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.pink.shade50,
                        child: Icon(Icons.person_add_alt_1, size: 28, color: Colors.pink.shade400),
                      ),
                      const SizedBox(height: 16),
                      const Text('Create Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter your username';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter your email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter your password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    if (_searchQuery.isEmpty) {
      _fetchProducts();
    } else {
      _searchProducts(_searchQuery);
    }
  }

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('${getBackendUrl()}/products'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = (data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        setState(() {
          _products = products;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load products';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchProducts(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse('${getBackendUrl()}/products/search?name=${Uri.encodeComponent(query)}');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = (data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        setState(() {
          _products = products;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to search products';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _openProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Products'),
          backgroundColor: Colors.blue.shade400,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              tooltip: 'Cart',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border),
              tooltip: 'Wishlist',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistScreen()),
                );
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/products');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('Your Cart'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Your Wishlist'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WishlistScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search products by name',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : ProductCatalog(products: _products, onProductTap: _openProductDetail),
            ),
          ],
        ),
      ),
    );
  }
}


class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _inCart = false;
  bool _inWishlist = false;
  bool _loading = true;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _checkCartAndWishlist();
  }

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  Future<void> _checkCartAndWishlist() async {
    setState(() { _loading = true; });
    try {
      final cartResp = await http.get(Uri.parse('${getBackendUrl()}/cart?user_email=$currentUserEmail'));
      final wishlistResp = await http.get(Uri.parse('${getBackendUrl()}/wishlist?user_email=$currentUserEmail'));
      if (cartResp.statusCode == 200 && wishlistResp.statusCode == 200) {
        final cartData = jsonDecode(cartResp.body);
        final wishlistData = jsonDecode(wishlistResp.body);
        final cartItems = (cartData['items'] as List);
        final wishlistItems = (wishlistData['products'] as List);
        final inCart = cartItems.any((item) => item['product_id'].toString() == widget.product.id.toString());
        final inWishlist = wishlistItems.map((e) => e.toString()).contains(widget.product.id.toString());
        setState(() { _inCart = inCart; _inWishlist = inWishlist; _loading = false; });
      } else {
        setState(() { _loading = false; });
      }
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  Future<void> _toggleCart() async {
    if (currentUserEmail == null || currentUserEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }
    if (_inCart) {
      final resp = await http.delete(
        Uri.parse('${getBackendUrl()}/cart/remove'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_email': currentUserEmail, 'product_id': widget.product.id}),
      );
      if (resp.statusCode == 200) {
        setState(() { _inCart = false; });
      }
    } else {
      final resp = await http.post(
        Uri.parse('${getBackendUrl()}/cart/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_email': currentUserEmail, 'product_id': widget.product.id, 'quantity': _quantity}),
      );
      if (resp.statusCode == 200) {
        setState(() { _inCart = true; });
      }
    }
  }

  Future<void> _toggleWishlist() async {
    if (currentUserEmail == null || currentUserEmail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }
    if (_inWishlist) {
      final resp = await http.delete(
        Uri.parse('${getBackendUrl()}/wishlist/remove'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_email': currentUserEmail, 'product_id': widget.product.id}),
      );
      if (resp.statusCode == 200) {
        setState(() { _inWishlist = false; });
      }
    } else {
      final resp = await http.post(
        Uri.parse('${getBackendUrl()}/wishlist/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_email': currentUserEmail, 'product_id': widget.product.id}),
      );
      if (resp.statusCode == 200) {
        setState(() { _inWishlist = true; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 300,
              title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              actions: [
                IconButton(
                  tooltip: _inWishlist ? 'Remove from Wishlist' : 'Add to Wishlist',
                  onPressed: _toggleWishlist,
                  icon: Icon(_inWishlist ? Icons.favorite : Icons.favorite_border, color: _inWishlist ? Colors.pink : Colors.white),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image, size: 64, color: Colors.grey)),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black26],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                        child: Text('₹${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Description'),
                  Tab(text: 'Details'),
                  Tab(text: 'Reviews'),
                ],
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              child: TabBarView(
                children: [
                  // Description Tab
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(product.category, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
                          ),
                          const SizedBox(width: 12),
                          Text('In stock: ${product.inStock}', style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(product.description, style: TextStyle(color: Colors.grey[800], fontSize: 16)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Text('Quantity:', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                ),
                                Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => setState(() => _quantity++),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.local_shipping_outlined, color: Colors.blue),
                        title: const Text('Free delivery on orders over ₹499'),
                        subtitle: const Text('Standard delivery in 3-5 business days'),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.assignment_turned_in_outlined, color: Colors.green),
                        title: const Text('7-day replacement policy'),
                        subtitle: const Text('Easy returns if the item is damaged or defective'),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                  // Details Tab
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Text('Product Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      SizedBox(height: 12),
                      ListTile(
                        dense: true,
                        title: Text('Material'),
                        subtitle: Text('Premium quality materials'),
                      ),
                      ListTile(
                        dense: true,
                        title: Text('Warranty'),
                        subtitle: Text('1 year limited warranty'),
                      ),
                      ListTile(
                        dense: true,
                        title: Text('Care'),
                        subtitle: Text('Refer to instructions included in the package'),
                      ),
                    ],
                  ),
                  // Reviews Tab (placeholder)
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Text('Customer Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      SizedBox(height: 12),
                      ListTile(
                        leading: Icon(Icons.person_outline),
                        title: Text('Great value for money!'),
                        subtitle: Text('Loved the quality and delivery was quick.'),
                      ),
                      ListTile(
                        leading: Icon(Icons.person_outline),
                        title: Text('As described'),
                        subtitle: Text('Product matches the description and images.'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))]),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleWishlist,
                  icon: Icon(_inWishlist ? Icons.favorite : Icons.favorite_border, color: _inWishlist ? Colors.pink : Colors.grey),
                  label: Text(_inWishlist ? 'Wishlisted' : 'Wishlist'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleCart,
                  icon: Icon(_inCart ? Icons.shopping_cart : Icons.add_shopping_cart),
                  label: Text(_inCart ? 'In Cart' : 'Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _inCart ? Colors.green : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Cart and Wishlist Screens ---
class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  Future<void> _fetchCart() async {
    if (currentUserEmail == null || currentUserEmail!.isEmpty) {
      setState(() { _error = 'Please log in first'; _loading = false; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final response = await http.get(Uri.parse('${getBackendUrl()}/cart/detailed?user_email=$currentUserEmail'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() { _items = data['items']; _loading = false; });
      } else {
        setState(() { _error = 'Failed to load cart'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _items.isEmpty
                  ? const Center(child: Text('Cart is empty'))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final item = _items[i];
                        final product = item['product'];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product['image_url'] ?? '',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width:56,height:56,color:Colors.grey.shade200,child: const Icon(Icons.image_not_supported)),
                            ),
                          ),
                          title: Text(product['name'] ?? ''),
                          subtitle: Text('Qty: ${item['quantity']}  •  ₹${(product['price'] ?? 0).toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await http.delete(
                                Uri.parse('${getBackendUrl()}/cart/remove'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({'user_email': currentUserEmail, 'product_id': product['_id']}),
                              );
                              _fetchCart();
                            },
                          ),
                        );
                      },
                    ),
      bottomNavigationBar: _items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder<http.Response>(
                    future: http.get(Uri.parse('${getBackendUrl()}/cart/total?user_email=$currentUserEmail')),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text('Total: ...');
                      try {
                        final json = jsonDecode(snapshot.data!.body);
                        return Text('Total: ₹${(json['total'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold));
                      } catch (_) {
                        return const Text('Total: --');
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Checkout'),
                  )
                ],
              ),
            ),
    );
  }
}

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<dynamic> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://localhost:8000';
    }
  }

  Future<void> _fetchWishlist() async {
    if (currentUserEmail == null || currentUserEmail!.isEmpty) {
      setState(() { _error = 'Please log in first'; _loading = false; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final response = await http.get(Uri.parse('${getBackendUrl()}/wishlist/detailed?user_email=$currentUserEmail'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() { _products = data['products']; _loading = false; });
      } else {
        setState(() { _error = 'Failed to load wishlist'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Wishlist')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _products.isEmpty
                  ? const Center(child: Text('Wishlist is empty'))
                  : ListView.separated(
                      itemCount: _products.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final product = _products[i];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product['image_url'] ?? '',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width:56,height:56,color:Colors.grey.shade200,child: const Icon(Icons.image_not_supported)),
                            ),
                          ),
                          title: Text(product['name'] ?? ''),
                          subtitle: Text('₹${(product['price'] ?? 0).toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await http.delete(
                                Uri.parse('${getBackendUrl()}/wishlist/remove'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({'user_email': currentUserEmail, 'product_id': product['_id']}),
                              );
                              _fetchWishlist();
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(
                                  product: Product(
                                    id: product['_id'] ?? '',
                                    name: product['name'] ?? '',
                                    description: product['description'] ?? '',
                                    price: (product['price'] ?? 0).toDouble(),
                                    category: product['category'] ?? '',
                                    inStock: product['in_stock'] ?? 0,
                                    imageUrl: product['image_url'] ?? '',
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
