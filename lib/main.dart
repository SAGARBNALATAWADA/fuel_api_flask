import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(FuelPredictorApp());

class FuelPredictorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuel Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FuelPredictionPage(),
    );
  }
}

class FuelPredictionPage extends StatefulWidget {
  @override
  _FuelPredictionPageState createState() => _FuelPredictionPageState();
}

class _FuelPredictionPageState extends State<FuelPredictionPage> {
  final _formKey = GlobalKey<FormState>();

  String? _vehicleClass;
  String? _transmission;
  String? _fuelType;
  double? _engineSize;
  int? _cylinders;
  int? _co2;

  String _result = '';
  bool _isLoading = false;

  final List<String> vehicleClasses = [
    'Two-seater', 'Minicompact', 'Compact', 'Subcompact', 'Mid-size', 'Full-size',
    'SUV: Small', 'SUV: Standard', 'Minivan', 'Station wagon: Small',
    'Station wagon: Mid-size', 'Pickup truck: Small', 'Special purpose vehicle',
    'Pickup truck: Standard'
  ];

  final List<String> transmissionTypes = ['AV', 'AM', 'M', 'AS', 'A'];
  final List<String> fuelTypes = ['D', 'E', 'X', 'Z'];

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _vehicleClass == null ||
        _transmission == null ||
        _fuelType == null) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _result = '';
    });

    final url = Uri.parse('https://fuel-api-vybx.onrender.com/predict'); // ✅ LIVE API URL

    final body = {
      "vehicle": _vehicleClass,
      "engine": _engineSize.toString(),
      "cyl": _cylinders.toString(),
      "trans": _transmission,
      "co2": _co2.toString(),
      "fuel": _fuelType
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'] ?? 'No result';

        String emoji = '⛽';
        double? value = double.tryParse(result);
        if (value != null) {
          if (value < 4) emoji = '😢⛽';
          else if (value < 7) emoji = '🚗';
          else if (value < 10) emoji = '🚗🌿';
          else emoji = '🌱✨';
        }

        setState(() {
          _result = "$result km/L $emoji";
        });
      } else {
        Fluttertoast.showToast(msg: "Server error: ${response.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "API call failed: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fuel Consumption Predictor")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            DropdownButtonFormField<String>(
              value: _vehicleClass,
              items: vehicleClasses
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (val) => setState(() => _vehicleClass = val),
              decoration: InputDecoration(labelText: "Vehicle Class"),
              validator: (val) => val == null ? "Required" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Engine Size (L)"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onSaved: (val) => _engineSize = double.tryParse(val!),
              validator: (val) => val!.isEmpty ? "Required" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Number of Cylinders"),
              keyboardType: TextInputType.number,
              onSaved: (val) => _cylinders = int.tryParse(val!),
              validator: (val) => val!.isEmpty ? "Required" : null,
            ),
            DropdownButtonFormField<String>(
              value: _transmission,
              items: transmissionTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => setState(() => _transmission = val),
              decoration: InputDecoration(labelText: "Transmission Type"),
              validator: (val) => val == null ? "Required" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "CO₂ Emission (g/km)"),
              keyboardType: TextInputType.number,
              onSaved: (val) => _co2 = int.tryParse(val!),
              validator: (val) => val!.isEmpty ? "Required" : null,
            ),
            DropdownButtonFormField<String>(
              value: _fuelType,
              items: fuelTypes
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) => setState(() => _fuelType = val),
              decoration: InputDecoration(labelText: "Fuel Type"),
              validator: (val) => val == null ? "Required" : null,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitForm,
                    child: Text("Predict"),
                  ),
            SizedBox(height: 30),
            if (_result.isNotEmpty)
              Text(
                _result,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
          ]),
        ),
      ),
    );
  }
}
