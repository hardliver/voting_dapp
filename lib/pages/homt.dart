import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:voting_dapp/pages/election_info.dart';
import 'package:voting_dapp/services/functions.dart';
import 'package:voting_dapp/utils/constants.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Client? httpClient;
  Web3Client? ethClient;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    httpClient = Client();
    ethClient = Web3Client(
      rpcURL,
      Client(),
      socketConnector: () {
        return IOWebSocketChannel.connect(wsURL).cast<String>();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Start Election"),
      ),
      body: Container(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                filled: true,
                hintText: 'Enter election name',
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    final currentContext = context;
                    await startElection(controller.text, ethClient!);
                    if (context.mounted) {
                      Navigator.push(
                        currentContext,
                        MaterialPageRoute(
                          builder: (context) => ElectionInfo(
                            ethClient: ethClient!,
                            electionName: controller.text,
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text("Start Election"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
