import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:voting_dapp/utils/constants.dart';
import 'package:web3dart/web3dart.dart';

Future<DeployedContract> loadContract() async {
  final abiStringFile =
      await rootBundle.loadString("build/contracts/Election.json");

  final abiJson = jsonDecode(abiStringFile);
  final abi = jsonEncode(abiJson["abi"]);
  final contractAddress =
      EthereumAddress.fromHex(abiJson["networks"]["5777"]["address"]);

  final contract = DeployedContract(
    ContractAbi.fromJson(abi, "Election"),
    contractAddress,
  );
  return contract;
}

Future<String> callFunction(
  String funcname,
  List<dynamic> args,
  Web3Client ethClient,
  String privateKey,
) async {
  EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
  DeployedContract contract = await loadContract();
  final ethFunction = contract.function(funcname);
  final result = await ethClient.sendTransaction(
    credentials,
    Transaction.callContract(
      contract: contract,
      function: ethFunction,
      parameters: args,
    ),
  );
  return result;
}

Future<String> startElection(String name, Web3Client ethClient) async {
  var response =
      await callFunction("startElection", [name], ethClient, ownerPrivateKey);
  print("Election started successfully");
  return response;
}

Future<String> addCandidate(String name, Web3Client ethClient) async {
  var response =
      await callFunction("addCandidate", [name], ethClient, ownerPrivateKey);
  print("Candidate added successfully");
  return response;
}

Future<String> authorizeVoter(String address, Web3Client ethClient) async {
  var response = await callFunction(
    "authorizeVoter",
    [EthereumAddress.fromHex(address)],
    ethClient,
    ownerPrivateKey,
  );
  print("Voter authorized successfully");
  return response;
}

Future<List> getCandidateNum(Web3Client ethClient) async {
  List<dynamic> result = await ask("getNumCandidates", [], ethClient);
  return result;
}

Future<List<dynamic>> ask(
  String funcName,
  List<dynamic> args,
  Web3Client ethClient,
) async {
  final contract = await loadContract();
  final ethFunction = contract.function(funcName);
  final result =
      ethClient.call(contract: contract, function: ethFunction, params: args);
  return result;
}

Future<String> vote(int candidateIndex, Web3Client ethClient) async {
  var response = await callFunction(
    "vote",
    [BigInt.from(candidateIndex)],
    ethClient,
    voterPrivateKey,
  );
  print("Vote counted successfully");
  return response;
}
