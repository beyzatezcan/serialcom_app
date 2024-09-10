import "package:flutter/material.dart";
import 'package:usb_serial/usb_serial.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serial Communication App',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const SerialCommunicationPage(),
    );
  }
}

class SerialCommunicationPage extends StatefulWidget {
  const SerialCommunicationPage({super.key});

  @override
  _SerialCommunicationPageState createState() => _SerialCommunicationPageState();
}

class _SerialCommunicationPageState extends State<SerialCommunicationPage> {
  List<UsbDevice> availablePorts = [];
  UsbPort? selectedPort;
  TextEditingController inputController = TextEditingController();
  String previousData = '';
  String previousPort = '';

  @override
  void initState() {
    super.initState();
    _getAvailablePorts();
  }

  Future<void> _getAvailablePorts() async {
    availablePorts = await UsbSerial.listDevices();
    setState(() {
      // Güncellenmiş port listesi
    });

    if (availablePorts.isEmpty) {
      print("No devices found.");
    }
  }

  void _openPort() async {
    if (selectedPort != null) {
      if (await selectedPort!.open()) {
        print('Port opened: ${selectedPort!.name}');
      } else {
        print('Failed to open port: ${selectedPort!.name}');
      }
    } else {
      print('Please select a port first.');
    }
  }

  void _sendData() {
    if (selectedPort != null && selectedPort!.isOpen) {
      String data = inputController.text;
      selectedPort!.write(Uint8List.fromList(data.codeUnits));
      setState(() {
        previousData = data;
        previousPort = selectedPort!.name;
        inputController.clear(); // Clear the input field after sending data
      });
      print('Data sent: $data');
    } else {
      print('Port is not open.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serial Communication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<UsbDevice>(
              isExpanded: true,
              value: selectedPort,
              hint: const Text('Select Port'),
              items: availablePorts.map((port) {
                return DropdownMenuItem(
                  value: port,
                  child: Text(port.productName ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPort = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openPort,
              child: const Text('Open Port'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: inputController,
              decoration: const InputDecoration(
                labelText: 'Data to Send',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedPort != null ? _sendData : null, // Disable button if no port is selected
              child: const Text('Send Data'),
            ),
            const SizedBox(height: 20),
            if (previousPort.isNotEmpty && previousData.isNotEmpty) ...[
              Text('Previous Port: $previousPort', style: TextStyle(color: Colors.green)),
              Text('Previous Data Sent: $previousData', style: TextStyle(color: Colors.green)),
            ] else if (selectedPort == null) ...[
              const Text('No port connected', style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
