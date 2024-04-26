import 'package:flutter/material.dart';
import 'package:walleye_sample/models/load_state.dart';
import 'package:walleye_sample/providers/subscription_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walleye Now Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Walleye Now Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ChangeNotifierProvider(
        create: (_) => SubscriptionProvider(),
        child: Center(
          child: Consumer<SubscriptionProvider>(
              builder: (context, subProvider, _) {
            List<Widget> payOptions = subProvider.products
                .map(
                  (p) => ElevatedButton(
                    onPressed: () {
                      subProvider.buy(p);
                    },
                    child: Column(
                      children: [
                        Text(p.title),
                        Text(p.description),
                        Text(p.price)
                      ],
                    ),
                  ),
                )
                .toList();
            return subProvider.state == LoadState.loading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                        const Text('Tap to select a product to buy'),
                        ...payOptions
                      ]);
          }),
        ),
      ),
    );
  }
}
