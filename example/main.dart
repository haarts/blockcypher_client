import 'package:blockcypher/blockcypher.dart';

void main(List<String> args) async {
  var client = Client.websocket("wss://socket.blockcypher.com/v1/btc/main", args[0]);

  /// Very high throughput without the optional address filter!
  Stream<String> txs = await client.unconfirmedTransactions();
  await for (String tx in txs) {
    print(tx);
  }

  Stream<String> blocks = await client.newBlocks();
	await for (String block in blocks) {
  	print(block);
	}

	await client.transactionConfirmation("14jvs228RDi8P1sa49VqyUpkguNCsR332r");
}
