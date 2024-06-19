import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import 'barcode_conf.dart';

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
  void initState() {
    super.initState();
    _textController = TextEditingController();
    conf.data = '123456789';
    _textFocus = FocusNode();
    _inputDecoration = InputDecoration(
      labelText: 'Штрих-код',
      labelStyle: const TextStyle(
        color: Color(0xFF80919F),
      ),
      hintText: 'Введите штрих-код',
      hintStyle: const TextStyle(
        color: Color(0xFF80919F),
      ),
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
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BarcodeWidget(
                padding: EdgeInsets.only(bottom: 32),
                barcode: Barcode.code128(escapes: true),
                data: _textController.text,
                drawText: false,
                width: 300,
                height: 100,
              ),
              TextField(
                controller: _textController,
                focusNode: _textFocus,
                maxLines: 1,
                maxLength: 15,
                decoration: _inputDecoration,
                onChanged: (code) =>
                    setState(() => conf.data = _textController.text),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            onPressed: conf.exportSvg,
            icon: const Icon(Icons.file_download),
            label: const Text('SVG'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            onPressed: conf.exportPng,
            icon: Icon(Icons.file_download),
            label: const Text('PNG'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            icon: Icon(Icons.file_download),
            onPressed: conf.exportPdf,
            label: const Text('PDF'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            onPressed: conf.exportA4Pdf,
            icon: const Icon(Icons.file_download),
            label: const Text('А4 PDF'),
          ),
        ],
      ),
    );
  }
}
