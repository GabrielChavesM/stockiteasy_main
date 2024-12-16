import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReturnPage extends StatefulWidget {
  @override
  _ReturnPageState createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _storeNumberController = TextEditingController();
  String _storeNumber = '';
  int _breakageQty = 1; // Quantidade inicial de quebras

  @override
  void initState() {
    super.initState();
    _fetchUserStoreNumber();
  }

  Future<void> _fetchUserStoreNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _storeNumber = userDoc['storeNumber'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      title: Text('Stock Brakes'),
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
                      TextField(
                        controller: _storeNumberController..text = _storeNumber,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Store Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final allProducts = snapshot.data!.docs;

                  // Filtros
                  final filteredProducts = allProducts.where((product) {
                    final data = product.data() as Map<String, dynamic>;
                    final productName = (data['name'] ?? "").toString().toLowerCase();
                    final productBrand = (data['brand'] ?? "").toString().toLowerCase();
                    final productCategory = (data['category'] ?? "").toString().toLowerCase();
                    final productStoreNumber = (data['storeNumber'] ?? "").toString().toLowerCase();

                    return productName.contains(_nameController.text.toLowerCase()) &&
                        productBrand.contains(_brandController.text.toLowerCase()) &&
                        productCategory.contains(_categoryController.text.toLowerCase()) &&
                        (_storeNumber.isEmpty || productStoreNumber == _storeNumber.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 0), // Adicione um padding para evitar colar no topo
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final data = product.data() as Map<String, dynamic>;

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(data['name'] ?? "Without name"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Brand: ${data['brand'] ?? "Without brand"}"),

                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Current Stock: ",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: (data['stockCurrent'] ?? 0).toString(), // Conversão para String
                                    ),
                                  ],
                                ),
                              ),

                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                    text: "Warehouse Stock: ",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: (data['wareHouseStock'] ?? 0).toString(),
                                  ),
                                ],
                              ),
                            ),


                            ],
                          ),
                          onTap: () => _showBreakageDialog(context, product),
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

void _showBreakageDialog(BuildContext context, DocumentSnapshot product) {
  final data = product.data() as Map<String, dynamic>;

  String _breakageType = 'stockCurrent'; // Tipo inicial padrão: Estoque de Loja

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16),
              height: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Product Breakage: ${data['name'] ?? "Without name"}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text("Store Stock: ${data['stockCurrent'] ?? 0}"),
                  Text("Warehouse Stock: ${data['wareHouseStock'] ?? 0}"),
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: 'stockCurrent',
                        groupValue: _breakageType,
                        onChanged: (value) {
                          setState(() {
                            _breakageType = value!;
                          });
                        },
                      ),
                      Text('Store'),
                      Radio<String>(
                        value: 'wareHouseStock',
                        groupValue: _breakageType,
                        onChanged: (value) {
                          setState(() {
                            _breakageType = value!;
                          });
                        },
                      ),
                      Text('Warehouse'),
                    ],
                  ),
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (_breakageQty > 1) _breakageQty--;
                          });
                        },
                      ),
                      Text("$_breakageQty", style: TextStyle(fontSize: 24)),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            if (_breakageQty < 10) _breakageQty++;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_breakageQty <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Invalid breakage quantity")),
                            );
                            return;
                          }

                          _showConfirmationDialog(context, product, _breakageType);
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

void _showConfirmationDialog(BuildContext context, DocumentSnapshot product, String breakageType) {
  final data = product.data() as Map<String, dynamic>;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Breakage"),
        content: Text(
          "Are you sure you want to mark ${data['name']} as breakage from "
          "${breakageType == 'stockCurrent' ? 'Store Stock' : 'Warehouse Stock'}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // Estoque atual e nova quantidade
              int currentStock = data[breakageType] ?? 0;
              int newStock = currentStock - _breakageQty;

              if (newStock < 0) newStock = 0;

              String breakageField =
                  breakageType == 'stockCurrent' ? 'storeBreak' : 'warehouseStockBreak';
              int stockBreak = data[breakageField] ?? 0;
              stockBreak += _breakageQty;

              try {
                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(product.id)
                    .update({
                  breakageType: newStock,
                  breakageField: stockBreak,
                });

                await FirebaseFirestore.instance.collection('breakages').add({
                  'productId': product.id,
                  'productName': data['name'],
                  'breakageQty': _breakageQty,
                  'breakageType': breakageType,
                  'timestamp': Timestamp.now(),
                });

                Navigator.of(context).pop(); // Fecha a confirmação
                Navigator.of(context).pop(); // Fecha o diálogo principal

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Breakage recorded successfully")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error saving breakage: $e")),
                );
              }
            },
            child: Text("Confirm"),
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
