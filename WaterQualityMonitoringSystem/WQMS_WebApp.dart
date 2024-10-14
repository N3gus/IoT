import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

const String apiToken =
    'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJMbGE5X3BNeFVwc1QxTXpsM2dsdkRFTFZIa256OWZDb191Q3JheDh1dkJ3In0.eyJqdGkiOiJjMGM0Y2ZlMy1lZDFkLTRhNjItOTQ0Ny1iMzNkNjkxMzc3YjQiLCJleHAiOjE3MTg5MzE5NjYsIm5iZiI6MCwiaWF0IjoxNzE4OTMxMzY2LCJpc3MiOiJodHRwczovL2tleWNsb2FrLndheml1cC5pby9hdXRoL3JlYWxtcy93YXppdXAiLCJhdWQiOiJhcGktc2VydmVyIiwic3ViIjoiOTQ4NmMzYjktNzkwNS00ZjM2LTg0OWYtMTYwNTJjMjk1NzZlIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiYXBpLXNlcnZlciIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjI3ZjU3NWYzLTg4ZDItNDUyMS05ZGEwLTI1N2E1NGQ3MGIyNSIsImFjciI6IjEiLCJhbGxvd2VkLW9yaWdpbnMiOlsiKiJdLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJyZWdpc3RlcmVkX3VzZXIiLCJ1bWFfYXV0aG9yaXphdGlvbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7InJlYWxtLW1hbmFnZW1lbnQiOnsicm9sZXMiOlsibWFuYWdlLXVzZXJzIiwidmlldy11c2VycyIsInF1ZXJ5LWdyb3VwcyIsInF1ZXJ5LXVzZXJzIl19LCJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6IiIsInR3aXR0ZXIiOiIiLCJzbXNfY3JlZGl0IjoiMTAwIiwicGhvbmUiOiIrMjYwNzc3OTcxNjMwIiwibmFtZSI6IkNCVSBZb3V0aFRlYW1VcCIsInByZWZlcnJlZF91c2VybmFtZSI6ImNidXlvdXRodGVhbXVwQGdtYWlsLmNvbSIsImdpdmVuX25hbWUiOiJDQlUiLCJmYW1pbHlfbmFtZSI6IllvdXRoVGVhbVVwIiwiZW1haWwiOiJjYnV5b3V0aHRlYW11cEBnbWFpbC5jb20ifQ.fsraNmLfy87I5UwGFzfVhG86UizHvnRQ5ed3POHTDDEi6O08B7yNwIR1ZuUA0MGjta_hpvM1e0VMIYW5A9AkSE31OJFb8IQoQfb4SKso-R12Lsr5mQGSSsQCyLQRmJR1fLcvuKrmu5X4XKqTCvz4vTxbjTNJs6kcpS1bv30vJcA4zysXiwwZCbwt9CRshD_inyH2PsSGVwL1nEzDrqT5xKV_Y9m-2S19R7BZoPpJcMxjD8HGND5017KgbMneWDYu31N9L5O2M_9i-blAAmDeUhkxLTtkrK8WFruh49XLmLMN5I0SaJZgivnROcB18sLAW8AlCerpJ0rzwgKweDfeSA';
const String deviceID = 'b827eb75cac868b3';

class WaterData {
  double turbidity;
  double totaldissolvedsalt;
  double potentialhydrogen;

  WaterData({
    required this.turbidity,
    required this.totaldissolvedsalt,
    required this.potentialhydrogen,
  });
}

Future<double> fetchTurbidity() async {
  try {
    final response = await http.get(
      Uri.parse(
          'https://api.waziup.io/api/v2/devices/$deviceID/sensors/6656d74968f31908bbf670c3/values'),
      headers: {
        'Authorization': 'Bearer $apiToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is List && jsonData.isNotEmpty) {
        return jsonData.first['value']?.toDouble() ?? 0.0;
      }
    }
  } catch (e, stackTrace) {
    logger.e('Error fetching turbidity', e, stackTrace);
  }
  return 0.0;
}

Future<double> fetchTotalDissolvedSalt() async {
  try {
    final response = await http.get(
      Uri.parse(
          'https://api.waziup.io/api/v2/devices/$deviceID/sensors/6696440a68f31907bcc86d91/values'),
      headers: {
        'Authorization': 'Bearer $apiToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is List && jsonData.isNotEmpty) {
        return jsonData.first['value']?.toDouble() ?? 0.0;
      }
    }
  } catch (e, stackTrace) {
    logger.e('Error fetching total dissolved salt', e, stackTrace);
  }
  return 0.0;
}

Future<double> fetchPotentialHydrogen() async {
  try {
    final response = await http.get(
      Uri.parse(
          'https://api.waziup.io/api/v2/devices/$deviceID/sensors/6656d74968f31908bbf670c5/values'),
      headers: {
        'Authorization': 'Bearer $apiToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is List && jsonData.isNotEmpty) {
        return jsonData.first['value']?.toDouble() ?? 0.0;
      }
    }
  } catch (e, stackTrace) {
    logger.e('Error fetching potential hydrogen', e, stackTrace);
  }
  return 0.0;
}

Future<WaterData> fetchWaterData() async {
  final turbidity = await fetchTurbidity();
  final totaldissolvedsalt = await fetchTotalDissolvedSalt();
  final potentialhydrogen = await fetchPotentialHydrogen();

  return WaterData(
    turbidity: turbidity,
    totaldissolvedsalt: totaldissolvedsalt,
    potentialhydrogen: potentialhydrogen,
  );
}

void main() {
  runApp(const WaterQualityMonitorApp());
}

class WaterQualityMonitorApp extends StatelessWidget {
  const WaterQualityMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Quality Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.lightBlue[50],
        appBarTheme: AppBarTheme(
          color: Colors.blue[800],
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
          bodyLarge: TextStyle(fontSize: 18.0, color: Colors.blue[900]),
        ),
      ),
      home: const WaterMonitorScreen(),
    );
  }
}

class WaterMonitorScreen extends StatefulWidget {
  const WaterMonitorScreen({super.key});

  @override
  WaterMonitorScreenState createState() => WaterMonitorScreenState();
}

class WaterMonitorScreenState extends State<WaterMonitorScreen> {
  late Future<WaterData> _waterDataFuture;

  @override
  void initState() {
    super.initState();
    _waterDataFuture = fetchWaterData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Quality Monitor'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/water_background.jpg',
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.3),
              colorBlendMode: BlendMode.modulate,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<WaterData>(
              future: _waterDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  final data = snapshot.data ??
                      WaterData(
                          turbidity: 0.0,
                          totaldissolvedsalt: 0.0,
                          potentialhydrogen: 0.0);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSensorDisplay('Turbidity', data.turbidity, 'NTU'),
                      _buildSensorDisplay(
                          'Dissolved Salt', data.totaldissolvedsalt, 'ppm'),
                      _buildSensorDisplay(
                          'Potential Hydrogen', data.potentialhydrogen, 'pH'),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorDisplay(String label, double value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Icon(Icons.water, color: Colors.blue[700], size: 24.0),
            const SizedBox(width: 8.0),
            Text('$value $unit', style: const TextStyle(fontSize: 18.0)),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}












/*const String api_Token =
    'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJMbGE5X3BNeFVwc1QxTXpsM2dsdkRFTFZIa256OWZDb191Q3JheDh1dkJ3In0.eyJqdGkiOiI0NmIxZDk4Yy1kMDI5LTRjYmQtYTlmZi02Yzk2ZjVlNzU1NzEiLCJleHAiOjE3MTg5MjIzNTAsIm5iZiI6MCwiaWF0IjoxNzE4OTIxNzUwLCJpc3MiOiJodHRwczovL2tleWNsb2FrLndheml1cC5pby9hdXRoL3JlYWxtcy93YXppdXAiLCJhdWQiOiJhcGktc2VydmVyIiwic3ViIjoiOTQ4NmMzYjktNzkwNS00ZjM2LTg0OWYtMTYwNTJjMjk1NzZlIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiYXBpLXNlcnZlciIsImF1dGhfdGltZSI6MCwic2Vzc2lvbl9zdGF0ZSI6IjhmODYyOGU3LTNkNTEtNDA2MS04MmJiLWFjNWNjNzE5MWI1YSIsImFjciI6IjEiLCJhbGxvd2VkLW9yaWdpbnMiOlsiKiJdLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJyZWdpc3RlcmVkX3VzZXIiLCJ1bWFfYXV0aG9yaXphdGlvbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7InJlYWxtLW1hbmFnZW1lbnQiOnsicm9sZXMiOlsibWFuYWdlLXVzZXJzIiwidmlldy11c2VycyIsInF1ZXJ5LWdyb3VwcyIsInF1ZXJ5LXVzZXJzIl19LCJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6IiIsInR3aXR0ZXIiOiIiLCJzbXNfY3JlZGl0IjoiMTAwIiwicGhvbmUiOiIrMjYwNzc3OTcxNjMwIiwibmFtZSI6IkNCVSBZb3V0aFRlYW1VcCIsInByZWZlcnJlZF91c2VybmFtZSI6ImNidXlvdXRodGVhbXVwQGdtYWlsLmNvbSIsImdpdmVuX25hbWUiOiJDQlUiLCJmYW1pbHlfbmFtZSI6IllvdXRoVGVhbVVwIiwiZW1haWwiOiJjYnV5b3V0aHRlYW11cEBnbWFpbC5jb20ifQ.VcbIT_7zE1e29BLT0M0bSYBJDwMbzAul8uqW1hNEhW9EwGKyvOmu-_5HHdv0v_uBlP66DOGn_RAWRaehORjVjO_6Vn-teZtkHaZ-o1wWH6TakmN6Y_VyTAt3NSCVbKfWj3tuit54El9uj7qzV0dVZYfCkzBfhy-CDV1FL6_VUVDoyI4lWN2mtgdG3wpPbbWRNaI7R5X9Fm6o-C9-1K5_uBldaytB2Rhw09YsPSY6LxmiC4lzcpsQ4dil7pABOnZBvlBLTvOJ14YgvKO69Ab3mP75bPF1CXg-2bWcAkxNogYMckTINFb3BInT1oiDlFI13m75ZW7rYRVCObDz5kICQQ';
*/
