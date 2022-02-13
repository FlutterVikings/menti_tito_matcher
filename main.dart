import 'package:tito_matcher/utils.dart';

Future<void> main() async {
  final account = String.fromEnvironment('ACCOUNT_SLUG');
  final event = String.fromEnvironment('EVENT_SLUG');
  final token = String.fromEnvironment('TOKEN');

  if (token.isEmpty || event.isEmpty || account.isEmpty) {
    return;
  }

  // get all ti.to tickets
  final List<Ticket> allTickets = await getTickets(
    account: account,
    event: event,
    token: token,
  );

  // EXAMPLE: How to use

  // Andrea
  /// CSV headers "position;name;score"
  final listToCSV_andrea = await mapTickets('./andrea.csv', allTickets);
  await writeToCSV(list: listToCSV_andrea, fileName: 'andrea_generated');

  // Robert
  /// CSV headers "position;name;score"
  final listToCSV_robert = await mapTickets('./robert.csv', allTickets);
  await writeToCSV(list: listToCSV_robert, fileName: 'robert_generated');
}
