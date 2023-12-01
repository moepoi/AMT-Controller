import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AMT Controller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 169, 74, 201)),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 169, 74, 201),
            brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const AMTController(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AMTController extends StatefulWidget {
  const AMTController({super.key});

  @override
  State<AMTController> createState() => _AMTControllerState();
}

class _AMTControllerState extends State<AMTController> {
  late MqttServerClient client;
  var status = false.obs;
  var hostName = 'miko.moe.team';
  var topic = 'amt';

  @override
  Widget build(BuildContext context) {
    connect().then((value) => value);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AMT Controller'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Obx(() => Container(
                margin: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: status.value
                      ? const Icon(Icons.motion_photos_on_rounded)
                      : const Icon(Icons.motion_photos_off_rounded),
                  onPressed: () {},
                  tooltip: status.value ? 'Connected' : 'Disconnected',
                  color: Colors.white,
                ),
              )),
        ],
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
                onPressed: () {
                  go('maju');
                },
                icon: const Icon(Icons.arrow_upward),
                label: const Text(""),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(const EdgeInsets.only(
                        top: 25, bottom: 25, left: 30, right: 25)))),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
                onPressed: () {
                  go('kiri');
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text(""),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(const EdgeInsets.only(
                        top: 25, bottom: 25, left: 30, right: 25)))),
            InkWell(
              onTap: () {
                go('berhenti');
              },
              child: Icon(
                Icons.stop_circle_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ElevatedButton.icon(
                onPressed: () {
                  go('kanan');
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text(""),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(const EdgeInsets.only(
                        top: 25, bottom: 25, left: 30, right: 25)))),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
                onPressed: () {
                  go('mundur');
                },
                icon: const Icon(Icons.arrow_downward),
                label: const Text(""),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(const EdgeInsets.only(
                        top: 25, bottom: 25, left: 30, right: 25)))),
          ],
        ),
      ]),
    );
  }

  Future<String> connect() async {
    client = MqttServerClient(hostName, '');
    client.keepAlivePeriod = 20;

    final connMessage = MqttConnectMessage()
        .authenticateAs('username', 'password')
        .startClean();

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      status.value = false;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      status.value = true;
      client.subscribe(topic, MqttQos.atLeastOnce);
      return 'Connected';
    } else {
      client.disconnect();
      return 'Failed to connect';
    }
  }

  void go(String direction) {
    try {
      var builder = MqttPayloadBuilder();
      builder.addString(direction);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    } catch (e) {
      status.value = false;
    }
  }
}
