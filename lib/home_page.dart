import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedVehicle = 'SUV';
  String selectedTransmission = 'Automatic';
  String selectedFuel = 'Petrol';

  final engineController = TextEditingController();
  final cylController = TextEditingController();
  final co2Controller = TextEditingController();

  String result = '';
  bool isLoading = false;

  final List<String> vehicleClasses = [
    'SUV', 'Sedan', 'Hatchback', 'Truck', 'Van', 'Coupe'
  ];

  final List<String> transmissionTypes = [
    'Automatic', 'Manual', 'CVT', 'Semi-Automatic'
  ];

  final List<String> fuelTypes = [
    'Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'
  ];

  Future<void> predictFuelConsumption() async {
    final uri = Uri.parse('http://127.0.0.1:5000/api/predict');
    final Map<String, dynamic> data = {
      'vehicle': selectedVehicle,
      'engine': engineController.text,
      'cyl': cylController.text,
      'trans': selectedTransmission,
      'co2': co2Controller.text,
      'fuel': selectedFuel,
    };

    setState(() {
      isLoading = true;
      result = '';
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          result = 'Prediction: ${json['prediction']}';
        });
      } else {
        setState(() {
          result = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        result = 'Network error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    engineController.dispose();
    cylController.dispose();
    co2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fuel Consumption Predictor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Vehicle Class'),
                value: selectedVehicle,
                items: vehicleClasses.map((vehicle) {
                  return DropdownMenuItem(
                    value: vehicle,
                    child: Text(vehicle),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedVehicle = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: engineController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Engine Size (L)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cylController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cylinders'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Transmission'),
                value: selectedTransmission,
                items: transmissionTypes.map((trans) {
                  return DropdownMenuItem(
                    value: trans,
                    child: Text(trans),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedTransmission = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: co2Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'CO2 Emissions (g/km)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Fuel Type'),
                value: selectedFuel,
                items: fuelTypes.map((fuel) {
                  return DropdownMenuItem(
                    value: fuel,
                    child: Text(fuel),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedFuel = val!),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : predictFuelConsumption,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Predict'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  result,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
