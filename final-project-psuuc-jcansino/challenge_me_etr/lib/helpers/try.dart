import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    label: Text('Item'),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.add)),
            ],
          ),
        ],
      ),
    );
  }
}
