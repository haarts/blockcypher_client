import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:mock_web_server/mock_web_server.dart';

import 'package:blockcypher/blockcypher.dart';

MockWebServer server;
Client client;

void main() {
  setUp(() async {
    server = MockWebServer();
    await server.start();
    client = Client(
      token: 'some-token',
      httpUrl: server.url,
      websocketUrl: 'ws://${server.host}:${server.port}/ws',
    );
  });

  tearDown(() async {
    server.shutdown();
  });

  test('initialize', () {
    expect(client, isNotNull);
    expect(client.httpUrl.host, '127.0.0.1');
    expect(client.websocketUrl.host, '127.0.0.1');
  });

  test('blockchain()', () async {
    var cannedResponse =
        await File('test/files/blockchain.json').readAsString();
    server.enqueue(body: cannedResponse);
    var blockchain = await client.blockchain();
    expect(json.decode(blockchain)['name'], 'BTC.main');
  });

  test('transaction()', () async {
    var cannedResponse =
        await File('test/files/transaction.json').readAsString();
    server.enqueue(body: cannedResponse);
    var transaction = await client.transaction('some-txhash');
    expect(json.decode(transaction)['block_height'], 600959);
  });

  test('transactionConfirmation()', () async {
    var cannedResponse =
        await File('test/files/transaction_conf.json').readAsString();
    server.enqueue(body: cannedResponse);
    var tx = client.transactionConfirmation('some-txhash');
    tx.listen(expectAsync1((message) {}, count: 1));
  });

  test('newBlocks()', () async {
    var cannedResponse = await File('test/files/block.json').readAsString();
    server.enqueue(body: cannedResponse);
    var blocks = client.newBlocks();
    blocks.listen(expectAsync1((message) {}, count: 1));
  });

  test('unconfirmedTransactions()', () async {
    var tx1 = await File('test/files/P2PKH.json').readAsString();
    var tx2 = await File('test/files/P2WPKH.json').readAsString();
    server.messageGenerator = (StreamSink sink) async {
      sink.add(tx1);
      sink.add(tx2);
    };

    var blocks = client.unconfirmedTransactions();
    blocks.listen(expectAsync1((message) {}, count: 2));
  });
}
