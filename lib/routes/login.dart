import 'package:flutter/material.dart';



void main() => runApp(const MyApp());
String mail = "";
String pass = "";

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /*double _altura = 100.0;
  double _largura = 100.0;

  _aumentaLargura() {
    setState(() {
      _largura = _largura >= 320.0 ? 100.0 : _largura += 50.0;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: const Prime(),
    );
  }
}

class Prime extends StatelessWidget {
  const Prime({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Faça seu login')),
          leading: GestureDetector(
            child: const Text('Faça seu login'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => const Login())));
            },
          ),
        ),
        body: Center(
            child: Column(
          children: [
            const SizedBox(
              width: 600,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Email(typeicon: Icons.mail),
              ),
            ),
            const SizedBox(
              width: 600,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Pass(typeicon: Icons.vpn_key),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                    width: 300,
                    height: 50,
                    child: ElevatedButton.icon(
                        onPressed: () {
                          l.login(mail, pass);
                        },
                        //style: const ButtonStyle(backgroundColor: Colors.blueGrey),
                        icon: const Icon(Icons.verified),
                        label: const Text("confirm"))))
          ],
        )));
  }
}

class Email extends StatelessWidget {
  final IconData typeicon;
  const Email({Key? key, required this.typeicon}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    return TextFormField(
      //onChanged: (text) => verifymail(text),
      onEditingComplete: () => mail = email.toString(),
      controller: email,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          labelText: "Digite seu email",
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                  color: Color.fromRGBO(52, 152, 219, 1), width: 2.0),
              borderRadius: BorderRadius.all(Radius.circular(60))),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(40.0))),
          prefixIcon: Icon(typeicon)),

      //onSubmitted: (text) => ,
    );
  }
}

class Pass extends StatelessWidget {
  final IconData typeicon;
  const Pass({Key? key, required this.typeicon}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final password = TextEditingController();
    return TextFormField(
      //onChanged: (text) => verifymail(text),
      controller: password,
      onEditingComplete: () => pass = password.toString(),
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
          labelText: "Digite sua senha",
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                  color: Color.fromRGBO(52, 152, 219, 1), width: 2.0),
              borderRadius: BorderRadius.all(Radius.circular(60.0))),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(40.0))),
          prefixIcon: Icon(typeicon)),

      //onSubmitted: (text) => ,
    );
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Segunda Rota (tela)"),
        ),
        body: Center(
            child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Retornar !'),
        )));
  }
}

/*
void verifymail(String email) {
  var domain = {
    "@gmail.com",
    "@outlook.com",
    "@hotmail.com",
    ".com",
    ".com.br"
  };
  if (!email.contains(domain.toString())) return error("validatemail");
}
*/
String error(String err) {
  return err;
}
