import 'package:intl/intl.dart';

// Formats purement numériques : ne nécessitent pas d'appel à
// initializeDateFormatting() pour une locale spécifique.
final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');
final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

String formatDateTime(DateTime dt) => _dateTimeFormatter.format(dt.toLocal());

String formatDate(DateTime dt) => _dateFormatter.format(dt.toLocal());
