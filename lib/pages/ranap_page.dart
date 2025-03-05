import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hasta_app/services/api_client.dart';

class RanapListPage extends StatefulWidget {
  const RanapListPage({super.key});

  @override
  _RanapListPageState createState() => _RanapListPageState();
}

class _RanapListPageState extends State<RanapListPage> {
  List<dynamic> ranapList = [];
  List<dynamic> filteredList = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRanapData();
  }

  Future<void> fetchRanapData() async {
    try {
      Response response =
          await ApiClient().get('/ranap'); // Replace with your API
      if (response.data['success'] == true) {
        setState(() {
          ranapList = response.data['data'];
          filteredList = ranapList; // Initially, show all data
          isLoading = false;
        });
      } else {
        showSnackbar("Failed to load data.");
      }
    } catch (error) {
      showSnackbar("Error fetching data.");
    }
  }

  void filterSearchResults(String query) {
    List<dynamic> tempList = [];
    if (query.isNotEmpty) {
      tempList = ranapList.where((item) {
        return item['nama'].toLowerCase().contains(query.toLowerCase()) ||
            item['no_rawat'].toLowerCase().contains(query.toLowerCase()) ||
            item['bgsl'].toLowerCase().contains(query.toLowerCase()) ||
            item['alamat'].toLowerCase().contains(query.toLowerCase()) ||
            item['kel'].toLowerCase().contains(query.toLowerCase()) ||
            item['kec'].toLowerCase().contains(query.toLowerCase()) ||
            item['kab'].toLowerCase().contains(query.toLowerCase()) ||
            item['prov'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else {
      tempList = ranapList; // Reset to full list if search is empty
    }
    setState(() {
      filteredList = tempList;
    });
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranap List')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: filterSearchResults,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Total Data: ${filteredList.length}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 5), // Small spacing
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      var item = filteredList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(item['nama'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("No Rawat: ${item['no_rawat']}"),
                              Text("Bangsal: ${item['bgsl']}"),
                              Text("Alamat: ${item['alamat']}"),
                              Text("Kota: ${item['kab']} - ${item['prov']}"),
                            ],
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () {
                            showSnackbar("${item['nama']} selected.");
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
