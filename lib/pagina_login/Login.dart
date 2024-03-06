import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pagina_login/HomeApp.dart';

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
  static String token = "";

  static String getToken() {
    return token;
  }
}

class _LoginState extends State<Login> {
  bool _obscurePassword = true; // Para controlar a visibilidade da senha
  bool _focado = false;
  bool _focado2 = false;
  final bool _openForgotPassword = false;

  var userController = TextEditingController();
  var secretController = TextEditingController();

  bool loading = false; // Variável para controlar o indicador de carregamento
  String message = ''; // Mensagem de sucesso

  void login() async {
    setState(() {
      loading = true; // Ativar o indicador de carregamento ao iniciar o login
      message = ''; // Limpar a mensagem
    });

    final url = Uri.parse(
        'https://sielloregistros.com.br/core/authenticator/autenticarSso'); // Substitua pela sua URL

    // Dados a serem enviados no corpo da requisição
    Map<String, dynamic> dados = {
      "email": userController.text,
      "senha": secretController.text,
    };

    try {
      final response = await http.post(
        url,
        body: json.encode(dados), // Convertendo os dados para JSON
        headers: {
          'Content-Type': 'application/json', // Indicando o tipo de conteúdo
          // Adicione outros headers, se necessário
        },
      );

      // Verificando o código de status da resposta
      if (response.statusCode == 200) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomeApp()));
        // Analisar a resposta JSON
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Extrair o token da resposta
        String token = jsonResponse['token'];

        // Armazenar o token no arquivo login
        Login.token = token;

        print('Token recebido: $token');

        setState(() {
          const Text('Login bem-sucedido!');
        });
      } else {
        setState(() {
          message = 'Credeciais incorretas';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Credeciais incorretas';
      });
    } finally {
      setState(() {
        loading =
            false; // Desativar o indicador de carregamento ao finalizar o login
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: () {
              setState(() {
                _focado2 = false;
                _focado = false;
              });
            },
            child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      hexToColor("#22408d"),
                      hexToColor("#303b60"),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(children: [
                  const SizedBox(
                    height: 15,
                  ),
                  if (_openForgotPassword)
                    Container(
                      width: double.infinity,
                      height: 80,
                      color: Colors.black,
                      child: const Center(
                        child: Text("voce recebere um email"),
                      ),
                    ),
                  const SizedBox(
                    height: 0,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 46, 46, 46)
                                .withOpacity(0.4), // Cor da sombra
                            spreadRadius: 5, // Quão longe a sombra se espalha
                            blurRadius: 7, // O quão desfocada é a sombra
                            offset: const Offset(1,
                                2), // A posição da sombra (horizontal, vertical)
                          ),
                        ],
                      ),
                      width: 550,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Image(
                              width: 400,
                              height: 200,
                              fit: BoxFit.contain,
                              image: AssetImage(
                                'assets/logo_cnr_01.png',
                              ),
                            ),
                            Container(
                                margin: const EdgeInsets.only(
                                    left: 30, right: 30, bottom: 20),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: userController,
                                        onTap: () {
                                          setState(() {
                                            _focado = true;
                                            _focado2 = false;
                                          });
                                        },
                                        style: const TextStyle(
                                          color: Colors.black, // Cor do texto
                                          fontSize: 16, // Tamanho da fonte
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Usuário*',
                                          filled: true,
                                          fillColor: _focado
                                              ? Colors.black.withOpacity(0.1)
                                              : Colors.black.withOpacity(0.001),
                                          labelStyle: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                          ),
                                          focusedBorder:
                                              const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromARGB(255, 0, 0,
                                                    0)), // Cor quando selecionado
                                          ),
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromARGB(
                                                    255, 0, 0, 0)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20.0),
                                      TextFormField(
                                        controller: secretController,
                                        onTap: () {
                                          setState(() {
                                            _focado2 = true;
                                            _focado = false;
                                          });
                                        },
                                        style: const TextStyle(
                                          color: Colors.black, // Cor do texto
                                          fontSize: 16, // Tamanho da fonte
                                        ),
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          labelText: 'Senha*',
                                          filled: true,
                                          fillColor: _focado2
                                              ? Colors.black.withOpacity(0.1)
                                              : Colors.black.withOpacity(0.001),
                                          labelStyle: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700),
                                          focusedBorder:
                                              const UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.black),
                                          ),
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.black),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                        onFieldSubmitted: (value) {
                                          loading ? null : login();
                                        },
                                      ),
                                    ])),
                            Column(children: [
                              AnimatedContainer(
                                duration: const Duration(
                                    milliseconds:
                                        500), // Ajuste a duração conforme necessário
                                height: loading ? 15 : 5,
                                curve: Curves
                                    .easeInOut, // Use um Curve para um movimento suave
                                child: const SizedBox(
                                    // Substitua YourWidget pelo conteúdo desejado
                                    ),
                              ),
                              if (loading)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: loading ? 35 : 0,
                                  child: CircularProgressIndicator(
                                    color: hexToColor('#22408d'),
                                  ),
                                ),

                              /// Indicador de carregamento
                              if (message.isNotEmpty)
                                Text(
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 255, 0, 0),
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'bornamerdium',
                                    ),
                                    message),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                height: loading ? 15 : 5,
                                curve: Curves.easeInOut,
                                child: const SizedBox(),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  loading ? null : login();
                                },
                                child: Container(
                                  width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: hexToColor('#22408d'),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: const Center(
                                    child: Text(
                                      "Entrar",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'bornamedium',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(
                              height: 30,
                            ),
                          ]),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: const Text(
                              style: TextStyle(
                                fontSize: 10,
                                color: Color.fromARGB(255, 100, 100, 100),
                              ),
                              "PDF_Sync_Hub -- Version 1.0")))
                ]))));
  }

//Funcao para chamar API de login
}
