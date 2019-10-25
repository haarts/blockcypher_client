# Blockcypher library

[![pub package](https://img.shields.io/pub/v/blockcypher.svg)](https://pub.dartlang.org/packages/blockcypher)
[![CircleCI](https://circleci.com/gh/inapay/blockcypher_client.svg?style=svg)](https://circleci.com/gh/inapay/blockcypher_client)

A library for communicating with the [Blockcypher API]. Only some websocket calls are implemented.

## Examples

Listen for all new blocks:

```dart
  var client =
      Client.websocket("wss://socket.blockcypher.com/v1/btc/main", "YOUR-TOKEN");

  Stream<String> blocks = await client.newBlocks();
  await for (String block in blocks) {
    print("new block: $block");
  }
```

For more examples see the [examples](examples) directory.

## Installing

Add it to your `pubspec.yaml`:

```
dependencies:
  blockcypher: 0.1.2
```

## Licence overview

All files in this repository fall under the license specified in 
[COPYING](COPYING). The project is licensed as [AGPL with a lesser clause](https://www.gnu.org/licenses/agpl-3.0.en.html). 
It may be used within a proprietary project, but the core library and any 
changes to it must be published online. Source code for this library must 
always remain free for everybody to access.

[Blockcypher API]: https://www.blockcypher.com/dev/bitcoin/
