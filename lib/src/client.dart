import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:web_socket_channel/io.dart';
import 'package:uuid/uuid.dart';

class Client {
  /// Used to send an appropriate User-Agent header with the HTTP requests
  static const String _userAgent = 'Blockcypher - Dart';
  static const String _mediaType = 'application/json';

  /// Used to keep the connection alive
  static const String _pingMessage = '{"event": "ping"}';

  static const _headers = {
    HttpHeaders.userAgentHeader: _userAgent,
  };

  /// The URL of the Blockcypher server.
  final Uri url;

  /// The API token
  final String token;

  Client.websocket(String url, this.token) : url = Uri.parse(url);

  /// Returns a [Stream] of ...? FIXME
  Stream<String> transactionConfirmation(String address) {
    return _streamFor(TransactionConfirmation(token, address));
  }

  /// Returns a [Stream] of blocks are they get published on the network
  Stream<String> newBlocks() {
    return _streamFor(NewBlocks(token));
  }

  /// Returns a [Stream] of transactions in the mempool. High traffic without
  /// the address filter! You're likely to run into API limits in which case
  /// this case seems to hang.
  Stream<String> unconfirmedTransactions([String address]) {
    return _streamFor(UnconfirmedTransactions(token, address));
  }

  Stream<String> _streamFor(Event event) {
    final channel = IOWebSocketChannel.connect(url, headers: _headers);
    channel.sink.add(event.toJson());

    Timer.periodic(Duration(seconds: 10), (t) => channel.sink.add(_pingMessage));

    return channel.cast<String>().stream;    
  }

  @override
  String toString() => "Client(url: $url)";
}

abstract class Event {
  final String _uuid;
  final String _token;
  final String _event;

  Event(this._token, this._event) : _uuid = Uuid().v4();

  String toJson();
}

class UnconfirmedTransactions extends Event {
  final String address;

  UnconfirmedTransactions(String token, [this.address])
      : super(token, "unconfirmed-tx");

  String toJson() {
    Map<String, dynamic> payload = {
      "id": _uuid,
      "event": _event,
      "token": _token,
    };

    if (address != null) {
      payload["address"] = address;
    }

    return json.encode(payload);
  }
}

class TransactionConfirmation extends Event {
  final String address;

  TransactionConfirmation(String token, this.address)
      : super(token, "tx-confirmation");

  String toJson() {
    return json.encode({
      "id": _uuid,
      "event": _event,
      "address": address,
      "token": _token,
    });
  }
}

class NewBlocks extends Event {
  NewBlocks(String token) : super(token, "new-block");

  String toJson() {
    return json.encode({
      "id": _uuid,
      "event": _event,
      "token": _token,
    });
  }
}
