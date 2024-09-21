import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? _name;
  String? _email;
  String? _githubUsername;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _name = user.userMetadata?['full_name'];
        _email = user.email;
        _githubUsername = user.userMetadata?['user_name'];
        _avatarUrl = user.userMetadata?['avatar_url'];
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                child: _avatarUrl == null ? Icon(Icons.person, size: 50) : null,
              ),
              SizedBox(height: 16),
              Text(_name ?? 'Name not available',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(_email ?? 'Email not available',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('GitHub: ${_githubUsername ?? 'Not available'}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 24),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signOut,
                child: Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
