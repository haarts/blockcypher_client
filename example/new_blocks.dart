import 'package:blockcypher/blockcypher.dart';

void main(List<String> args) async {
  var token = args[0];
  var client =
      Client.websocket("wss://socket.blockcypher.com/v1/btc/main", token);

  Stream<String> blocks = await client.newBlocks();
  await for (String block in blocks) {
    print("new blocK: $block");
  }
}
