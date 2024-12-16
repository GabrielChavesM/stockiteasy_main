import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

// Função para verificar se a notificação tem mais de 3 dias
bool _isNotificationExpired(Timestamp timestamp) {
  final notificationTime = timestamp.toDate();
  final currentTime = DateTime.now();
  final difference = currentTime.difference(notificationTime);
  return difference.inDays >= 3; // Se a notificação tem mais de/ou 3 dias
}

// Função para buscar as notificações
Future<List<Map<String, dynamic>>> _fetchNotifications(String storeNumber) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('storeNumber', isEqualTo: storeNumber)
        .orderBy('timestamp', descending: true)
        .get();

    final notifications = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // Excluir notificações expiradas em lote
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in querySnapshot.docs) {
      if (_isNotificationExpired(doc['timestamp'])) {
        batch.delete(doc.reference);
      }
    }

    // Commit das exclusões em lote
    await batch.commit();

    return notifications.where((n) => !_isNotificationExpired(n['timestamp'])).toList();
  } catch (e) {
    debugPrint("Error fetching notifications: $e");
    throw e;
  }
}


  // Função para pegar o número da loja do usuário
  Future<String?> _getUserStoreNumber() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final storeNumber = userDoc.data()?['storeNumber'] as String?;
      //debugPrint("User StoreNumber: $storeNumber");
      return storeNumber;
    } catch (e) {
      debugPrint("Error fetching user storeNumber: $e");
      throw e;
    }
  }

  // Função para exibir o tempo decorrido
  String _getTimeAgo(DateTime notificationTime) {
    final currentTime = DateTime.now();
    final difference = currentTime.difference(notificationTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days ago'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours ago'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes ago'}';
    } else {
      return 'Less than a minute ago';
    }
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
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<String?>(
          future: _getUserStoreNumber(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text(
                  'Failed to fetch user storeNumber.',
                  style: TextStyle(fontSize: 18, color: Colors.white), // Cor branca para o texto de erro
                ),
              );
            }

            final storeNumber = snapshot.data!;
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchNotifications(storeNumber),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error fetching notifications.',
                      style: TextStyle(fontSize: 18, color: Colors.white), // Cor branca para o texto de erro
                    ),
                  );
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return const Center(
                    child: Text(
                      'No notifications available.',
                      style: TextStyle(fontSize: 18, color: Colors.white), // Cor branca para o texto de "No notifications"
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final notificationType = notification['notificationType'] ?? 'Default';

                    // Determinar ícone e cor
                    IconData iconData;
                    Color iconColor;
                        switch (notificationType) {
                          case 'Order':
                            iconData = Icons.add_box;
                            iconColor = const Color.fromARGB(255, 25, 105, 170);
                            break;
                          case 'Update':
                            iconData = Icons.inventory_2;
                            iconColor = const Color.fromARGB(255, 23, 143, 27);
                            break;
                          case 'Transfer':
                            iconData = Icons.swap_horiz;
                            iconColor = const Color.fromARGB(255, 131, 6, 153);
                            break;
                          case 'UpdatePrice':
                            iconData = Icons.attach_money;
                            iconColor = const Color.fromARGB(255, 255, 115, 0);
                            break;
                          case 'Create':
                            iconData = Icons.fiber_new;
                            iconColor = Colors.black;
                            break;
                          case 'Edit':
                            iconData = Icons.edit;
                            iconColor = const Color.fromARGB(255, 221, 199, 0);
                            break;
                          case 'Meeting': 
                            iconData = Icons.timelapse_sharp;
                            iconColor = const Color.fromARGB(255, 3, 12, 138); 
                            break;
                          case 'Warning': 
                            iconData = Icons.warning;
                            iconColor = const Color.fromARGB(255, 141, 128, 9);
                            break;
                          case 'Schedule': 
                            iconData = Icons.schedule;
                            iconColor = const Color.fromARGB(255, 0, 0, 0);
                            break;
                          default:
                            iconData = Icons.notification_important;
                            iconColor = Colors.red;
                            break;
                        }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.5),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification['message'] ?? 'No message',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // Cor branca para o texto da mensagem
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    notification['timestamp'] != null
                                        ? _getTimeAgo((notification['timestamp'] as Timestamp).toDate())
                                        : 'No timestamp',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white70, // Cor branca clara para o timestamp
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Icon(iconData, color: iconColor, size: 20.0),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        notificationType,
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white, // Cor branca para o tipo de notificação
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

Color hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}