import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          children: [
            Text(
              "Let's create your account",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              textAlign: TextAlign.end,
            ),
            Form(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_box_sharp),
                            labelText: "First Name ",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_box_sharp),
                            labelText: "Last Name ",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.account_circle),
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.password),
                      labelText: "Password",
                      suffixIcon: Icon(Icons.remove_red_eye),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),

                  Row(
                    children: [
                      Checkbox(value: true, onChanged: (value) {}),
                      Text("I agree to Privacy Policy and Terms of use"),
                    ],
                  ),

                  ElevatedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                    ),
                    onPressed: () {},
                    child: Text(
                      "Create Account",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
