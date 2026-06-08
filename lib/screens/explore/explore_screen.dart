import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/report_model.dart';
import '../../providers/report_provider.dart';
import '../../widgets/item_card.dart';
import '../report/report_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String selectedCategory = "All";
  String searchText = "";

  final List<String> categories = [
    "All",
    "Electronics",
    "Documents",
    "Accessories",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Explore"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },

              decoration: InputDecoration(
                hintText: "Search item...",
                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 45,

              child: ListView.builder(
                scrollDirection: Axis.horizontal,

                itemCount: categories.length,

                itemBuilder: (context, index) {
                  final category = categories[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),

                    child: ChoiceChip(
                      label: Text(category),

                      selected: selectedCategory == category,

                      onSelected: (value) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<List<ReportModel>>(
                stream: context.read<ReportProvider>().getReports(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text("No Reports"));
                  }

                  List<ReportModel> reports = snapshot.data!;

                  reports = reports.where((report) {
                    final matchSearch =
                        report.title.toLowerCase().contains(searchText) ||
                        report.location.toLowerCase().contains(searchText);

                    final matchCategory = selectedCategory == "All"
                        ? true
                        : report.category == selectedCategory;

                    return matchSearch && matchCategory;
                  }).toList();

                  if (reports.isEmpty) {
                    return const Center(child: Text("No matching reports"));
                  }

                  return ListView.builder(
                    itemCount: reports.length,

                    itemBuilder: (context, index) {
                      final report = reports[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),

                        child: ItemCard(
                          title: report.title,
                          location: report.location,

                          imageUrl: report.imageUrl.isEmpty
                              ? "https://picsum.photos/300"
                              : report.imageUrl,

                          isLost: report.isLost,

                          onTap: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    ReportDetailsScreen(report: report),
                              ),
                            );
                          },
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
}
