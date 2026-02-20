import 'package:entralogin/blocs/microsoft_login_cubit.dart';
import 'package:entralogin/blocs/microsoft_login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Azure SSO Login")),
      body: BlocProvider(
        create: (context) => AuthCubit(),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${state.errorMessage}")));
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (state is AuthSuccess) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Display profile photo if available
                    state.profilePhoto != null
                        ? ClipOval(child: Image.memory(state.profilePhoto!, width: 100, height: 100, fit: BoxFit.cover))
                        : Icon(Icons.account_circle, size: 100),
                    SizedBox(height: 10),
                    Text("Welcome, ${state.name}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("Email: ${state.email}", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthCubit>().logout(); // Call the logout method
                      },
                      child: Text("Logout"),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<AuthCubit>().login(); // call the login method
                },
                child: Text("Login with Microsoft"),
              ),
            );
          },
        ),
      ),
    );
  }
}
