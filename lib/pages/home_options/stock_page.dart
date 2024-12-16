import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importando o Firebase Auth

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _storeNumberController = TextEditingController();
  String? _selectedPriceRange; // Controla o intervalo de preço selecionado

  List<DocumentSnapshot> _filteredProducts = [];
  List<DocumentSnapshot> _allProducts = [];

  // Variável para controlar o estado de carregamento
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllProducts();  // Carrega todos os produtos
    _fetchUserStoreNumber(); // Pega o número da loja do utilizador
  }

  // Função para pegar os dados do utilizador logado e preenche o campo de storeNumber
  Future<void> _fetchUserStoreNumber() async {
    User? user = FirebaseAuth.instance.currentUser; // Obtém o utilizador logado
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final storeNumber = userDoc['storeNumber'];
        setState(() {
          _storeNumberController.text = storeNumber ?? ''; // Preenche o campo com o storeNumber
        });
        _filterProducts(); // Aplica o filtro logo após carregar o número da loja
      }
    }
  }

  Future<void> _fetchAllProducts() async {
    // Simula uma espera de 1 segundo para mostrar a tela de carregamento
    await Future.delayed(Duration(seconds: 1)); // Simulando o carregamento

    final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
    setState(() {
      _allProducts = querySnapshot.docs;
      _filteredProducts = _allProducts; // Aplica o filtro inicial
      _isLoading = false; // Finaliza o carregamento
    });
    _filterProducts(); // Aplica o filtro com os dados carregados
  }

  void _filterProducts() {
    final name = _nameController.text.toLowerCase();
    final brand = _brandController.text.toLowerCase();
    final category = _categoryController.text.toLowerCase();
    final storeNumber = _storeNumberController.text.toLowerCase();

    double minPrice = 0;
    double maxPrice = double.infinity;

    if (_selectedPriceRange != null) {
      if (_selectedPriceRange == '5000+') {
        minPrice = 5000;
        maxPrice = double.infinity;
      } else {
        final range = _selectedPriceRange!.split('-');
        minPrice = double.tryParse(range[0]) ?? 0;
        maxPrice = double.tryParse(range[1]) ?? double.infinity;
      }
    }

    final filteredList = _allProducts.where((product) {
      final data = product.data() as Map<String, dynamic>;

      final productName = (data['name'] ?? "").toString().toLowerCase();
      final productBrand = (data['brand'] ?? "").toString().toLowerCase();
      final productCategory = (data['category'] ?? "").toString().toLowerCase();
      final productStoreNumber = (data['storeNumber'] ?? "").toString().toLowerCase();
      final productPrice = (data['salePrice'] ?? 0.0) is int
          ? (data['salePrice'] as int).toDouble()
          : (data['salePrice'] ?? 0.0) as double;

      // Verifica se o storeNumber é válido e corresponde ao filtro
      if (storeNumber.isNotEmpty && productStoreNumber != storeNumber) {
        return false; // Se não houver correspondência, exclui o produto
      }

      // Se o utilizador acabou de fazer login e não colocou um código de loja, não aparecem produtos
      if(storeNumber.isEmpty) return false;

      // Aplica os outros filtros
      return productName.contains(name) &&
            productBrand.contains(brand) &&
            productCategory.contains(category) &&
            productPrice >= minPrice &&
            productPrice <= maxPrice;
    }).toList();


    setState(() {
      _filteredProducts = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
return Scaffold(
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    title: Text('Filter Products'),
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
      children: [
        SizedBox(height: kToolbarHeight * 2), // Compensa a altura da AppBar
        Padding(
          padding: const EdgeInsets.all(16.0), // Espaçamento igual ao LocationsPage
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
                  SizedBox(height: 0), // Espaço controlado entre campos
                  _buildTextField(_brandController, 'Brand'),
                  SizedBox(height: 0),
                  _buildTextField(_categoryController, 'Category'),
                  SizedBox(height: 0),
                  _buildTextField(
                    _storeNumberController,
                    'Filter by store number',
                    enabled: false,
                  ),
                  SizedBox(height: 0),
                  _buildDropdown(),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    final data = product.data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(data['name'] ?? "Without name", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: "Brand: ",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: data['brand'] ?? "Without brand",
      ),
    ],
  ),
),
Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: "Model: ",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: data['model'] ?? "Without model",
      ),
    ],
  ),
),
Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: "Sale Price: ",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: "€ ${data['salePrice']?.toStringAsFixed(2) ?? "0.00"}",
      ),
    ],
  ),
),
Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: "Current Stock: ",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: "${data['stockCurrent'] ?? 0}",
      ),
    ],
  ),
),

                          ],
                        ),
                        onTap: () => _showProductDetailsDialog(context, data),
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

  // Função para criar os campos de texto
  Widget _buildTextField(TextEditingController controller, String label, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        onChanged: (_) => _filterProducts(),
        enabled: enabled, // Aqui controlamos se o campo é editável ou não
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 12.0), // Reduz a altura interna
        ),
      ),
    );
  }

  // Função para criar o dropdown de intervalo de preço
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
          _filterProducts();
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

void _showProductDetailsDialog(BuildContext context, Map<String, dynamic> data) {
  final details = {
    "Brand": data['brand'] ?? "Without brand",
    "Model": data['model'] ?? "Without model",
    "Category": data['category'] ?? "Without category",
    "Subcategory": data['subCategory'] ?? "Without subcategory",
    "Description": data['description'] ?? "Without description",
    "Sale Price": "€ ${data['salePrice']?.toStringAsFixed(2) ?? "0.00"}",
    "Current Stock": "${data['stockCurrent'] ?? 0}",
    "Stock Order": "${data['stockOrder'] ?? 0}",
  };

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(data['name'] ?? "No name"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: details.entries.map((entry) {
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
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100], // Cor do fundo (ajuste conforme necessário)
                borderRadius: BorderRadius.circular(12), // Bordas arredondadas
                boxShadow: [
                  // Sombra clara (parte superior)
                  BoxShadow(
                    color: Colors.white, // Sombra clara
                    offset: Offset(-4, -4), // Direção da sombra
                    blurRadius: 6, // Difusão da sombra
                  ),
                  // Sombra escura (parte inferior)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Sombra escura
                    offset: Offset(4, 4), // Direção da sombra
                    blurRadius: 6, // Difusão da sombra
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Espaçamento interno
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87, // Cor do texto
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
  // Função auxiliar para converter strings hexadecimais em cores
  Color hexStringToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF' + hex; // Adiciona transparência 100%
    }
    return Color(int.parse('0x$hex'));
  }
}