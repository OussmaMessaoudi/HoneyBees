import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share2cash/dashboard.dart';
import 'package:share2cash/packet_sdk.dart';
import 'package:share2cash/secrets.dart';
import 'package:share2cash/settings.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HoneyBees"),
        leading: IconButton(
          onPressed: () => showMaterialModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SettingsPage();
            },
          ),
          icon: Icon(Icons.settings),
        ),
        actions: [],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              WaveWidget(
                config: CustomConfig(
                  durations: [10000],
                  heightPercentages: [-0.007],
                  colors: [Colors.yellow.shade600],
                ),
                size: Size(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height * 0.6,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(13),
                    bottomRight: Radius.circular(13),
                  ),
                  color: Colors.yellow.shade600,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Dashboard(),
                SizedBox(height: 25),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [PacketSdkButton(appKey: apikey)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
