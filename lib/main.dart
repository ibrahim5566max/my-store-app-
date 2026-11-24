import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TayebBanagaStoreApp());
}

class TayebBanagaStoreApp extends StatelessWidget {
  const TayebBanagaStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF57C00);
    const darkBg = Color(0xFF121212);
    const cardBg = Color(0xFF1E1E1E);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مغلق الطيب بانقا',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBg,
        primaryColor: primaryOrange,
        colorScheme: const ColorScheme.dark(
          primary: primaryOrange,
          secondary: primaryOrange,
          surface: cardBg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cardBg,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const StoreHomeScreen(),
    );
  }
}

class ProductItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;

  const ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
  });
}

class StoreHomeScreen extends StatefulWidget {
  const StoreHomeScreen({super.key});

  @override
  State<StoreHomeScreen> createState() => _StoreHomeScreenState();
}

class _StoreHomeScreenState extends State<StoreHomeScreen> {
  final List<String> categories = [
    'الكل',
    'مستلزمات كهربائية',
    'مواد بناء',
    'أدوات منزلية',
  ];

  String selectedCategory = 'الكل';
  final Map<String, int> cart = {};
  String orderStatus = 'لا توجد طلبات نشطة';
  String paymentMethod = 'إشعار تحويل بنكي (رفع إيصال)';

  final List<ProductItem> products = const [
    ProductItem(
      id: 'p1',
      name: 'قابس كهربائي ذكي وحماية',
      category: 'مستلزمات كهربائية',
      price: 45.0,
      description: 'مفتاح وقابس بتحكم عملي وحماية من ارتفاع الجهد.',
    ),
    ProductItem(
      id: 'p2',
      name: 'كابل نحاسي معزول 2.5 ملم',
      category: 'مستلزمات كهربائية',
      price: 120.0,
      description: 'مناسب للتمديدات الداخلية عالية التحمل.',
    ),
    ProductItem(
      id: 'p3',
      name: 'أسمنت ومواد تشطيب للمغلق',
      category: 'مواد بناء',
      price: 95.0,
      description: 'خامات ومواد متوفرة للطلب المباشر والتوصيل.',
    ),
    ProductItem(
      id: 'p4',
      name: 'طقم مفكات صيانة متكامل',
      category: 'أدوات منزلية',
      price: 60.0,
      description: 'مجموعة متنوعة للتركيب والصيانة المنزلية اليومية.',
    ),
  ];

  List<ProductItem> get filteredProducts {
    if (selectedCategory == 'الكل') return products;
    return products.where((p) => p.category == selectedCategory).toList();
  }

  int get totalCartItems => cart.values.fold(0, (sum, qty) => sum + qty);

  double get totalCartAmount {
    double total = 0;
    for (final entry in cart.entries) {
      final item = products.firstWhere((p) => p.id == entry.key);
      total += item.price * entry.value;
    }
    return total;
  }

  void addToCart(String productId) {
    setState(() {
      cart[productId] = (cart[productId] ?? 0) + 1;
    });
  }

  void openCheckoutSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'إتمام الطلب والدفع - مغلق الطيب بانقا',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('الإجمالي: ${totalCartAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    dropdownColor: const Color(0xFF2A2A2A),
                    decoration: const InputDecoration(
                      labelText: 'طريقة الدفع',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'إشعار تحويل بنكي (رفع إيصال)',
                        child: Text('إشعار تحويل بنكي (رفع إيصال)'),
                      ),
                      DropdownMenuItem(
                        value: 'الدفع عند الاستلام (COD)',
                        child: Text('الدفع عند الاستلام (COD)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => paymentMethod = val);
                        setState(() => paymentMethod = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57C00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: cart.isEmpty
                        ? null
                        : () {
                            setState(() {
                              orderStatus = 'قيد المراجعة ($paymentMethod)';
                              cart.clear();
                            });
                            Navigator.pop(ctx);
                          },
                    child: const Text('تأكيد الطلب'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مغلق الطيب بانقا'),
          actions: [
            IconButton(
              icon: Badge(
                label: Text('$totalCartItems'),
                isLabelVisible: totalCartItems > 0,
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: openCheckoutSheet,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF57C00)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('حالة الطلب: $orderStatus')),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        orderStatus = 'جاري التجهيز والتوصيل';
                      });
                    },
                    child: const Text(
                      'تحديث الحالة',
                      style: TextStyle(color: Color(0xFFF57C00)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final active = cat == selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: active,
                    selectedColor: const Color(0xFFF57C00),
                    onSelected: (_) => setState(() => selectedCategory = cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final item = filteredProducts[index];
                  return Card(
                    color: const Color(0xFF1E1E1E),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${item.category} • ${item.price}'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF57C00),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => addToCart(item.id),
                        child: const Text('أضف'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
