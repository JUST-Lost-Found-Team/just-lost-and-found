import 'package:flutter/material.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? selectedBuilding;
  DateTime? selectedDate;

  final List<String> MedicalBuildings = [
    "M1",
    "M2",
    "M3",
    "M4",
    "M5",
    "M6",
    "N1",
    "N2",
    "N3",
    "N4",
    "D1",
    "D2",
    "D3",
    "D4",
    "PH1",
    "PH2",
    "PH3",
    "PH4",
    "P1",
    "P2",
    "P3",
    "Medical Lab 10C",
    "Medical Lab 10D",
    "Medical Lab 10E",
    "Medical Lab 10F",
    "Medical Lab 10G",
    "Medical Lab 10H",
    "Medical Cafeteria",
  ];
  final List<String> EngineeringBuildings = [
    "D1",
    "A1",
    "A2",
    "A3",
    "A4",
    "G1",
    "G2",
    "G3",
    "G4",
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "M1",
    "M2",
    "M3",
    "M4",
    "M5",
    "M6",
    "M7",
    "M8",
    "E1",
    "E2",
    "E3",
    "E4",
    "N1",
    "N2",
    "CH1",
    "CH2",
    "Workshops"
        "Engineering Cafeteria",
  ];
  final List<String> GeneralFacilities = [
    "The Central Library ",
    "Deanship of Student Affairs ",
    "Student Center (MALL)",
    "The Mosque ",
    "Gym & Stadium ",
    "Bus Station ",
    "Stadium",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Filter by Location",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ThemeManager.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildExpansionSection(
                  "Medical Campus ",
                  Icons.local_hospital,
                  MedicalBuildings,
                ),
                const Divider(),
                _buildExpansionSection(
                  "Engineering Campus ",
                  Icons.engineering,
                  EngineeringBuildings,
                ),
                const Divider(),
                _buildExpansionSection(
                  "General Facilities",
                  Icons.account_balance,
                  GeneralFacilities,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedBuilding = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: ThemeManager.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'reset',
                      style: TextStyle(color: ThemeManager.primaryBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedBuilding);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: ThemeManager.primaryYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      "Apply Filter",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionSection(
    String title,
    IconData icon,
    List<String> items,
  ) {
    return ExpansionTile(
      leading: Icon(icon, color: ThemeManager.primaryBlue),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      children: items.map((item) {
        return RadioListTile<String>(
          title: Text(item, style: const TextStyle(fontSize: 14)),
          value: item,
          groupValue: selectedBuilding,
          activeColor: ThemeManager.primaryYellow,
          onChanged: (value) {
            setState(() {
              selectedBuilding = value;
            });
          },
        );
      }).toList(),
    );
  }
}
