import 'package:flutter_test/flutter_test.dart';

import 'package:cyberspace_client/src/exceptions.dart';
import 'package:cyberspace_client/src/resources/resource.dart';

void main() {
  group('response data helpers', () {
    test('extracts object data from an envelope', () {
      final data = responseDataObject({
        'data': {'id': 'value'},
      });

      expect(data, {'id': 'value'});
    });

    test('extracts list data from an envelope', () {
      final data = responseDataList({
        'data': [
          {'id': 'one'},
          {'id': 'two'},
        ],
      });

      expect(data, [
        {'id': 'one'},
        {'id': 'two'},
      ]);
    });

    test('parses paged object data from an envelope', () {
      final page = parsePaged({
        'data': {
          'data': [
            {'id': 'one'},
          ],
          'cursor': 'next',
        },
      }, (json) => json['id'] as String);

      expect(page.data, ['one']);
      expect(page.cursor, 'next');
    });

    test('rejects responses without a data envelope', () {
      expect(
        () => responseDataObject({'id': 'value'}),
        throwsA(isA<CyberspaceResponseException>()),
      );
    });
  });
}
