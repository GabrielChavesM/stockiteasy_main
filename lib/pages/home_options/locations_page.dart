import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationsPage extends StatefulWidget {
  @override
  _LocationsPageState createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _storeNumberController = TextEditingController();
  String? _selectedPriceRange;

  List<DocumentSnapshot> _allProducts = []; // Mantém todos os produtos
  String _storeNumber = '';

  @override
  void initState() {
    super.initState();
    _fetchUserStoreNumber();
  }

  // Função para buscar o número da loja do utilizador logado
  Future<void> _fetchUserStoreNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _storeNumber = userDoc['storeNumber'] ?? '';
          _storeNumberController.text = _storeNumber;
        });
      }
    }
  }

  // Função de filtro
  List<DocumentSnapshot> _applyFilters(List<DocumentSnapshot> products) {
    final name = _nameController.text.toLowerCase();
    final brand = _brandController.text.toLowerCase();
    final category = _categoryController.text.toLowerCase();
    final storeNumber = _storeNumber.toLowerCase();

    return products.where((product) {
      final data = product.data() as Map<String, dynamic>;

      final productName = (data['name'] ?? "", style: TextStyle(fontWeight: FontWeight.bold)).toString().toLowerCase();
      final productBrand = (data['brand'] ?? "").toString().toLowerCase();
      final productCategory = (data['category'] ?? "").toString().toLowerCase();
      final productStoreNumber = (data['storeNumber'] ?? "").toString().toLowerCase();

      if (storeNumber.isNotEmpty && productStoreNumber != storeNumber) return false;
      if (storeNumber.isEmpty) return false;

      return productName.contains(name) &&
          productBrand.contains(brand) &&
          productCategory.contains(category);
    }).toList();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      title: Text('Locate Stock'),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            hexStringToColor("CB2B93"),
            hexStringToColor("9546C4"),
            hexStringToColor("5E61F4"),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Ajusta o alinhamento
        children: [
          SizedBox(height: kToolbarHeight * 2), // Espaço para a AppBar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(_nameController, 'Name'),
                    _buildTextField(_brandController, 'Brand'),
                    _buildTextField(_categoryController, 'Category'),
                    _buildTextField(_storeNumberController, 'Filter by store number', enabled: false),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar os produtos.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Nenhum produto encontrado.'));
                }

                _allProducts = snapshot.data!.docs;
                final filteredProducts = _applyFilters(_allProducts);

                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 0), // Adicione um padding para evitar colar no topo
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final data = product.data() as Map<String, dynamic>;
                    final documentId = product.id;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(data['name'] ?? "Sem nome", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Brand: ${data['brand'] ?? "Sem marca"}"),
                            Text("Model: ${data['model'] ?? "Sem modelo"}"),
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                    text: "Current Stock: ",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: data['stockCurrent']?.toString() ?? "No stock.",
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                    text: "Shop Location: ",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: data['productLocation'] ?? "Not located.",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showProductDetailsDialog(context, data, documentId),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  // Função para criar os campos de texto
  Widget _buildTextField(TextEditingController controller, String label, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        enabled: enabled, // Aqui controlamos se o campo é editável ou não
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 12.0), // Reduz a altura interna
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DropdownButton<String>(
        isExpanded: true,
        value: _selectedPriceRange,
        onChanged: (value) {
          setState(() {
            _selectedPriceRange = value;
          });
        },
        hint: Text("Select Price Range"),
        items: [
          '0-100', '100-200', '200-300', '300-400',
          '400-500', '500-600', '600-700', '700-800',
          '800-900', '900-1000', '1000-2000', '2000-3000',
          '3000-4000', '4000-5000', '5000+'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

void _showProductDetailsDialog(BuildContext context, Map<String, dynamic> data, String documentId) {
  final TextEditingController _locationController =
      TextEditingController(text: data['productLocation'] ?? '');

  final details = {
    "Brand": data['brand'] ?? "No brand",
    "Model": data['model'] ?? "No model",
    "Category": data['category'] ?? "No category",
    "Current Stock": data['stockCurrent']?.toString() ?? "No stock"
  };

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(data['name'] ?? "Sem nome", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...details.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: "${entry.key}: ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: entry.value),
                      ],
                    ),
                  ),
                  SizedBox(height: 8), // Adiciona espaçamento entre os itens
                  Divider(), // Linha separadora
                ],
              );
            }).toList(),

            // Exibição da localização de forma clicável
            GestureDetector(
              onTap: () {
                _showEditLocationDialog(context, _locationController, documentId);
              },
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: "Location: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: data['productLocation'] ?? "Não localizado",
                      style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
        actions: [
  GestureDetector(
    onTap: () async { 
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(documentId)
            .update({'productLocation': _locationController.text});
            Navigator.of(context).pop();
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error while saving location: $e')),
        );
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(4, 4),
            blurRadius: 6,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Text(
        'Close',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
],

      );
    },
  );
}

void _showEditLocationDialog(BuildContext context, TextEditingController _locationController, String documentId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Editar Localização"),
        content: TextField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: "Localização do Produto",
            contentPadding: EdgeInsets.symmetric(vertical: 0.5, horizontal: 12.0),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4, -4),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(4, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              // Verifica se o campo está vazio e atribui "Not located." caso necessário
              String locationText = _locationController.text.isEmpty ? "Not located." : _locationController.text;

              try {
                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(documentId)
                    .update({'productLocation': locationText});
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } catch (e) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error while saving location: $e')),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4, -4),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(4, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}


  Color hexStringToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF' + hex;
    }
    return Color(int.parse('0x$hex'));
  }
}