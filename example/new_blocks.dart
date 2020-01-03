import 'package:blockcypher/blockcypher.dart';

void main(List<String> args) async {
  var token = args[0];
  var client =
      Client(token, websocketUrl: 'wss://socket.blockcypher.com/v1/btc/main');

  var blocks = client.newBlocks();
  await for (String block in blocks) {
    print('new block: $block');
  }
}
