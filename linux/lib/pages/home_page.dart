import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uas_pemweb/auth.dart';
import 'package:uas_pemweb/pages/place_page.dart';
import 'navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceData {
  final String name;
  final String location;
  // ignore: non_constant_identifier_names
  final String image_url;

  PlaceData(
      {required this.name,
      required this.location,
      // ignore: non_constant_identifier_names
      required this.image_url});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<PlaceData> placeData = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('places').get();

      final List<PlaceData> fetchedData = snapshot.docs.map((doc) {
        final data = doc.data();
        return PlaceData(
          name: data['name'] ?? '',
          location: data['location'] ?? '',
          image_url: data['image_url'] ?? '',
        );
      }).toList();

      setState(() {
        placeData = fetchedData;
      });
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text(
      'DISCOVER \nPALANGKA \nRAYA',
      style: TextStyle(
          color: Colors.white,
          fontSize: 60,
          fontWeight: FontWeight.w900,
          height: 0.9),
    );
  }

  void navigateToPlacePage(String placeName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlacePage(placeName: placeName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 42, 78, 20),
          elevation: 0,
        ),
        endDrawer: NavBar(),
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/home_blur.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 64),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _title(),
                ),
                const SizedBox(height: 32),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: placeData.map(
                      (PlaceData place) {
                        return GestureDetector(
                          onTap: () {
                            navigateToPlacePage(place.name);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                bottom: 16, right: 8, left: 8),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(place.image_url, scale: 1),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color.fromARGB(255, 0, 0, 0)
                                            .withOpacity(0.7),
                                        const Color.fromARGB(0, 69, 145, 120),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      right: 12, left: 12, top: 12, bottom: 12),
                                  child: Flex(
                                    direction: Axis.horizontal,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Flex(
                                          direction: Axis.vertical,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              place.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Flex(
                                              direction: Axis.horizontal,
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  place.location,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_circle_right_outlined,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
