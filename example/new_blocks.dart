import 'package:blockcypher/blockcypher.dart';

void main(List<String> args) async {
  var token = args[0];
  var client =
      Client(token: token, websocketUrl: "wss://socket.blockcypher.com/v1/btc/main");

  Stream<String> blocks = client.newBlocks();
  await for (String block in blocks) {
    print("new blocK: $block");
  }
}
