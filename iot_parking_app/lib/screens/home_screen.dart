import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:parking_app/components/custom_slot_card.dart';
import 'package:parking_app/screens/login_screen.dart';

// XOR Key
const int xorKey = 123;

int decryption(int value) => value ^ xorKey;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String id = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dbRef = FirebaseDatabase.instance.ref().child('parking_slots');
  final String? userName = FirebaseAuth.instance.currentUser?.displayName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18181B),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset('assets/images/logo.png', width: 50),
            const Text(
              'IOT Parking App',
              style: TextStyle(
                color: Color(0xFF25BAC1),
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed(LoginScreen.id);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Text(
                'Hi, ${userName ?? 'Sir'} ✨',

                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading data",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          Map<String, bool> slotsStatus = {};
          int availableCount = 0;
          int occupiedCount = 0;

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

            data.forEach((key, value) {
              String id = value['id'].toString();

              // قراءة الرقم المشفر وفك التشفير
              int encryptedVal;
              if (value['isAvailable'] is int) {
                encryptedVal = value['isAvailable'];
              } else if (value['isAvailable'] is String) {
                encryptedVal = int.parse(value['isAvailable']);
              } else {
                encryptedVal = 0;
              }

              bool isAvailable = (decryption(encryptedVal) == 1);
              slotsStatus[id] = isAvailable;

              if (isAvailable) {
                availableCount++;
              } else {
                occupiedCount++;
              }
            });
          }

          bool getStatus(String id) => slotsStatus[id] ?? false;

          return Column(
            children: [
              const SizedBox(height: 50),
              Container(
                color: const Color(0xFF18181B),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.square_rounded, color: Colors.green),
                        const SizedBox(width: 5),
                        Text(
                          "Available: $availableCount",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.square_rounded, color: Colors.red),
                        const SizedBox(width: 5),
                        Text(
                          "Occupied: $occupiedCount",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // upper part
                          Row(
                            children: [
                              const Spacer(flex: 3),
                              CustomSlotCard(
                                slotId: "P-05",
                                isVertical: false,
                                isAvailable: getStatus("P-05"),
                              ),
                              const Spacer(flex: 1),
                              CustomSlotCard(
                                slotId: "P-04",
                                isVertical: false,
                                isAvailable: getStatus("P-04"),
                              ),
                              const Spacer(flex: 3),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // lower part
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  CustomSlotCard(
                                    slotId: "P-06",
                                    isVertical: true,
                                    isAvailable: getStatus("P-06"),
                                  ),
                                  const SizedBox(height: 20),
                                  CustomSlotCard(
                                    slotId: "P-07",
                                    isVertical: true,
                                    isAvailable: getStatus("P-07"),
                                  ),
                                  const SizedBox(height: 20),
                                  CustomSlotCard(
                                    slotId: "P-08",
                                    isVertical: true,
                                    isAvailable: getStatus("P-08"),
                                  ),
                                ],
                              ),
                              Image.asset(
                                'assets/images/image.png',
                                fit: BoxFit.contain,
                                height: 398,
                              ),
                              Column(
                                children: [
                                  CustomSlotCard(
                                    slotId: "P-03",
                                    isVertical: true,
                                    isAvailable: getStatus("P-03"),
                                  ),
                                  const SizedBox(height: 20),
                                  CustomSlotCard(
                                    slotId: "P-02",
                                    isVertical: true,
                                    isAvailable: getStatus("P-02"),
                                  ),
                                  const SizedBox(height: 20),
                                  CustomSlotCard(
                                    slotId: "P-01",
                                    isVertical: true,
                                    isAvailable: getStatus("P-01"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
