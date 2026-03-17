import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageNotFound extends StatelessWidget {
  const PageNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 100,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 20),
              const Text(
                '404',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Page Not Found',
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'The page you are looking for doesn\'t exist or has been moved.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => context.pushReplacement("/"),
                icon: const Icon(Icons.home),
                label: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}