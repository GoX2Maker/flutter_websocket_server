import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final int pingIntervalSeconds = 10; // ping 간격

  Future<void> _startWebSocketServer() async {
    // Start the WebSocket server
    // WebSocket 서버 포트를 설정합니다.
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 4040);

    // 클라이언트 연결을 기다립니다.
    await for (HttpRequest request in server) {
      if (request.uri.path == '/ws') {
        // 클라이언트가 WebSocket으로 업그레이드 요청을 합니다.
        var socket = await WebSocketTransformer.upgrade(request);
        print('Client connected!');

        // Ping interval을 설정하여 주기적으로 ping을 보냄
        socket.pingInterval = Duration(seconds: pingIntervalSeconds);

        // 메시지를 받으면 클라이언트로 다시 전송합니다.
        socket.listen((message) {
          print('Received message: $message');
          if (message == 'pong') {
            print('Received pong from client');
          } else {
            socket.add('Echo: $message'); // 클라이언트에게 응답
          }
        }, onDone: () {
          print('Client disconnected!');
        }, onError: (error) {
          print('Error: $error');
        });
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.close();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _startWebSocketServer();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
