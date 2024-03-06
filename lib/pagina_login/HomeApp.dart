import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

PDFListState uploadPDFglobal = PDFListState();

class PDFList extends StatefulWidget {
  const PDFList({super.key});

  @override
  PDFListState createState() => PDFListState();
}

class PDFListState extends State<PDFList> {
  List<String> pdfEnviadosComSucesso = [];
  List<String> pdfEnviadosComSucesso2 = [];

  @override
  void initState() {
    super.initState();
    clearPDFList();
    loadPDFs(); // Carregue a lista no início do widget
  }

  void clearPDFList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('pdfEnviadosComSucesso');
    prefs.remove('pdfEnviadosComSucesso2');
  }

  void loadPDFs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pdfEnviadosComSucesso =
          prefs.getStringList('pdfEnviadosComSucesso') ?? [];
      pdfEnviadosComSucesso2 =
          prefs.getStringList('pdfEnviadosComSucesso2') ?? [];
    });
  }

  Future<void> addPDF(String fileName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? pdfEnviadosComSucesso =
        prefs.getStringList('pdfEnviadosComSucesso');

    pdfEnviadosComSucesso ??= [];

    pdfEnviadosComSucesso.add(fileName);
    prefs.setStringList('pdfEnviadosComSucesso', pdfEnviadosComSucesso);

    print("PDF adicionado com sucesso: $fileName");
  }

  Future<void> addPDF2(String fileName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? pdfEnviadosComSucesso2 =
        prefs.getStringList('pdfEnviadosComSucesso2');

    pdfEnviadosComSucesso2 ??= [];

    pdfEnviadosComSucesso2.add(fileName);
    prefs.setStringList('pdfEnviadosComSucesso2', pdfEnviadosComSucesso2);

    print("Erro ao adicionar PDF: $fileName");
  }

  uploadPDF() async {
    try {
      // 2. Selecione os arquivos PDF usando o FilePicker
      List<PlatformFile?>? results = (await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      ))
          ?.files;

      if (results == null || results.isEmpty) {
        print("Nenhum arquivo selecionado");
        return;
      }

      // 3. Prepare o FormData para upload
      String token = await getToken();
      print("Token enviado para a API: $token");

      for (PlatformFile? platformFile in results) {
        if (platformFile != null) {
          var request = http.MultipartRequest(
            'POST',
            Uri.parse(
                'https://sielloregistros.com.br/core/integracao/v2/contratos/imagem/files/'),
          )..headers['authorization'] = token;

          String filePath = platformFile.path!;

          String fileName = platformFile.name;

          // Lê o conteúdo do arquivo como bytes
          List<int> fileBytes = await File(filePath).readAsBytes();

          // Adicione o arquivo à lista de arquivos no FormData
          request.files.add(http.MultipartFile.fromBytes(
            'files',
            filename: fileName,
            fileBytes,
          ));

          // 4. Envie a solicitação POST
          var response = await request.send();

          // 5. Lidere com a resposta

          if (response.statusCode == 200) {
            print("PDF enviado com sucesso!");

            // Adicione o nome do arquivo à lista de PDFs enviados com sucesso
            await addPDF(fileName);

            // Carregue a lista novamente após adicionar o PDF

            // Recarregue a página após adicionar o PDF
            pdfListKey.currentState?.loadPDFs();
          } else if (response.statusCode == 422) {
            print("Erro ao enviar o PDF. Código: ${response.statusCode}");
            print(
                "PDF não enviado: arquivo já existente com o mesmo chassi no registro.");

            print("Motivo: ${response.reasonPhrase}");
            print(
                "Resposta do servidor: ${await response.stream.bytesToString()}");

            // Adicione o nome do arquivo à lista de PDFs enviados com sucesso
            await addPDF2(fileName);

            // Carregue a lista novamente após adicionar o PDF

            // Recarregue a página após adicionar o PDF
            pdfListKey.currentState
                ?.loadPDFs(); // Adicione o nome do arquivo à lista de PDFs enviados com sucesso
          } else {
            print("Erro ao enviar o PDF. Código: ${response.statusCode}");
            print("Motivo: ${response.reasonPhrase}");
            print(
                "Resposta do servidor: ${await response.stream.bytesToString()}");

            // Adicione o nome do arquivo à lista de PDFs enviados com sucesso
            await addPDF2(fileName);

            // Carregue a lista novamente após adicionar o PDF

            // Recarregue a página após adicionar o PDF
            pdfListKey.currentState
                ?.loadPDFs(); // Adicione o nome do arquivo à lista de PDFs enviados com sucesso
          }
        }
      }
    } catch (e) {
      print("Erro durante o envio do PDF: $e");
      print("Tipo da exceção: ${e.runtimeType}");
      print("Mensagem de erro: ${e.toString()}");
    } finally {
      loading =
          false; // Certifique-se de desativar o indicador de carregamento, mesmo em caso de erro
    }
  }

  showSuccessMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF enviado com sucesso!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<String> getToken() async {
    final url = Uri.parse(
        'https://sielloregistros.com.br/core/authenticator/autenticarSso');

    Map<String, dynamic> dados = {
      "email": "andrejone88@gmail.com",
      "senha": "123@Teste",
    };

    try {
      final response = await http.post(
        url,
        body: json.encode(dados),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      print("Token obtido com sucesso: ${jsonResponse['token']}");

      return jsonResponse['token'];
    } catch (e) {
      print("Erro ao obter o token: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.black, width: 0.3))),
                margin: const EdgeInsets.only(
                  left: 20,
                  right: 0,
                ),
                padding: const EdgeInsets.only(left: 40, right: 5),
                child: const Text(
                  "No.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.black, width: 0.3))),
                padding: const EdgeInsets.only(left: 10, right: 30),
                child: const Text(
                  "Nome",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Container(
            child: SizedBox(
              width: 200,
              height: 200,
              child: ListView.builder(
                itemCount: pdfEnviadosComSucesso.length,
                itemExtent: 20,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      pdfEnviadosComSucesso[index],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Text(
                      '${index + 1} - ',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "PDFs não adicionados",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontWeight: FontWeight.w900,
              fontFamily: 'bornamerdium',
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.black, width: 1))),
            height: 0,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.black, width: 0.3))),
                margin: const EdgeInsets.only(
                  left: 20,
                  right: 0,
                ),
                padding: const EdgeInsets.only(left: 40, right: 5),
                child: const Text(
                  "No.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.black, width: 0.3))),
                padding: const EdgeInsets.only(left: 10, right: 30),
                child: const Text(
                  "Nome",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Container(
            child: SizedBox(
              width: 200,
              height: 100,
              child: ListView.builder(
                itemCount: pdfEnviadosComSucesso2.length,
                itemExtent: 20,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      pdfEnviadosComSucesso2[index],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Text(
                      '${index + 1} - ',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

GlobalKey<PDFListState> pdfListKey = GlobalKey<PDFListState>();

bool loading = false;

class HomeApp extends StatefulWidget {
  const HomeApp({super.key});

  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  String? token;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexToColor("#22408d"),
        title: Center(
          child: Text(
            "Envio de Imagem do contrato ",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 35,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontFamily: 'bornamerdium',
            ),
          ),
        ),
      ),
      body: Center(
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
                  height: 30,
                ),
                Expanded(
                  child: Container(
                    width: 900,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
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
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: Colors.black, width: 0.1))),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Column(children: [
                                      Container(
                                        margin: const EdgeInsets.all(15),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: hexToColor(
                                                "#22408d"), // Cor do texto do botão
                                            padding: const EdgeInsets.all(
                                                40), // Espaçamento interno do botão
                                            textStyle: const TextStyle(
                                              fontSize:
                                                  18.0, // Tamanho do texto do botão
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  13.0), // Borda arredondada do botão
                                            ),
                                            elevation: 4.0, // Elevação do botão
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              loading =
                                                  true; // Ativar o indicador de carregamento
                                            });

                                            await uploadPDFglobal.uploadPDF();

                                            setState(() {
                                              loading =
                                                  false; // Desativar o indicador de carregamento
                                            });
                                          }, // Call the function directly
                                          child: const Text("Carregar PDF"),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        // Ajuste a duração conforme necessário
                                        height: loading ? 15 : 5,
                                        curve: Curves
                                            .easeInOut, // Use um Curve para um movimento suave
                                      ),
                                      if (loading)
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          height: loading ? 35 : 0,
                                          child: CircularProgressIndicator(
                                            color: hexToColor('#22408d'),
                                          ),
                                        ), // Indicador de carregamento

                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        height: loading ? 15 : 5,
                                        curve: Curves.easeInOut,
                                      ),
                                      Container(
                                        width: 210,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                35, 158, 158, 158),
                                            border: Border.all(
                                              color: hexToColor("#22408d"),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Column(children: [
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 6),
                                                  child: Icon(
                                                    Icons
                                                        .warning_amber_outlined,
                                                    color:
                                                        hexToColor("#22408d"),
                                                    size: 25.0,
                                                  ),
                                                ),
                                                Text(
                                                  "O nome do arquivo PDF ",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        hexToColor("#303b60"),
                                                    fontWeight: FontWeight.w900,
                                                    fontFamily: 'bornamerdium',
                                                  ),
                                                ),
                                              ]),
                                          Text(
                                            "deve ser o numero do chassi do veiculo",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: hexToColor("#303b60"),
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'bornamerdium',
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ]),
                                  ),
                                ]),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Alinha os itens no eixo principal (verticalmente)
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center, // Alinha os itens no eixo cruzado (horizontalmente)
                                  children: [
                                    Container(
                                      width: 300,
                                      margin: const EdgeInsets.all(15),
                                      child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center, // Alinha os itens verticalmente no centro
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center, // Alinha os itens horizontalmente no centro
                                          children: [
                                            SizedBox(
                                              width: double.infinity,
                                              child: Text(
                                                "PDFs adicionados",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: hexToColor("#303b60"),
                                                  fontWeight: FontWeight.w900,
                                                  fontFamily: 'bornamerdium',
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              child: PDFList(key: pdfListKey),
                                            ),
                                          ]),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
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
              ]))),
    );
  }
}
