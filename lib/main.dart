/*
 * Copyright (C) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:barcode_image/barcode_image.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: const Code128(),
      );
}

class Code128 extends StatefulWidget {
  const Code128({Key? key}) : super(key: key);

  @override
  State<Code128> createState() => _Code128State();
}

class _Code128State extends State<Code128> {
  late final TextEditingController _textController;
  late final FocusNode _textFocus;
  late final InputDecoration _inputDecoration;

  final BarcodeConf conf = BarcodeConf();

  @override
  void dispose() {
    _textController.dispose();
    _textFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    conf.type = BarcodeType.Code128;
    conf.data = '00000000000000';
    _textFocus = FocusNode();
    _inputDecoration = InputDecoration(
      labelText: 'Штрих-код',
      labelStyle: const TextStyle(color: Color(0xFF80919F), fontSize: 22),
      hintText: 'Введите штрих-код',
      hintStyle: const TextStyle(color: Color(0xFF80919F), fontSize: 22),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.black54,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.black,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _textController,
                focusNode: _textFocus,
                maxLines: 1,
                maxLength: 16,
                decoration: _inputDecoration,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9%]')),
                ],
                onChanged: (code) => conf.data = _textController.text,
              ),
              Download(conf: conf),
            ],
          ),
        ),
      );
}

class Download extends StatelessWidget {
  const Download({super.key, required this.conf});

  final BarcodeConf conf;

  @override
  Widget build(BuildContext context) {
    if (!conf.barcode.isValid(conf.normalizedData)) {
      return const SizedBox.shrink();
    }

    return Theme(
      data: Theme.of(context).copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.black),
          ),
        ),
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.white),
        ),
        onPressed: conf.exportSvg,
        child: const Text('SVG'),
      ),
    );
  }
}

/// Barcode configuration
class BarcodeConf extends ChangeNotifier {
  String? _data;

  /// Data to encode
  String get data => _data ?? _defaultData;
  set data(String value) {
    _data = value;
    notifyListeners();
  }

  String get normalizedData {
    if (barcode is BarcodeEan && barcode.name != 'UPC E') {
      // ignore: avoid_as
      final ean = barcode as BarcodeEan;
      return ean.normalize(data);
    }

    return data;
  }

  String _defaultData = 'OZON';

  late Barcode _barcode;

  late String _desc;

  late String _method;

  late BarcodeType _type;

  /// Size of the font
  double fontSize = 30.0;

  /// height of the barcode
  double height = 60.0;

  /// width of the barcode
  double width = 335.0;

  Barcode get barcode => _barcode;

  String get desc => _desc;

  String get method => _method;

  /// Barcode type
  BarcodeType get type => _type;

  set type(BarcodeType value) {
    _type = value;

    switch (_type) {
      case BarcodeType.Itf:
        fontSize = 25;
        _defaultData = '345874';
        _desc =
            'Interleaved 2 of 5 (ITF) is a continuous two-width barcodesymbology encoding digits. It is used commercially on 135 film, for ITF-14 barcodes, and on cartons of some products, while the products inside are labeled with UPC or EAN.';
        _method = 'itf(zeroPrepend: true)';
        _barcode = Barcode.itf(zeroPrepend: true);
        break;
      case BarcodeType.CodeITF16:
        fontSize = 25;
        height = 140;
        _defaultData = '1234567890123452';
        _desc =
            'ITF-16 is a standardized version of the Interleaved 2 of 5 barcode, also known as UPC Shipping Container Symbol. It is used to mark cartons, cases, or pallets that contain products. It containins 16 digits, the last being a check digit.';
        _method = 'itf16()';
        _barcode = Barcode.itf16();
        break;
      case BarcodeType.CodeITF14:
        fontSize = 25;
        height = 140;
        _defaultData = '9872346598257';
        _desc =
            'ITF-14 is the GS1 implementation of an Interleaved 2 of 5 (ITF) bar code to encode a Global Trade Item Number. ITF-14 symbols are generally used on packaging levels of a product, such as a case box of 24 cans of soup. The ITF-14 will always encode 14 digits.';
        _method = 'itf14()';
        _barcode = Barcode.itf14();
        break;
      case BarcodeType.CodeEAN13:
        _defaultData = '873487659295';
        _desc =
            'The International Article Number is a standard describing a barcode symbology and numbering system used in global trade to identify a specific retail product type, in a specific packaging configuration, from a specific manufacturer.';
        _method = 'ean13(drawEndChar: true)';
        _barcode = Barcode.ean13(drawEndChar: true);
        break;
      case BarcodeType.CodeEAN8:
        width = 300;
        _defaultData = '3465920';
        _desc =
            'An EAN-8 is an EAN/UPC symbology barcode and is derived from the longer International Article Number code. It was introduced for use on small packages where an EAN-13 barcode would be too large; for example on cigarettes, pencils, and chewing gum packets. It is encoded identically to the 12 digits of the UPC-A barcode, except that it has 4 digits in each of the left and right halves.';
        _method = 'ean8(drawSpacers: true)';
        _barcode = Barcode.ean8(drawSpacers: true);
        break;
      case BarcodeType.CodeEAN5:
        _defaultData = '12749';
        width = 150;
        _desc =
            'The EAN-5 is a 5-digit European Article Number code, and is a supplement to the EAN-13 barcode used on books. It is used to give a suggestion for the price of the book.';
        _method = 'ean5()';
        _barcode = Barcode.ean5();
        break;
      case BarcodeType.CodeEAN2:
        _defaultData = '42';
        width = 100;
        _desc =
            'The EAN-2 is a supplement to the EAN-13 and UPC-A barcodes. It is often used on magazines and periodicals to indicate an issue number.';
        _method = 'ean2()';
        _barcode = Barcode.ean2();
        break;
      case BarcodeType.CodeISBN:
        fontSize = 25;
        height = 140;
        _defaultData = '329873497482';
        _desc =
            'The International Standard Book Number is a numeric commercial book identifier which is intended to be unique. Publishers purchase ISBNs from an affiliate of the International ISBN Agency.';
        _method = 'isbn(drawEndChar: true)';
        _barcode = Barcode.isbn(drawEndChar: true);
        break;
      case BarcodeType.Code39:
        _defaultData = 'HELLO WORLD';
        _desc =
            'The Code 39 specification defines 43 characters, consisting of uppercase letters (A through Z), numeric digits (0 through 9) and a number of special characters (-, ., \$, /, +, %, and space). An additional character (denoted \'*\') is used for both start and stop delimiters.';
        _method = 'code39()';
        _barcode = Barcode.code39();
        break;
      case BarcodeType.Code93:
        _defaultData = 'HELLO WORLD';
        _desc =
            'Code 93 is a barcode symbology designed in 1982 by Intermec to provide a higher density and data security enhancement to Code 39. It is an alphanumeric, variable length symbology. Code 93 is used primarily by Canada Post to encode supplementary delivery information.';
        _method = 'code93()';
        _barcode = Barcode.code93();
        break;
      case BarcodeType.CodeUPCA:
        _defaultData = '37234876234';
        _desc =
            'The Universal Product Code is a barcode symbology that is widely used in the United States, Canada, Europe, Australia, New Zealand, and other countries for tracking trade items in stores. UPC consists of 12 numeric digits that are uniquely assigned to each trade item.';
        _method = 'upcA()';
        _barcode = Barcode.upcA();
        break;
      case BarcodeType.CodeUPCE:
        _defaultData = '18740000915';
        _desc =
            'The Universal Product Code is a barcode symbology that is widely used in the United States, Canada, Europe, Australia, New Zealand, and other countries for tracking trade items in stores. To allow the use of UPC barcodes on smaller packages, where a full 12-digit barcode may not fit, a zero-suppressed version of UPC was developed, called UPC-E, in which the number system digit, all trailing zeros in the manufacturer code, and all leading zeros in the product code, are suppressed';
        _method = 'upcE()';
        _barcode = Barcode.upcE();
        break;
      case BarcodeType.Code128:
        _defaultData = 'Hello World';
        _desc =
            'Code 128 is a high-density linear barcode symbology defined in ISO/IEC 15417:2007. It is used for alphanumeric or numeric-only barcodes. It can encode all 128 characters of ASCII and, by use of an extension symbol, the Latin-1 characters defined in ISO/IEC 8859-1.';
        fontSize = 25;
        _method = 'code128(escapes: true)';
        _barcode = Barcode.code128(escapes: true);
        break;
      case BarcodeType.GS128:
        _defaultData = '(420)22345(56780000000001)';
        _desc =
            'The GS1-128 is an application standard of the GS1. It uses a series of Application Identifiers to include additional data such as best before dates, batch numbers, quantities, weights and many other attributes needed by the user.';
        _method = 'gs128(useCode128A: false, useCode128B: false)';
        fontSize = 25;
        _barcode = Barcode.gs128(useCode128A: false, useCode128B: false);
        break;
      case BarcodeType.Telepen:
        _defaultData = 'Hello';
        _desc =
            'Telepen is a barcode designed in 1972 in the UK to express all 128 ASCII characters without using shift characters for code switching, and using only two different widths for bars and spaces.';
        _method = 'telepen()';
        _barcode = Barcode.telepen();
        break;
      case BarcodeType.QrCode:
        width = 300;
        height = width;
        _defaultData = 'Hello World';
        _desc =
            'QR code (abbreviated from Quick Response code) is the trademark for a type of matrix barcode (or two-dimensional barcode) first designed in 1994 for the automotive industry in Japan.';
        _method = 'qrCode()';
        _barcode = Barcode.qrCode();
        break;
      case BarcodeType.Codabar:
        _defaultData = '7698-1239';
        _desc =
            'Codabar was designed to be accurately read even when printed on dot-matrix printers for multi-part forms such as FedEx airbills and blood bank forms, where variants are still in use as of 2007.';
        _method = 'codabar()';
        _barcode = Barcode.codabar();
        break;
      case BarcodeType.PDF417:
        _defaultData = 'Hello World';
        _desc =
            'PDF417 is a stacked linear barcode format used in a variety of applications such as transport, identification cards, and inventory management.';
        _method = 'pdf417()';
        _barcode = Barcode.pdf417();
        break;
      case BarcodeType.DataMatrix:
        width = 300;
        height = width;
        _defaultData = 'Hello World';
        _desc =
            'A Data Matrix is a two-dimensional barcode consisting of black and white "cells" or modules arranged in either a square or rectangular pattern, also known as a matrix.';
        _method = 'dataMatrix()';
        _barcode = Barcode.dataMatrix();
        break;
      case BarcodeType.Aztec:
        width = 300;
        height = width;
        _defaultData = 'Hello World';
        _desc = 'Named after the resemblance of the central finder pattern to an Aztec pyramid.';
        _method = 'aztec()';
        _barcode = Barcode.aztec();
        break;
      case BarcodeType.Rm4scc:
        height = 60;
        _defaultData = 'HELLOWORLD';
        _desc =
            'The RM4SCC is used for the Royal Mail Cleanmail service. It enables UK postcodes as well as Delivery Point Suffixes (DPSs) to be easily read by a machine at high speed.';
        _method = 'rm4scc()';
        _barcode = Barcode.rm4scc();
        break;
      case BarcodeType.Postnet:
        height = 60;
        _defaultData = '55555-1237';
        _desc =
            'POSTNET (Postal Numeric Encoding Technique) is a barcode symbology used by the United States Postal Service to assist in directing mail.';
        _method = 'postnet()';
        _barcode = Barcode.postnet();
        break;
    }

    notifyListeners();
  }

  (String, String) splitCode(String code) {
    // Extract all digits from the string
    final digits = code.replaceAll(RegExp(r'%.*?%'), '');
    if (code.length < 16) {
      return ('0000000', '0000');
    } else {
      return (digits.substring(0, 7), digits.substring(7, digits.length));
    }
  }

  String _d(double d) {
    assert(d != double.infinity);
    return d.toStringAsFixed(5);
  }

  String _s(String s) {
    const esc = HtmlEscape();
    return esc.convert(s);
  }

  String _c(int c) {
    return '#${(c & 0xffffff).toRadixString(16).padLeft(6, '0')}';
  }

  String toSvg(
    Iterable<BarcodeElement> recipe,
    double width,
    double height,
    int color,
  ) {
    final path = StringBuffer();
    final tSpan = StringBuffer();
    /*<svg viewBox="0.0 0.0 335.0 126.0" xmlns="http://www.w3.org/2000/svg">
  
    <rect x="8" y="10" width="318" height="16" style="fill: #000000"/>
  
    <path transform="translate(8, 55)" d="M 0.00000 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 3.84615 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 10.25641 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 14.10256 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 19.23077 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 21.79487 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 28.20513 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 30.76923 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 35.89744 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 42.30769 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 48.71795 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 51.28205 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 56.41026 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 61.53846 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 66.66667 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 70.51282 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 75.64103 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 80.76923 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 84.61538 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 87.17949 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 93.58974 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 98.71795 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 103.84615 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 107.69231 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 112.82051 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 119.23077 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 123.07692 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 126.92308 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 130.76923 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 137.17949 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 141.02564 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 146.15385 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 152.56410 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 155.12821 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 160.25641 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 164.10256 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 169.23077 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 171.79487 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 178.20513 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 183.33333 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 189.74359 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 194.87179 0.00000 h 1.28205 v 60.00000 h -1.28205 z M 197.43590 0.00000 h 2.56410 v 60.00000 h -2.56410 z M 201.74359 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 215.74359 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 220.74359 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 230.74359 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 240.74359 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 250.74359 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 260.74359 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 270.74359 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 280.74359 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 290.74359 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 300.74359 0.00000 h 3.84615 v 60.00000 h -3.84615 z M 310.74359 0.00000 h 3.84615 v 60.00000 h -3.84615 z" style="fill: #000000"/>
  
    <text transform="translate(75, 30)" style="fill: #000000; font-family: PT Sans;">
    <tspan style="font-family: DejaVu Sans; font-size:18.0px;" x="0.0" y="16.0">КТЯ</tspan>
    <tspan style="font-weight: normal; font-size:12.0px;" x="45.0" y="16.0">2121345</tspan>
    <tspan style="font-weight: bold; font-size:18.0px;" x="100.0" y="16.0">5900</tspan>
    <tspan style="font-weight: normal; font-size:12.0px;" x="150.0" y="16.0">000</tspan>
 
    </text>
    </svg>*/

    // Draw the barcode
    for (var elem in recipe) {
      if (elem is BarcodeBar) {
        if (elem.black) {
          path.write('M ${_d(elem.left)} ${_d(elem.top)} ');
          path.write('h ${_d(elem.width)} ');
          path.write('v ${_d(elem.height)} ');
          path.write('h ${_d(-elem.width)} ');
          path.write('z ');
        }
      } else if (elem is BarcodeText) {
        final (onePart, twoPart) = splitCode(elem.text);

        tSpan.write(
            '<text transform="translate(${_d(75)}, ${_d(20)})" style="fill: ${_c(color)}; font-family: ${_s('PT Sans')};">');
        tSpan.write(
            '<tspan style="font-family: ${_s('DejaVu Sans')}; font-size: ${_d(18)}px;" x="${_d(0)}" y="${_d(16)}">${_s('КТЯ')}</tspan>');
        tSpan.write(
            '<tspan style="font-weight: normal; font-size: ${_d(12)}px;" x="${_d(45)}" y="${_d(16)}">${_s(onePart)}</tspan>');
        tSpan.write(
            '<tspan style="font-weight: bold; font-size: ${_d(18)}px;" x="${_d(100)}" y="${_d(16)}">${_s(twoPart)}</tspan>');
        tSpan.write(
            '<tspan style="font-weight: normal; font-size: ${_d(12)}px;" x="${_d(150)}" y="${_d(16)}">${_s('000')}</tspan>');
        tSpan.write('</text>');
      }
    }

    final output = StringBuffer();

    output.write('<svg viewBox="${_d(0)} ${_d(0)} ${_d(width)} ${_d(height)}" xmlns="http://www.w3.org/2000/svg">');

    output
        .write('<rect x="${_d(0)}" y="${_d(0)}" width="${_d(width)}" height="${_d(16)}" style="fill: ${_c(color)}"/>');

    output.write('<path transform="translate(${_d(0)}, ${_d(40)})" d="$path" style="fill: ${_c(color)}"/>');

    output.write(tSpan);

    output.write('</svg>');

    return output.toString();
  }

  Future<void> exportPdf() async {
    final pdf = pw.Document(
      author: 'OZON',
      title: barcode.name,
    )..addPage(
        pw.Page(
          build: (context) => pw.Center(
            child: pw.Column(
              children: [
                pw.BarcodeWidget(
                  barcode: barcode,
                  data: normalizedData,
                  width: 7 * PdfPageFormat.cm,
                  height: 2 * PdfPageFormat.cm,
                  drawText: false,
                ),
                pw.Text(
                  normalizedData,
                  style: pw.TextStyle(fontSize: 21),
                ),
              ],
            ),
          ),
        ),
      );

    final location = await getSaveLocation();
    if (location != null) {
      final file = XFile.fromData(
        await pdf.save(),
        name: '${normalizedData}.pdf',
        mimeType: 'application/pdf',
      );
      await file.saveTo(location.path);
    }
  }

  Future<void> exportA4Pdf() async {
    try {
      final pdf = pw.Document(
        author: 'OZON',
        title: 'Возвратные ШК',
      );
      const scale = 7.0;
      final List<String> digitsList = normalizedData.split('#').sublist(1);
      final int codeDigitFormat = int.tryParse(digitsList.last) ?? 0;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            21.0 * PdfPageFormat.cm,
            29.7 * PdfPageFormat.cm,
            marginTop: PdfPageFormat.cm,
          ),
          build: (context) => pw.Center(
            child: pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                27,
                (i) {
                  final String code = '#${digitsList.first}#' + '${codeDigitFormat + i}'.padLeft(10, '0');
                  return pw.Column(
                    children: [
                      pw.BarcodeWidget(
                        barcode: barcode,
                        data: code,
                        width: width * PdfPageFormat.mm / scale,
                        height: height * PdfPageFormat.mm / scale,
                        drawText: false,
                      ),
                      pw.Text(
                        code,
                        style: pw.TextStyle(fontSize: 21),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      final location = await getSaveLocation();
      if (location != null) {
        final file = XFile.fromData(
          await pdf.save(),
          name: '${normalizedData}.pdf',
          mimeType: 'application/pdf',
        );
        await file.saveTo(location.path);
      }
    } catch (e) {
      return;
    }
  }

  Future<void> exportPng() async {
    final bc = barcode;
    final image = im.Image(
      width: width.toInt() * 2,
      height: height.toInt() * 2,
    );
    im.fill(image, color: im.ColorRgb8(255, 255, 255));
    drawBarcode(image, bc, normalizedData, font: im.arial48);
    final data = im.encodePng(image);

    final location = await getSaveLocation();
    if (location != null) {
      final file = XFile.fromData(
        Uint8List.fromList(data),
        name: '${normalizedData}.png',
        mimeType: 'image/png',
      );
      await file.saveTo(location.path);
    }
  }

  Future<void> exportSvg() async {
    final bc = barcode;
    final fontHeight = height * 0.02;
    final textPadding = height * 0.05;

    final recipe = bc.make(
      normalizedData,
      width: width.toDouble(),
      height: height.toDouble(),
      drawText: true,
      fontHeight: fontHeight.toDouble(),
      textPadding: textPadding.toDouble(),
    );

    final data = toSvg(recipe, width, height, 000000);

    final location = await getSaveLocation();
    if (location != null) {
      final file = XFile.fromData(
        Uint8List.fromList(utf8.encode(data)),
        name: '${normalizedData}.svg',
        mimeType: 'image/svg+xml',
      );
      await file.saveTo(location.path);
    }
  }
}
