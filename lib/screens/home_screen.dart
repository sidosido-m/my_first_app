import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marketplace"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [

            // 🔐 Login / Register
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text("Login"),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text("Register"),
                ),
              ],
            ),

            SizedBox(height: 20),

            // 🛒 Products button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/products');
              },
              child: Text("View Products"),
            ),

            SizedBox(height: 20),

            // 🏪 Seller panel
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/seller');
              },
              child: Text("Seller Panel"),
            ),
          ],
        ),
      ),
    );
  }
}