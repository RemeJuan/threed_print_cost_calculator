import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:localizely_sdk/src/common/gen_l10n/localizely_gen_l10n.dart';
import 'package:localizely_sdk/src/ota/model/release_data.dart';
import 'package:localizely_sdk/src/ota/model/label.dart';
import 'package:localizely_sdk/src/sdk_data.dart';

import 'localizely_gen_l10n_test.mocks.dart';

@GenerateMocks([ReleaseData])
void main() {
  setUp(() {
    SdkData.releaseData = null;
  });

  group('Localizely gen_l10n interceptor for Over-the-Air', () {
    test('getText returns null for a missing locale', () {
      final locale = 'en_US';
      final stringKey = 'stringKey';

      final mockedReleaseData = MockReleaseData();
      when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
        'en': {'stringKey': Label(key: 'stringKey', value: 'Plain message')},
      });
      SdkData.releaseData = mockedReleaseData;

      final response = LocalizelyGenL10n.getText(locale, stringKey);

      expect(response, isNull);
    });

    test('getText returns null for a missing string key', () {
      final locale = 'en_US';
      final stringKey = 'missingStringKey';

      final mockedReleaseData = MockReleaseData();
      when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
        'en_US': {'stringKey': Label(key: 'stringKey', value: 'Plain message')},
      });
      SdkData.releaseData = mockedReleaseData;

      final response = LocalizelyGenL10n.getText(locale, stringKey);

      expect(response, isNull);
    });

    test('getText returns correct translation for plain text message', () {
      final locale = 'en_US';
      final stringKey = 'stringKey';

      final mockedReleaseData = MockReleaseData();
      when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
        'en_US': {'stringKey': Label(key: 'stringKey', value: 'Plain message')},
      });
      SdkData.releaseData = mockedReleaseData;

      final response = LocalizelyGenL10n.getText(locale, stringKey);

      expect(response, equals('Plain message'));
    });

    test(
      'getText returns correct translation for plain text message when relax-syntax is enabled',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(key: 'stringKey', value: 'Plain message'),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [],
          {},
          {},
          true,
          false,
        );

        expect(response, equals('Plain message'));
      },
    );

    test(
      'getText returns correct translation for plain text message with placeholder like content when relax-syntax is enabled',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Plain message with {placeholderLikeContent}',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [],
          {},
          {},
          true,
          false,
        );

        expect(response, equals('Plain message with {placeholderLikeContent}'));
      },
    );

    test(
      'getText returns correct translation for plain text message with escaped content when relax-syntax is enabled',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Plain message with \'{escaped}\' content',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [],
          {},
          {},
          true,
          false,
        );

        expect(response, equals('Plain message with \'{escaped}\' content'));
      },
    );

    test(
      'getText returns correct translation for plain text message with escaped content when use-escaping is not enabled',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Plain message with \'{escaped}\' content',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          ['inserted'],
          {
            "@stringKey": {
              "placeholders": {
                "escaped": {"type": "Object"},
              },
            },
          },
          {},
        );

        expect(response, equals('Plain message with \'inserted\' content'));
      },
    );

    test(
      'getText returns correct translation for plain text message when use-escaping is enabled',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(key: 'stringKey', value: 'Plain message'),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [],
          {},
          {},
          false,
          true,
        );

        expect(response, equals('Plain message'));
      },
    );

    test(
      'getText returns correct translation for plain text message with escaped content when use-escaping is enabled',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Plain message with \'{escaped}\' content',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [],
          {},
          {},
          false,
          true,
        );

        expect(response, equals('Plain message with {escaped} content'));
      },
    );

    test(
      'getText returns correct translation for plain text message when relax-syntax and use-escaping are enabled',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(key: 'stringKey', value: 'Plain message'),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [],
          {},
          {},
          true,
          true,
        );

        expect(response, equals('Plain message'));
      },
    );

    test(
      'getText returns correct translation for plain text message with escaped content when relax-syntax and use-escaping are enabled',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Plain message with \'{escaped}\' content',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [],
          {},
          {},
          true,
          true,
        );

        expect(response, equals('Plain message with {escaped} content'));
      },
    );

    test(
      'getText returns correct translation for message with simple placeholder',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Message with {value}.',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          ['some value'],
          {
            "@stringKey": {
              "placeholders": {
                "value": {"type": "Object"},
              },
            },
          },
          {},
        );

        expect(response, equals('Message with some value.'));
      },
    );

    test(
      'getText returns correct translation for message with simple placeholder when relax-syntax is enabled',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Message with {value}.',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [],
          {},
          {},
          true,
          false,
        );

        expect(response, equals('Message with {value}.'));
      },
    );

    test(
      'getText returns correct translation for message with simple placeholder when use-escaping is enabled',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Message with {value}.',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          ['some value'],
          {
            "@stringKey": {
              "placeholders": {
                "value": {"type": "Object"},
              },
            },
          },
          {},
          false,
          true,
        );

        expect(response, equals('Message with some value.'));
      },
    );

    test(
      'getText returns correct translation for message with simple placeholder when relax-syntax and use-escaping are enabled',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Message with {value}.',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [],
          {},
          {},
          true,
          true,
        );

        expect(response, equals('Message with {value}.'));
      },
    );

    test(
      'getText returns correct translation for message with formatted DateTime placeholder',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Message created: {date}.',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [DateTime(2022, 5, 10, 12, 0)],
          {
            "@stringKey": {
              "placeholders": {
                "date": {"type": "DateTime", "format": "yMd"},
              },
            },
          },
          {},
        );

        expect(response, equals('Message created: 5/10/2022.'));
      },
    );

    test(
      'getText returns correct translation for message with custom formatted DateTime placeholder',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Message created: {date}.',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [DateTime(2022, 5, 10, 12, 0)],
          {
            "@stringKey": {
              "placeholders": {
                "date": {
                  "type": "DateTime",
                  "format": "EEE, M/d/y",
                  "isCustomDateFormat": "true",
                },
              },
            },
          },
          {},
        );

        expect(response, equals('Message created: Tue, 5/10/2022.'));
      },
    );

    test(
      'getText returns correct translation for message with multi-formatted DateTime placeholder',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Message created: {date}.',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [DateTime(2022, 5, 10, 12, 15)],
          {
            "@stringKey": {
              "placeholders": {
                "date": {"type": "DateTime", "format": "yMd+Hm"},
              },
            },
          },
          {},
        );

        expect(response, equals('Message created: 5/10/2022 12:15.'));
      },
    );

    test(
      'getText returns correct translation for message with formatted DateTime placeholder and locale-specific metadata',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Message created: {date}.',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [DateTime(2022, 5, 10, 12, 15)],
          {
            "@stringKey": {
              "placeholders": {
                "date": {"type": "DateTime", "format": "yMd"},
              },
            },
          },
          {
            "de": {
              "date": {"format": "yMd"},
            },
            "en_US": {
              "date": {"format": "yMEd"},
            },
          },
        );

        expect(response, equals('Message created: Tue, 5/10/2022.'));
      },
    );

    test(
      'getText returns correct translation for message with formatted number placeholder',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(key: 'stringKey', value: 'Messages: {number}.'),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [1250000],
          {
            "@stringKey": {
              "placeholders": {
                "number": {"type": "num", "format": "compactLong"},
              },
            },
          },
          {},
        );

        expect(response, equals('Messages: 1.25 million.'));
      },
    );

    test(
      'getText returns correct translation for message with decimal-digits formatted number placeholder',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(key: 'stringKey', value: 'Total: {amount}.'),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [1250000],
          {
            "@stringKey": {
              "placeholders": {
                "amount": {
                  "type": "num",
                  "format": "currency",
                  "optionalParameters": {"decimalDigits": 2, "symbol": "\$"},
                },
              },
            },
          },
          {},
        );

        expect(response, equals('Total: \$1,250,000.00.'));
      },
    );

    test(
      'getText returns correct translation for message with decimal-digits formatted number placeholder and locale-specific metadata',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(key: 'stringKey', value: 'Total: {amount}.'),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [1250000],
          {
            "@stringKey": {
              "placeholders": {
                "amount": {
                  "type": "num",
                  "format": "currency",
                  "optionalParameters": {"decimalDigits": 2},
                },
              },
            },
          },
          {
            "de": {
              "amount": {
                "optionalParameters": {"decimalDigits": 6},
              },
            },
            "en_US": {
              "amount": {
                "optionalParameters": {"decimalDigits": 4},
              },
            },
          },
        );

        expect(response, equals('Total: USD1,250,000.0000.'));
      },
    );

    test(
      'getText returns correct translation for message with plural placeholder',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: '{count, plural, =1 {{count} item} other {{count} items}}',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [5],
          {
            "@stringKey": {
              "placeholders": {
                "count": {"type": "num"},
              },
            },
          },
          {},
        );

        expect(response, equals('5 items'));
      },
    );

    test(
      'getText returns correct translation for message with plural placeholder when are used all named plural forms',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value:
                  '{count, plural, one {{count} item} other {{count} items}}',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [1],
          {
            "@stringKey": {
              "placeholders": {
                "count": {"type": "num"},
              },
            },
          },
          {},
        );

        expect(response, equals('1 item'));
      },
    );

    test(
      'getText returns correct translation for message with formatted plural placeholder',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value:
                  '{count, plural, one {{count} item} other {{count} items}}',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [1250000],
          {
            "@stringKey": {
              "placeholders": {
                "count": {"type": "num", "format": "compactLong"},
              },
            },
          },
          {},
        );

        expect(response, equals('1.25 million items'));
      },
    );

    test(
      'getText returns correct translation for message with nested plural placeholders',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value:
                  '{count1, plural, one {{count2, plural, one {one-one: {count1} {count2}} other {one-other: {count1} {count2}}}} other {{count2, plural, one {other-one: {count1} {count2}} other {other-other: {count1} {count2}}}}}',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [5, 1],
          {
            "@stringKey": {
              {
                "placeholders": {
                  "count1": {"type": "num"},
                  "count2": {"type": "num"},
                },
              },
            },
          },
          {},
        );

        expect(response, equals('other-one: 5 1'));
      },
    );

    test(
      'getText returns correct translation for message with select placeholder',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value:
                  '{gender, select, male {Mr {name}} female {Mrs {name}} other {User {name}}}',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          ['female', 'Jane'],
          {
            "@stringKey": {
              "placeholders": {
                "gender": {"type": "String"},
                "name": {"type": "String"},
              },
            },
          },
          {},
        );

        expect(response, equals('Mrs Jane'));
      },
    );

    test(
      'getText returns correct translation for message with nested select placeholder',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value:
                  '{choice1, select, foo {{choice2, select, bar {foo bar} other {foo other}}} other {{choice2, select, bar {other bar} other {other other}}}}',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          ['foo', 'bar'],
          {
            "@stringKey": {
              "placeholders": {
                "choice1": {"type": "String"},
                "choice2": {"type": "String"},
              },
            },
          },
          {},
        );

        expect(response, equals('foo bar'));
      },
    );

    test('getText returns correct translation for compound message', () {
      final locale = 'en_US';
      final stringKey = 'stringKey';

      final mockedReleaseData = MockReleaseData();
      when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
        'en_US': {
          'stringKey': Label(
            key: 'stringKey',
            value:
                'The {gender, select, male {Mr {name}} female {Mrs {name}} other {User {name}}} has {count, plural, =1 {{count} apple} other {{count} apples}} and {amount} in pocket.',
          ),
        },
      });
      SdkData.releaseData = mockedReleaseData;

      final response = LocalizelyGenL10n.getText(
        locale,
        stringKey,
        ['male', 'John', 3, 234.5],
        {
          "@stringKey": {
            "placeholders": {
              "gender": {"type": "String"},
              "name": {"type": "String"},
              "count": {"type": "int"},
              "amount": {
                "type": "num",
                "format": "currency",
                "optionalParameters": {"decimalDigits": 2, "symbol": "\$"},
              },
            },
          },
        },
        {},
      );

      expect(
        response,
        equals('The Mr John has 3 apples and \$234.50 in pocket.'),
      );
    });

    test(
      'getText returns correct translation for message with argument-expression placeholder when type is date',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Current date: {currDate, date, ::yMd}',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [DateTime(2025, 2, 27, 14, 30)],
          {
            "@stringKey": {
              "placeholders": {
                "currDate": {"type": "DateTime"},
              },
            },
          },
          {},
        );

        expect(response, equals('Current date: 2/27/2025'));
      },
    );

    test(
      'getText returns correct translation for message with argument-expression placeholder when type is time',
      () {
        final locale = 'en_US';
        final stringKey = 'stringKey';

        final mockedReleaseData = MockReleaseData();
        when(mockedReleaseData.data).thenReturn(<String, Map<String, Label>>{
          'en_US': {
            'stringKey': Label(
              key: 'stringKey',
              value: 'Current date: {currDate, time, ::yMd}',
            ),
          },
        });
        SdkData.releaseData = mockedReleaseData;

        final response = LocalizelyGenL10n.getText(
          locale,
          stringKey,
          [DateTime(2025, 2, 27, 14, 30)],
          {
            "@stringKey": {
              "placeholders": {
                "currDate": {"type": "DateTime"},
              },
            },
          },
          {},
        );

        expect(response, equals('Current date: 2/27/2025'));
      },
    );
  });
}
