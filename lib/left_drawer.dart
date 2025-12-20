import 'package:flutter/material.dart';
import 'package:oliminate_mobile/features/main-page/main_page.dart';
import 'package:oliminate_mobile/features/ticketing/ticketing_page.dart';
import 'package:oliminate_mobile/features/user-profile/main_profile.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Bagian routing
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            // Bagian redirection ke MyHomePage
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LandingPage(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_box),
            title: const Text('Profile'),
            // Bagian redirection ke NewsFormPage
            onTap: () {
              /*
              Buatlah routing ke NewsFormPage di sini,
              setelah halaman NewsFormPage sudah dibuat.
              */
              /*
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ));
              */
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Schedule'),
            onTap: () {
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //       // Assuming you'll have a dedicated NewsListPage later
              //       builder: (context) => const SchedulePage(), 
              //     ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Ticketing'),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    // Assuming you'll have a dedicated NewsListPage later
                    builder: (context) => const TicketingPage(), 
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.shop_2),
            title: const Text('Merchandise'),
            onTap: () {
              /*
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    // Assuming you'll have a dedicated NewsListPage later
                    builder: (context) => const MerchandisePage(), 
                  ));
                */
            },
          ),
          ListTile(
            leading: const Icon(Icons.reviews),
            title: const Text('Review'),
            onTap: () {
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //       // Assuming you'll have a dedicated NewsListPage later
              //       builder: (context) => const ReviewPage(), 
              //     ));
            },
          ),
        ],
      ),
    );
  }
}