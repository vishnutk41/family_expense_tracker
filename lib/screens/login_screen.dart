import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final nameC = TextEditingController();
  bool isRegistering = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authViewModel = ref.read(authViewModelProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(title: Text('Login / Register')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children:[
            if (isRegistering) 
              TextField(
                controller: nameC, 
                decoration: InputDecoration(labelText:'Full Name'),
              ),
            TextField(controller: emailC, decoration: InputDecoration(labelText:'Email')),
            SizedBox(height: 12),
            TextField(controller: passC, decoration: InputDecoration(labelText:'Password'), obscureText:true),
            SizedBox(height:20),
            if (!isRegistering) ...[
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setState(() => isLoading = true);
                  try {
                    await authViewModel.signIn(emailC.text, passC.text);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  } finally {
                    setState(() => isLoading = false);
                  }
                }, 
                child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Login')
              ),
              TextButton(
                onPressed: ()=>setState(()=>isRegistering=true), 
                child: Text('Create Account')
              ),
            ] else ...[
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setState(() => isLoading = true);
                  try {
                    await authViewModel.signUp(emailC.text, passC.text, nameC.text);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  } finally {
                    setState(() => isLoading = false);
                  }
                }, 
                child: isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Register')
              ),
              TextButton(
                onPressed: ()=>setState(()=>isRegistering=false), 
                child: Text('Back to Login')
              ),
            ],
          ],
        ),
      ),
    );
  }
}
