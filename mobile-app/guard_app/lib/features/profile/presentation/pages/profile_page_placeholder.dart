import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('${state.user.firstName} ${state.user.lastName}'),
                      subtitle: const Text('Name'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(state.user.email),
                      subtitle: const Text('Email'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.work),
                      title: Text(state.user.role),
                      subtitle: const Text('Role'),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No user data'));
        },
      ),
    );
  }
}
