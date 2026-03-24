import 'package:flutter/material.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey =GlobalKey<FormState>();
  TextEditingController emailCTRL=TextEditingController();
  TextEditingController passwordCTRL=TextEditingController();
  void _submit(){
    if (_formKey.currentState!.validate()){
      print('Success: Welcome JUST student!');
      //رح نحتاج نحط اشي للفايبربيس هون يا بنات
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: SafeArea(
     child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child:Form(
          key:_formKey,
          child: Column(
            children: [
              Image.asset('images/Gemini_Generated_Image.png',height: 200,fit:BoxFit.cover),
              const Text(
               'Sign In',
               style: TextStyle(
                color:Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
               ),
              ),
              const SizedBox(height: 20,),
              TextFormField(
               controller: emailCTRL,
               decoration: InputDecoration(
                hintText: 'Email (@just.edu.jo)',
                filled: true,
                fillColor: Colors.grey.withOpacity(0.24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.email),
                
               ),
               keyboardType: TextInputType.emailAddress,
               validator: (value) {
                    if (value == null || value.isEmpty) 
                    return 'Enter email';
                    
                    if (!value.endsWith('@just.edu.jo')) {
                      return 'Use your JUST university email only';
                    }
                    return null;
                  },
              ),
              const SizedBox(height:10 ,),
              TextFormField(
               controller: passwordCTRL,
               decoration: InputDecoration(
                hintText: 'Password',
                filled: true,
                fillColor: Colors.grey.withOpacity(0.24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: GestureDetector(
                  onTap:(){
                    
                  },
                  child: Icon(Icons.remove_red_eye_outlined),
                ),
               ),
               keyboardType: TextInputType.visiblePassword,
               obscureText: true,
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: (){},
                    child: Text('Forget your password?',style: TextStyle(color: Colors.orange,fontSize: 13,fontWeight: FontWeight.bold),),
                  ),

                ],
              ),
              const SizedBox(height: 32,),
              // SizedBox(
              //   width: ,
              // )
            ],
           
          ),
        
        ),
        ),
     ),),
    );
  }
}