import 'dart:convert';
import 'dart:io';
import 'dart:developer' as devTools;
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

Future<List<List<String>>> mapTickets(String path, List<Ticket> tickets) async {
  final List<List<String>> listToCSV = [
    ['Position;Name;Score;TicketReference;TicketName;TicketEmail']
  ];

  final listOfWinnersIncludingHeaders = await readFromCSV(path: path);
  // remove headers
  final listOfWinners = listOfWinnersIncludingHeaders.sublist(1).map(
    (List<dynamic> row) {
      final item = row[0].split(';');
      final json = {
        'position': item[0],
        'name': item[1],
        'score': item[2],
      };
      return MenteeAttendee.fromJson(json);
    },
  ).toList();

  devTools.log("Getting tickets start");
  await Future.forEach(
    listOfWinners,
    (MenteeAttendee item) async {
      devTools.log(item.position);
      // valid ticket
      if (item.name.length == 6 && item.name.contains('-')) {
        // make a call
        final ticket = await getTicket(
          reference: item.name,
          tickets: tickets,
        );
        if (ticket != null) {
          devTools.log('item: ${item.name}, reference: ${ticket.reference}');
          listToCSV.add(
            [
              '${item.position};${item.name};${item.score};${ticket.reference};${ticket.name};${ticket.email}'
            ],
          );
        }
      } else {
        // not valid ticket
        devTools.log('item: ${item.name}, reference: not valid');
        listToCSV.add(
          ['${item.position};${item.name};${item.score};-;-;-'],
        );
      }
    },
  );
  devTools.log("Getting tickets end");
  return listToCSV;
}

class MenteeAttendee {
  final String position;
  final String name;
  final String score;

  MenteeAttendee({
    required this.position,
    required this.name,
    required this.score,
  });

  factory MenteeAttendee.fromJson(Map<String, dynamic> json) {
    return MenteeAttendee(
      name: json['name'],
      position: json['position'],
      score: json['score'],
    );
  }
}

class Ticket {
  Ticket({
    required this.email,
    required this.name,
    required this.reference,
    this.slug,
  });

  final String email;
  final String name;
  final String reference;
  final String? slug;

  factory Ticket.fromJSON(Map<String, dynamic> json) {
    return Ticket(
      email: json['email'] ?? json['registration_email'] ?? '',
      name: json['name'] ?? json['registration_name'] ?? '',
      reference: json['reference'],
      slug: json['slug'],
    );
  }
}

Future<List<Ticket>> getTickets({
  required String account,
  required String event,
  required String token,
  int page = 1,
  List<Ticket>? tickets,
}) async {
  final allTickets = tickets ?? [];

  final url = Uri.parse(
    'https://api.tito.io/v3/$account/$event/tickets?page=$page',
  );

  final response = await http.get(
    url,
    headers: {
      'Authorization': ' Token token=$token',
      'Accept': 'application/json'
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonTickets = jsonDecode(response.body)['tickets'];

    final List<Ticket> tickets = jsonTickets
        .map(
          (dynamic ticket) => Ticket.fromJSON(ticket),
        )
        .toList();

    allTickets.addAll(tickets);

    final int? next_page = jsonDecode(response.body)['meta']['next_page'];

    if (next_page != null) {
      devTools.log('nextPage is $next_page');
      return getTickets(
        account: account,
        event: event,
        token: token,
        page: next_page,
        tickets: allTickets,
      );
    }
  }

  devTools.log('allTickets are fetched!');
  return allTickets;
}

Future<Ticket?> getTicket({
  required String reference,
  required List<Ticket> tickets,
}) async {
  final filterTickets = tickets.where(
    (element) => element.reference == reference,
  );

  return filterTickets.isNotEmpty ? filterTickets.first : null;
}

Future<List<List<dynamic>>> readFromCSV({
  required String path,
}) async {
  final input = File(path).openRead();

  final List<List<dynamic>> fields = await input
      .transform(utf8.decoder)
      .transform(CsvToListConverter())
      .toList();

  return fields;
}

Future<void> writeToCSV({
  required List<List<dynamic>> list,
  required String fileName,
}) async {
  final String csv = const ListToCsvConverter().convert(list);

  final Directory directory = Directory.current;
  final pathOfTheFileToWrite = '${directory.path}/$fileName.csv';
  final File file = await File(pathOfTheFileToWrite);
  file.writeAsString(csv);
}
