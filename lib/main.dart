import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/helper/check_link_type.dart';
import 'package:flutter_qr_scan/video_player.dart';
import 'package:flutter_qr_scan/audio_player.dart'; // Add this line to import AudioPlayerScreen
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp((const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruang Ngaji Kita - QR Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHome(),
    );
  }
}

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ruang Ngaji Kita - QR Scanner')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRViewExample(),
            ));
          },
          child: const Text('qrView'),
        ),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isProcessing = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                result != null
                    ? 'Hasil Code: ${result!.code}\nFormat: ${describeEnum(result!.format)}'
                    : 'Scan a QR code',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (isProcessing) return; // Mencegah pemrosesan ulang
      isProcessing =
          true; // Set flag ke true untuk mencegah pemrosesan berulang

      setState(() {
        result = scanData;
      });

      String? scannedCode = result?.code;
      if (scannedCode != null) {
        print('Hasil Scan: $scannedCode');

        if (scannedCode.startsWith('http')) {
          bool isMp4 = await isMp4File(scannedCode);
          if (isMp4) {
            controller.pauseCamera();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(videoUrl: scannedCode),
              ),
            );
            isProcessing =
                false; // Reset flag setelah kembali dari VideoPlayerScreen
            controller.resumeCamera();
          } else if (scannedCode.endsWith('.mp3')) {
            controller.pauseCamera();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AudioPlayerScreen(audioUrl: scannedCode),
              ),
            );
            isProcessing =
                false; // Jika bukan video, reset flag agar bisa scan ulang
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Error: Format tidak didukung. Silakan scan ulang.'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pop(context);
          }
        }
      } else {
        isProcessing = false;
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
}
