import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

class Code128 extends StatefulWidget {
  const Code128({Key? key}) : super(key: key);

  @override
  State<Code128> createState() => _Code128State();
}

class _Code128State extends State<Code128> {
  late final TextEditingController _textController;
  late final FocusNode _textFocus;

  @override
  void initState() {
    _textController = TextEditingController();
    _textFocus = FocusNode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 24.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BarcodeWidget(
                barcode: Barcode.code128(escapes: true),
                data: _textController.text,
                width: 400,
                height: 200,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _textController,
                        focusNode: _textFocus,
                        onEditingComplete: () => setState(() {}),
                        decoration: InputDecoration(
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
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
}
