import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a new UUID v4 string.
String generateId() => _uuid.v4();
