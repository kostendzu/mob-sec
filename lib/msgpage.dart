import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:sensors_plus/sensors_plus.dart';

typedef CalculateHashC = Void Function(Pointer<Uint8>, IntPtr, Pointer<Uint8>);
typedef CalculateHashDart = void Function(Pointer<Uint8>, int, Pointer<Uint8>);

class MyResponse {
  final String message;

  MyResponse({required this.message});

  factory MyResponse.fromJson(Map<String, dynamic> json) {
    return MyResponse(
      message: json['message'],
    );
  }
}

class MyPage extends StatefulWidget {
  @override
  _MyPage createState() => _MyPage();
}

typedef NativeFunc = Int32 Function();
typedef DartFunc = int Function();

class _MyPage extends State<MyPage> {
  final TextEditingController messageController = TextEditingController();

  Timer? timer;
  List<double> accelerometerData = [];
  List<double> gyroscopeData = [];
  List<double> concatData = [];
  late String accelerometerBits = '';
  late String gyroscopeBits = '';
  final metricsMessageController = TextEditingController();
  late String xorResult ='';
  late Uint8List sha256Hash = Uint8List(32);
  late Pointer<Utf8> messageUtf8 = ''.toNativeUtf8();




  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }



  Future<void> GetInfo() async {
    timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      setState(() {
        if (accelerometerData.length > 0 && gyroscopeData.length > 0) {
          double acc = accelerometerData[0] + accelerometerData[1] + accelerometerData[2];
          double gyro = gyroscopeData[0] + gyroscopeData[1] + gyroscopeData[2];
          accelerometerBits = (acc * acc * 1000 * 1000).toInt().toRadixString(2);
          gyroscopeBits = (gyro * gyro * 1000 * 1000).toInt().toRadixString(2);
          xorResult = accelerometerBits + gyroscopeBits;

          var dylib = DynamicLibrary.open("/home/alex/Documents/Uni/Kozlovskij/moba/jni/libhash-lib.so");

          //final calculateHash = dylib.lookupFunction<CalculateHashC, CalculateHashDart>('calculateHash');
          final calculateHash = dylib
              .lookup<NativeFunction<CalculateHashC>>('calculateHash')
              .asFunction<CalculateHashDart>();

          if (calculateHash == null) {
            xorResult = 'calculateHash is not downloaded';
          }
          //final message = 'Hello, World!'; // Ваше сообщение для хэширования
          messageUtf8 = xorResult.toNativeUtf8();

          final messagePointer = messageUtf8.cast<Uint8>();
          final messageLength = xorResult.length;
          final hashBuffer = calloc<Uint8>(32);
          print('--------------------------------------------------');
          print(messageUtf8);
          print(messageLength);
          print(hashBuffer);
          calculateHash(messagePointer, messageLength, hashBuffer);

          sha256Hash = hashBuffer.asTypedList(32);

        }
      });
    });

    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        accelerometerData = [event.x, event.y, event.z];
      });
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        gyroscopeData = [event.x, event.y, event.z];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Отправка сообщения')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: 'Введите сообщение'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: GetInfo,
              child: Text('Получить данные с акселерометра'),
            ),
            SizedBox(height: 16.0),
            Text('Акселерометр:'),
            Text('x=${accelerometerData.isNotEmpty ? accelerometerData[0].toStringAsFixed(3) : 0.000}'),
            Text('y=${accelerometerData.isNotEmpty ? accelerometerData[1].toStringAsFixed(3) : 0.000}'),
            Text('z=${accelerometerData.isNotEmpty ? accelerometerData[2].toStringAsFixed(3) : 0.000}'),
            Text('bits=$accelerometerBits'),
            SizedBox(height: 16.0),
            Text('Гироскоп:'),
            Text('x=${gyroscopeData.isNotEmpty ? gyroscopeData[0].toStringAsFixed(3) : 0.000}'),
            Text('y=${gyroscopeData.isNotEmpty ? gyroscopeData[1].toStringAsFixed(3) : 0.000}'),
            Text('z=${gyroscopeData.isNotEmpty ? gyroscopeData[2].toStringAsFixed(3) : 0.000}'),
            Text('bits=$gyroscopeBits'),
            SizedBox(height: 16.0),
            Text('Сумма: $xorResult'),
            Text('Поинтер: $messageUtf8'),
            Text('Хэш: $sha256Hash')
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyPage(),
  ));
}
