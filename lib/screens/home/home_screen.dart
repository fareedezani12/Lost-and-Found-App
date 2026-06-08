import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/report_model.dart';
import '../../providers/report_provider.dart';
import '../../widgets/item_card.dart';
import '../report/add_report_screen.dart';
import '../report/report_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 25, child: Icon(Icons.person)),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back!",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "User",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search item...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
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

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No Reports Found"));
                    }

                    final reports = snapshot.data!;

                    final filteredReports = reports.where((report) {
                      return report.title.toLowerCase().contains(searchText) ||
                          report.location.toLowerCase().contains(searchText) ||
                          report.category.toLowerCase().contains(searchText);
                    }).toList();

                    if (filteredReports.isEmpty) {
                      return const Center(child: Text("No Matching Results"));
                    }

                    return ListView.builder(
                      itemCount: filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ItemCard(
                            title: report.title,
                            location: report.location,
                            imageUrl: report.imageUrl.isEmpty
                                ? "https://picsum.photos/200"
                                : report.imageUrl,
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
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReportScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
