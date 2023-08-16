import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceData {
  final String name;
  final String location;
  final String image_url;
  final String description;

  PlaceData({
    required this.name,
    required this.location,
    required this.image_url,
    required this.description,
  });
}

class PlacePage extends StatefulWidget {
  final String placeName;
  const PlacePage({Key? key, required this.placeName}) : super(key: key);

  @override
  State<PlacePage> createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
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
          await FirebaseFirestore.instance
              .collection('places')
              .where('name', isEqualTo: widget.placeName)
              .get();

      final List<PlaceData> fetchedData = snapshot.docs.map((doc) {
        final data = doc.data();
        return PlaceData(
          name: data['name'] ?? '',
          location: data['location'] ?? '',
          image_url: data['image_url'] ?? '',
          description: data['description'] ?? '',
        );
      }).toList();

      setState(() {
        placeData = fetchedData;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching data from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 42, 78, 20),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              )),
        ),
        body: ListView.builder(
          itemCount: placeData.length,
          itemBuilder: (context, index) {
            final place = placeData[index];

            return Stack(
              children: [
                Container(
                  height: 600,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        place.image_url,
                      ),
                      alignment: Alignment.topCenter,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: Image.asset(
                          'assets/wonderful_indonesia.png',
                          width: 100,
                        ),
                      ),
                      const SizedBox(
                        height: 256,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          place.name.replaceAll(' ', '\n').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            height: 0.9,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 20),
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 46, 46, 46),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      '${place.location}, Kota Palangka Raya',
                                      style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                const Text(
                                  'Deskripsi',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 115, 211, 56),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  place.description,
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
