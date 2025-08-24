import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share2cash/Themes/ThemeProvider.dart';
import 'package:share2cash/fireStoreServices.dart';
import 'package:share2cash/packet_sdk.dart';


class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Consumer<PacketSdkProvider>(
              builder: (context, prov, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoCard(
                      'Bandwidth shared',
                      '${prov.totalGB.toStringAsFixed(3)} GB',
                      context,
                    ),
                    FutureBuilder<double?>(
                      future: FirestoreService().getTodayEarnings(), // <-- call firestore function
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _infoCard('Earnings today', 'Loading...', context);
                        }
                        if (snapshot.hasError) {
                          return _infoCard('Earnings today', 'Error', context);
                        }
                        return _infoCard(
                          'Earnings today',
                          '\$ ${snapshot.data?.toStringAsFixed(4) ?? '0.0000'}',
                          context,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoCard(String title, String value, BuildContext context) {
    return Container(
      height: 160,
      width: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
