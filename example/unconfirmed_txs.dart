import 'package:blockcypher/blockcypher.dart';

void main(List<String> args) async {
  var token = args[0];
  var client =
      Client.websocket("wss://socket.blockcypher.com/v1/btc/main", token);

  /// Very high throughput without the optional address filter!
  Stream<String> txs = await client.unconfirmedTransactions();
  await for (String tx in txs) {
    print(tx);
  }

  Stream<String> blocks = await client.newBlocks();
  await for (String block in blocks) {
    print(block);
  }

  Stream<String> confs = await client
      .transactionConfirmation("3ETUD57Zm1oKrGUikFLsh5xFRieWJzN1sc");
  await for (String conf in confs) {
    print(conf);
  }
}
