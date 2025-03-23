import 'package:flutter/material.dart';
import 'package:form_demo/User.dart';

class UserDetailsPage extends StatelessWidget {
  final User user;

  const UserDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Данные пользователя')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            SizedBox(height: 8),
            Text('Пароль: ${user.password}'),
            SizedBox(height: 8),
            Text('Дата рождения: ${user.birthDate.toLocal().toIso8601String().split('T')[0]}'),
            SizedBox(height: 8),
            Text('Пол: ${user.gender}'),
          ],
        ),
      ),
    );
  }
}
