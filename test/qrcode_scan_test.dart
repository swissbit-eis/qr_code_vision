import 'dart:io';
import 'dart:math';

import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart';
import 'package:qr_code_vision/qr_code_vision.dart';
import 'package:test/test.dart';

void main() {
  group("QR Scanner", () {
    test('can locate and decode totp qr code without margin', () {
      final imageBytes = File("./test/qrcode_scan_test_data/otp_qr_code.png")
          .readAsBytesSync();
      final qrCode = new QrCode();
      qrCode.scanImageBytes(imageBytes);
      expect(qrCode.location, isNotNull);
      expect(qrCode.content?.text,
          "otpauth://totp/max.musterman%40gate.company.test?secret=CNIA7THKN26W4B7RYIOUFKOL4ZVFKWPYUDJGFNLOXHOMCVBP7IRZ%3D%3D%3D%3D&algorithm=SHA256&issuer=company&period=60");
    });

    test('can locate and parse perfect qr codes', () {
      // Generate QR codes with random content of increasing length and assert
      // that the scanner can locate and decode them correctly.
      const _chars =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890:/#%';
      Random _rnd = Random(1234); // constant seed
      String getRandomString(int length) =>
          String.fromCharCodes(Iterable.generate(
              length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

      final image = Image(width: 147, height: 147);
      for (int len = 70; len < 200; len++) {
        for (int i = 0; i < 100; i++) {
          String data = getRandomString(len);
          fill(image, color: ColorRgb8(255, 255, 255));
          drawBarcode(image, Barcode.qrCode(), data);

          final qrCode = new QrCode();
          qrCode.scanImage(image);

          // If the detection and decoding fails dump the QR code into an
          // image file for debugging.
          File? qrFile;
          if (qrCode.location == null || qrCode.content?.text != data) {
            final dir = Directory.systemTemp.createTempSync();
            qrFile = File("${dir.path}/qr_code_error.png");
            qrFile.writeAsBytesSync(encodePng(image));
          }

          final reason =
              "Length: $len, Iteration: $i, QR code: ${qrFile?.path}";
          expect(qrCode.location, isNotNull, reason: reason);
          expect(qrCode.content?.text, data, reason: reason);
        }
      }
    });
  });
}
