import 'package:test/test.dart';
import 'package:intl/intl.dart';

import 'package:localizely_sdk/src/ota/model/label.dart';

void main() {
  setUp(() {
    Intl.defaultLocale =
        'en'; // `getTranslation` method may use `Intl` lib for message processing (e.g. plural).
  });

  group('Label instantiation', () {
    test(
      'Test instantiation with constructor when named args are not passed',
      () {
        var label = Label();

        expect(label.key, isNull);
        expect(label.value, isNull);
      },
    );

    test('Test instantiation with constructor when named args are passed', () {
      var label = Label(key: 'key', value: 'value');

      expect(label.key, equals('key'));
      expect(label.value, equals('value'));
    });

    test(
      'Test instantiation with named constructor when json arg is empty',
      () {
        var label = Label.fromJson({});

        expect(label.key, isNull);
        expect(label.value, isNull);
      },
    );

    test(
      'Test instantiation with named constructor when json arg has partial data',
      () {
        var label = Label.fromJson({'key': 'key'});

        expect(label.key, equals('key'));
        expect(label.value, isNull);
      },
    );

    test(
      'Test instantiation with named constructor when json arg has all data',
      () {
        var label = Label.fromJson({'key': 'key', 'value': 'value'});

        expect(label.key, equals('key'));
        expect(label.value, equals('value'));
      },
    );

    test(
      'Test instantiation with named constructor when json arg has additional data',
      () {
        var label = Label.fromJson({
          'key': 'key',
          'value': 'value',
          'newData': 'new data',
        });

        expect(label.key, equals('key'));
        expect(label.value, equals('value'));
      },
    );
  });

  group('Label literal translation', () {
    test('Test label literal translation when value is empty string', () {
      var label = Label(key: 'key', value: '');

      expect(label.getTranslation({}), isEmpty);
    });

    test('Test label literal translation when value is blank', () {
      var label = Label(key: 'labelKey', value: ' ');

      expect(label.getTranslation({}), equals(' '));
    });

    test('Test label literal translation when value is plain text', () {
      var label = Label(key: 'labelKey', value: 'plain text');

      expect(label.getTranslation({}), equals('plain text'));
    });

    test(
      'Test label literal translation when value is plain text which contains special chars',
      () {
        var label = Label(
          key: 'labelKey',
          value: 'chars: !@#\$%^&*()_+=-\\[];~`,.<>?:"\'',
        );

        expect(
          label.getTranslation({}),
          equals('chars: !@#\$%^&*()_+=-\\[];~`,.<>?:"\''),
        );
      },
    );

    test(
      'Test label literal translation when value contains curly braces which are not indicating placeholder',
      () {
        var label = Label(key: 'key', value: '}{');

        expect(label.getTranslation({}), equals('}{'));
      },
    );

    test('Test label literal translation when value contains a tag', () {
      var label = Label(
        key: 'key',
        value: 'Literal message with a <b>tag</b>.',
      );

      expect(
        label.getTranslation({}),
        equals('Literal message with a <b>tag</b>.'),
      );
    });

    test(
      'Test label literal translation when value contains few different tags',
      () {
        var label = Label(
          key: 'key',
          value: '<i>Literal message</i> with a <br> <b>tag</b>.',
        );

        expect(
          label.getTranslation({}),
          equals('<i>Literal message</i> with a <br> <b>tag</b>.'),
        );
      },
    );

    test(
      'Test label literal translation when value contains content wrapped with tag',
      () {
        var label = Label(
          key: 'key',
          value: '<p>Literal message with a <b>tag</b>.</p>',
        );

        expect(
          label.getTranslation({}),
          equals('<p>Literal message with a <b>tag</b>.</p>'),
        );
      },
    );

    test(
      'Test label literal translation when value contains a less-than sign',
      () {
        var label = Label(key: 'key', value: 'Literal message with < sign');

        expect(label.getTranslation({}), equals('Literal message with < sign'));
      },
    );

    test(
      'Test label literal translation when value contains a greater-than sign',
      () {
        var label = Label(key: 'key', value: 'Literal message with > sign');

        expect(label.getTranslation({}), equals('Literal message with > sign'));
      },
    );

    test(
      'Test label literal translation when value contains a simple json string',
      () {
        var label = Label(
          key: 'key',
          value: '{ "firstName": "John", "lastName": "Doe" }',
        );

        expect(
          label.getTranslation({}),
          equals('{ "firstName": "John", "lastName": "Doe" }'),
        );
      },
    );

    test(
      'Test label literal translation when value contains a nested json string',
      () {
        var label = Label(
          key: 'key',
          value:
              '{ "firstName": "John", "lastName": "Doe", "address": { "street": "Some street 123", "city": "Some city" } }',
        );

        expect(
          label.getTranslation({}),
          equals(
            '{ "firstName": "John", "lastName": "Doe", "address": { "street": "Some street 123", "city": "Some city" } }',
          ),
        );
      },
    );

    test(
      'Test label literal translation when value contains a complex json string',
      () {
        var label = Label(
          key: 'key',
          value:
              '{ "firstName": "John", "lastName": "Doe", "address": { "street": "Some street 123", "city": "Some city" }, "skills": [ { "name": "programming" }, { "name": "design" } ] }',
        );

        expect(
          label.getTranslation({}),
          equals(
            '{ "firstName": "John", "lastName": "Doe", "address": { "street": "Some street 123", "city": "Some city" }, "skills": [ { "name": "programming" }, { "name": "design" } ] }',
          ),
        );
      },
    );

    test(
      'Test label literal translation when value contains a json string with special chars',
      () {
        var label = Label(
          key: 'key',
          value:
              '{ "special_chars": "abc !@#\$%^&*()_+-=`~[]{};\'\\:"|,./<>?*ÄäÖöÜüẞ你好أهلا" }',
        );

        expect(
          label.getTranslation({}),
          equals(
            '{ "special_chars": "abc !@#\$%^&*()_+-=`~[]{};\'\\:"|,./<>?*ÄäÖöÜüẞ你好أهلا" }',
          ),
        );
      },
    );
  });

  group('Label argument translation', () {
    test(
      'Test label argument translation when value contains just placeholder',
      () {
        var label = Label(key: 'key', value: '{placeholder}');

        expect(
          label.getTranslation({'placeholder': 'Some value'}),
          equals('Some value'),
        );
      },
    );

    test(
      'Test label argument translation when value contains plain text and placeholder',
      () {
        var label = Label(key: 'key', value: 'Hi {name}!');

        expect(label.getTranslation({'name': 'John'}), equals('Hi John!'));
      },
    );

    test(
      'Test label argument translation when value contains plain text and few placeholders',
      () {
        var label = Label(
          key: 'key',
          value: 'My name is {lastName}, {firstName} {lastName}!',
        );

        expect(
          label.getTranslation({'lastName': 'Bond', 'firstName': 'James'}),
          equals('My name is Bond, James Bond!'),
        );
      },
    );

    test(
      'Test label argument translation when value contains special chars and few placeholders',
      () {
        var label = Label(
          key: 'key',
          value:
              'chars: !@#\$%^&*()_+=-\\[];~`,.<>?:"\' {first} {second} {third}',
        );

        expect(
          label.getTranslation({
            'third': 'third-val',
            'second': 'second-val',
            'first': 'first-val',
          }),
          equals(
            'chars: !@#\$%^&*()_+=-\\[];~`,.<>?:"\' first-val second-val third-val',
          ),
        );
      },
    );

    test(
      'Test label argument translation when value contains placeholder and curly braces which are not indicating placeholder',
      () {
        var label = Label(key: 'key', value: '{placeholder} }{');

        expect(
          label.getTranslation({'placeholder': 'Some value'}),
          equals('Some value }{'),
        );
      },
    );

    test(
      'Test label argument translation when value contains placeholder and a tag',
      () {
        var label = Label(
          key: 'key',
          value: 'Argument message with {placeholder} and <b>tag</b>',
        );

        expect(
          label.getTranslation({'placeholder': 'Some value'}),
          equals('Argument message with Some value and <b>tag</b>'),
        );
      },
    );

    test(
      'Test label argument translation when value contains placeholder and few different tags',
      () {
        var label = Label(
          key: 'key',
          value:
              'Argument message with <br><i>{placeholder}</i> and <b>tag</b>',
        );

        expect(
          label.getTranslation({'placeholder': 'Some value'}),
          equals('Argument message with <br><i>Some value</i> and <b>tag</b>'),
        );
      },
    );

    test(
      'Test label argument translation when value contains placeholder and is wrapped with tag',
      () {
        var label = Label(
          key: 'key',
          value:
              '<p>Argument message with <br><i>{placeholder}</i> and <b>tag</b></p>',
        );

        expect(
          label.getTranslation({'placeholder': 'Some value'}),
          equals(
            '<p>Argument message with <br><i>Some value</i> and <b>tag</b></p>',
          ),
        );
      },
    );

    test(
      'Test label argument translation when value contains placeholder and less-than sign',
      () {
        var label = Label(
          key: 'key',
          value: 'Argument message with {placeholder} and < sign',
        );

        expect(
          label.getTranslation({'placeholder': 'Some value'}),
          equals('Argument message with Some value and < sign'),
        );
      },
    );

    test(
      'Test label argument translation when value contains placeholder and greater-than sign',
      () {
        var label = Label(
          key: 'key',
          value: 'Argument message with {placeholder} and > sign',
        );

        expect(
          label.getTranslation({'placeholder': 'Some value'}),
          equals('Argument message with Some value and > sign'),
        );
      },
    );

    test(
      'Test label argument translation when value contains a simple json string',
      () {
        var label = Label(
          key: 'key',
          value:
              'Argument message: {name} - { "firstName": "John", "lastName": "Doe" }',
        );

        expect(
          label.getTranslation({'name': 'John'}),
          equals(
            'Argument message: John - { "firstName": "John", "lastName": "Doe" }',
          ),
        );
      },
    );

    test(
      'Test label argument translation when value contains a nested json string',
      () {
        var label = Label(
          key: 'key',
          value:
              'Argument message: {name} - { "firstName": "John", "lastName": "Doe", "address": { "street": "Some street 123", "city": "Some city" } }',
        );

        expect(
          label.getTranslation({'name': 'John'}),
          equals(
            'Argument message: John - { "firstName": "John", "lastName": "Doe", "address": { "street": "Some street 123", "city": "Some city" } }',
          ),
        );
      },
    );

    test(
      'Test label argument translation when value contains a complex json string',
      () {
        var label = Label(
          key: 'key',
          value:
              'Argument message: {name} - { "firstName": "John", "lastName": "Doe", "address": { "street": "Some street 123", "city": "Some city" }, "skills": [ { "name": "programming" }, { "name": "design" } ] }',
        );

        expect(
          label.getTranslation({'name': 'John'}),
          equals(
            'Argument message: John - { "firstName": "John", "lastName": "Doe", "address": { "street": "Some street 123", "city": "Some city" }, "skills": [ { "name": "programming" }, { "name": "design" } ] }',
          ),
        );
      },
    );

    test(
      'Test label argument translation when value contains a json string with special chars',
      () {
        var label = Label(
          key: 'key',
          value:
              'Argument message: {name} - { "special_chars": "abc !@#\$%^&*()_+-=`~[]{};\'\\:"|,./<>?*ÄäÖöÜüẞ你好أهلا" }',
        );

        expect(
          label.getTranslation({'name': 'John'}),
          equals(
            'Argument message: John - { "special_chars": "abc !@#\$%^&*()_+-=`~[]{};\'\\:"|,./<>?*ÄäÖöÜüẞ你好أهلا" }',
          ),
        );
      },
    );

    test(
      'Test label argument translation when value contains a json string with placeholders',
      () {
        var label = Label(
          key: 'key',
          value:
              '{ "name": "{name}", "address": { "street": "{street}", "city": "{city}" } }',
        );

        expect(
          label.getTranslation({
            'name': 'John',
            'street': 'Some street 123',
            'city': 'Some city',
          }),
          equals(
            '{ "name": "John", "address": { "street": "Some street 123", "city": "Some city" } }',
          ),
        );
      },
    );
  });

  group('Label plural translation', () {
    test(
      'Test label plural translation when value contains empty plural forms',
      () {
        var label = Label(
          key: 'labelKey',
          value:
              '{howMany, plural, zero {} one {} two {} few {} many {} other {}}',
        );

        // Some plural forms are superfluous here (testing parsing)
        expect(label.getTranslation({'howMany': 1}), isEmpty);
        expect(label.getTranslation({'howMany': 5}), isEmpty);
      },
    );

    test(
      'Test label plural translation when value contains plural forms with plain text',
      () {
        var label = Label(
          key: 'labelKey',
          value: '{howMany, plural, one {one-pf} other {other-pf}}',
        );

        expect(label.getTranslation({'howMany': 1}), equals('one-pf'));
        expect(label.getTranslation({'howMany': 5}), equals('other-pf'));
      },
    );

    test(
      'Test label plural translation when value contains plural forms with placeholder',
      () {
        var label = Label(
          key: 'labelKey',
          value:
              '{howMany, plural, one {one-pf: {placeholder}} other {other-pf: {placeholder}}}',
        );

        expect(
          label.getTranslation({'howMany': 1, 'placeholder': 'Some value'}),
          equals('one-pf: Some value'),
        );
        expect(
          label.getTranslation({'howMany': 2, 'placeholder': 'Some value'}),
          equals('other-pf: Some value'),
        );
      },
    );

    test(
      'Test label plural translation when value contains plural forms with few placeholders',
      () {
        var label = Label(
          key: 'labelKey',
          value:
              '{howMany, plural, one {one-pf: {howMany} {first} {second}} other {other-pf: {howMany} {first} {second}}}',
        );

        expect(
          label.getTranslation({
            'howMany': 1,
            'first': 'first-val',
            'second': 'second-val',
          }),
          equals('one-pf: 1 first-val second-val'),
        );
        expect(
          label.getTranslation({
            'howMany': 2,
            'first': 'first-val',
            'second': 'second-val',
          }),
          equals('other-pf: 2 first-val second-val'),
        );
      },
    );

    test(
      'Test label plural translation when value contains plural forms with special chars and few placeholders',
      () {
        var label = Label(
          key: 'labelKey',
          value:
              '{howMany, plural, one {one-pf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' {howMany} {first}} other {other-pf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' {howMany} {first}}}',
        );

        // `<` char is not used in the test - cause parsing error
        expect(
          label.getTranslation({'howMany': 1, 'first': 'first-val'}),
          equals('one-pf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' 1 first-val'),
        );
        expect(
          label.getTranslation({'howMany': 2, 'first': 'first-val'}),
          equals('other-pf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' 2 first-val'),
        );
      },
    );

    test(
      'Test label plural translation when value contains plural forms with a tag (unsupported)',
      () {
        var label = Label(
          key: 'labelKey',
          value:
              '{howMany, plural, one {one-pf: <b>tag</b>} other {other-pf: <b>tag</b>}}',
        );

        expect(
          label.getTranslation({'howMany': 1}),
          equals('one-pf: <b>tag</b>'),
        );
        expect(
          label.getTranslation({'howMany': 2}),
          equals('other-pf: <b>tag</b>'),
        );
      },
      skip: true,
    );

    test(
      'Test label plural translation when value contains plural forms with less-than sign (unsupported)',
      () {
        var label = Label(
          key: 'labelKey',
          value: '{howMany, plural, one {one-pf: <} other {other-pf: <}}',
        );

        expect(label.getTranslation({'howMany': 1}), equals('one-pf: <'));
        expect(label.getTranslation({'howMany': 2}), equals('other-pf: <'));
      },
      skip: true,
    );

    test(
      'Test label plural translation when value contains plural forms with greater-than sign',
      () {
        var label = Label(
          key: 'labelKey',
          value: '{howMany, plural, one {one-pf: >} other {other-pf: >}}',
        );

        expect(label.getTranslation({'howMany': 1}), equals('one-pf: >'));
        expect(label.getTranslation({'howMany': 2}), equals('other-pf: >'));
      },
    );

    test(
      'Test label plural translation when value contains a simple json string (unsupported)',
      () {
        var label = Label(
          key: 'key',
          value:
              '{count, plural, one {one message { "firstName": "John", "lastName": "Doe" }} other {other message { "firstName": "John", "lastName": "Doe" }}}',
        );

        expect(
          label.getTranslation({'count': 1}),
          equals('one message { "firstName": "John", "lastName": "Doe" }'),
        );
        expect(
          label.getTranslation({'count': 5}),
          equals('other message { "firstName": "John", "lastName": "Doe" }'),
        );
      },
      skip: true,
    );
  });

  group('Label gender translation', () {
    test(
      'Test label gender translation when value contains empty gender forms',
      () {
        var label = Label(
          key: 'key',
          value: '{gender, select, male {} female {} other {}}',
        );

        expect(label.getTranslation({'gender': 'male'}), isEmpty);
        expect(label.getTranslation({'gender': 'female'}), isEmpty);
        expect(label.getTranslation({'gender': 'other'}), isEmpty);
      },
    );

    test(
      'Test label gender translation when value contains gender forms with plain text',
      () {
        var label = Label(
          key: 'key',
          value:
              '{gender, select, male {male-gf} female {female-gf} other {other-gf}}',
        );

        expect(label.getTranslation({'gender': 'male'}), equals('male-gf'));
        expect(label.getTranslation({'gender': 'female'}), equals('female-gf'));
        expect(label.getTranslation({'gender': 'other'}), equals('other-gf'));
      },
    );

    test(
      'Test label gender translation when value contains gender forms with plain text and placeholder',
      () {
        var label = Label(
          key: 'key',
          value:
              '{gender, select, male {male-gf: {placeholder}} female {female-gf: {placeholder}} other {other-gf: {placeholder}}}',
        );

        expect(
          label.getTranslation({'gender': 'male', 'placeholder': 'Some value'}),
          equals('male-gf: Some value'),
        );
        expect(
          label.getTranslation({
            'gender': 'female',
            'placeholder': 'Some value',
          }),
          equals('female-gf: Some value'),
        );
        expect(
          label.getTranslation({
            'gender': 'other',
            'placeholder': 'Some value',
          }),
          equals('other-gf: Some value'),
        );
      },
    );

    test(
      'Test label gender translation when value contains gender forms with plain text and few placeholders',
      () {
        var label = Label(
          key: 'key',
          value:
              '{gender, select, male {male-gf: {gender} {first} {second}} female {female-gf: {gender} {first} {second}} other {other-gf: {gender} {first} {second}}}',
        );

        expect(
          label.getTranslation({
            'gender': 'male',
            'first': 'first-val',
            'second': 'second-val',
          }),
          equals('male-gf: male first-val second-val'),
        );
        expect(
          label.getTranslation({
            'gender': 'female',
            'first': 'first-val',
            'second': 'second-val',
          }),
          equals('female-gf: female first-val second-val'),
        );
        expect(
          label.getTranslation({
            'gender': 'other',
            'first': 'first-val',
            'second': 'second-val',
          }),
          equals('other-gf: other first-val second-val'),
        );
      },
    );

    test(
      'Test label gender translation when value contains gender forms with special chars and few placeholders',
      () {
        var label = Label(
          key: 'key',
          value:
              '{gender, select, male {male-gf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' {gender} {first}} female {female-gf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' {gender} {first}} other {other-gf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' {gender} {first}}}',
        );

        // `<` char is not used in the test - cause parsing error
        expect(
          label.getTranslation({'gender': 'male', 'first': 'first-val'}),
          equals(
            'male-gf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' male first-val',
          ),
        );
        expect(
          label.getTranslation({'gender': 'female', 'first': 'first-val'}),
          equals(
            'female-gf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' female first-val',
          ),
        );
        expect(
          label.getTranslation({'gender': 'other', 'first': 'first-val'}),
          equals(
            'other-gf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' other first-val',
          ),
        );
      },
    );

    test(
      'Test label gender translation when value contains gender forms with a tag (unsupported)',
      () {
        var label = Label(
          key: 'key',
          value:
              '{gender, select, male {male-gf: <b>tag</b>} female {female-gf: <b>tag</b>} other {other-gf: <b>tag</b>}}',
        );

        expect(
          label.getTranslation({'gender': 'male'}),
          equals('male-gf: <b>tag</b>'),
        );
        expect(
          label.getTranslation({'gender': 'female'}),
          equals('female-gf: <b>tag</b>'),
        );
        expect(
          label.getTranslation({'gender': 'other'}),
          equals('other-gf: <b>tag</b>'),
        );
      },
      skip: true,
    );

    test(
      'Test label gender translation when value contains gender forms with less-than sign (unsupported)',
      () {
        var label = Label(
          key: 'key',
          value:
              '{gender, select, male {male-gf: <} female {female-gf: <} other {other-gf: <}}',
        );

        expect(label.getTranslation({'gender': 'male'}), equals('male-gf: <'));
        expect(
          label.getTranslation({'gender': 'female'}),
          equals('female-gf: <'),
        );
        expect(
          label.getTranslation({'gender': 'other'}),
          equals('other-gf: <'),
        );
      },
      skip: true,
    );

    test(
      'Test label gender translation when value contains gender forms with greater-than sign',
      () {
        var label = Label(
          key: 'key',
          value:
              '{gender, select, male {male-gf: >} female {female-gf: >} other {other-gf: >}}',
        );

        expect(label.getTranslation({'gender': 'male'}), equals('male-gf: >'));
        expect(
          label.getTranslation({'gender': 'female'}),
          equals('female-gf: >'),
        );
        expect(
          label.getTranslation({'gender': 'other'}),
          equals('other-gf: >'),
        );
      },
    );

    test(
      'Test label gender translation when value contains a simple json string (unsupported)',
      () {
        var label = Label(
          key: 'key',
          value:
              '{gender, select, male {male { "firstName": "John", "lastName": "Doe" }} female {female { "firstName": "John", "lastName": "Doe" }} other {other { "firstName": "John", "lastName": "Doe" }}}',
        );

        expect(
          label.getTranslation({'gender': 'male'}),
          equals('male { "firstName": "John", "lastName": "Doe" }'),
        );
        expect(
          label.getTranslation({'gender': 'female'}),
          equals('female { "firstName": "John", "lastName": "Doe" }'),
        );
        expect(
          label.getTranslation({'gender': 'other'}),
          equals('other { "firstName": "John", "lastName": "Doe" }'),
        );
      },
      skip: true,
    );
  });

  group('Label select translation', () {
    test(
      'Test label select translation when value contains empty select forms',
      () {
        var label = Label(
          key: 'key',
          value: '{choice, select, foo {} bar {} baz {} other{}}',
        );

        expect(label.getTranslation({'choice': 'foo'}), isEmpty);
        expect(label.getTranslation({'choice': 'bar'}), isEmpty);
        expect(label.getTranslation({'choice': 'baz'}), isEmpty);
        expect(label.getTranslation({'choice': 'ups'}), isEmpty);
      },
    );

    test(
      'Test label select translation when value contains select forms with plain text',
      () {
        var label = Label(
          key: 'key',
          value:
              '{choice, select, foo {foo-sf} bar {bar-sf} baz {baz-sf} other{other-sf}}',
        );

        expect(label.getTranslation({'choice': 'foo'}), equals('foo-sf'));
        expect(label.getTranslation({'choice': 'bar'}), equals('bar-sf'));
        expect(label.getTranslation({'choice': 'baz'}), equals('baz-sf'));
        expect(label.getTranslation({'choice': 'ups'}), equals('other-sf'));
      },
    );

    test(
      'Test label select translation when value contains select forms with plain text and placeholder',
      () {
        var label = Label(
          key: 'key',
          value:
              '{choice, select, foo {foo-sf: {placeholder}} bar {bar-sf: {placeholder}} baz {baz-sf: {placeholder}} other{other-sf: {placeholder}}}',
        );

        expect(
          label.getTranslation({'choice': 'foo', 'placeholder': 'Some value'}),
          equals('foo-sf: Some value'),
        );
        expect(
          label.getTranslation({'choice': 'bar', 'placeholder': 'Some value'}),
          equals('bar-sf: Some value'),
        );
        expect(
          label.getTranslation({'choice': 'baz', 'placeholder': 'Some value'}),
          equals('baz-sf: Some value'),
        );
        expect(
          label.getTranslation({'choice': 'ups', 'placeholder': 'Some value'}),
          equals('other-sf: Some value'),
        );
      },
    );

    test(
      'Test label select translation when value contains select forms with plain text and few placeholders',
      () {
        var label = Label(
          key: 'key',
          value:
              '{choice, select, foo {foo-sf: {choice} {first} {second}} bar {bar-sf: {choice} {first} {second}} baz {baz-sf: {choice} {first} {second}} other{other-sf: {choice} {first} {second}}}',
        );

        expect(
          label.getTranslation({
            'choice': 'foo',
            'first': 'first-val',
            'second': 'second-val',
          }),
          equals('foo-sf: foo first-val second-val'),
        );
        expect(
          label.getTranslation({
            'choice': 'bar',
            'first': 'first-val',
            'second': 'second-val',
          }),
          equals('bar-sf: bar first-val second-val'),
        );
        expect(
          label.getTranslation({
            'choice': 'baz',
            'first': 'first-val',
            'second': 'second-val',
          }),
          equals('baz-sf: baz first-val second-val'),
        );
        expect(
          label.getTranslation({
            'choice': 'ups',
            'first': 'first-val',
            'second': 'second-val',
          }),
          equals('other-sf: ups first-val second-val'),
        );
      },
    );

    test(
      'Test label select translation when value contains select forms with special chars and few placeholders',
      () {
        var label = Label(
          key: 'key',
          value:
              '{choice, select, foo {foo-sf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' {choice} {first}} bar {bar-sf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' {choice} {first}} baz {baz-sf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' {choice} {first}} other{other-sf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' {choice} {first}}}',
        );

        // `<` char is not used in the test - cause parsing error
        expect(
          label.getTranslation({'choice': 'foo', 'first': 'first-val'}),
          equals('foo-sf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' foo first-val'),
        );
        expect(
          label.getTranslation({'choice': 'bar', 'first': 'first-val'}),
          equals('bar-sf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' bar first-val'),
        );
        expect(
          label.getTranslation({'choice': 'baz', 'first': 'first-val'}),
          equals('baz-sf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' baz first-val'),
        );
        expect(
          label.getTranslation({'choice': 'ups', 'first': 'first-val'}),
          equals(
            'other-sf-chars: !@#\$%^&*()_+=-\\[];~`,.>?:"\' ups first-val',
          ),
        );
      },
    );

    test(
      'Test label select translation when value contains select forms with a tag (unsupported)',
      () {
        var label = Label(
          key: 'key',
          value:
              '{choice, select, foo {foo-sf: <b>tag</b>} bar {bar-sf: <b>tag</b>} baz {baz-sf: <b>tag</b>} other {other-sf: <b>tag</b>}}',
        );

        expect(
          label.getTranslation({'choice': 'foo'}),
          equals('foo-sf: <b>tag</b>'),
        );
        expect(
          label.getTranslation({'choice': 'bar'}),
          equals('bar-sf: <b>tag</b>'),
        );
        expect(
          label.getTranslation({'choice': 'baz'}),
          equals('baz-sf: <b>tag</b>'),
        );
        expect(
          label.getTranslation({'choice': 'ups'}),
          equals('other-sf: <b>tag</b>'),
        );
      },
      skip: true,
    );

    test(
      'Test label select translation when value contains select forms with less-than sign (unsupported)',
      () {
        var label = Label(
          key: 'key',
          value:
              '{choice, select, foo {foo-sf: <} bar {bar-sf: <} baz {baz-sf: <} other {other-sf: <}}',
        );

        expect(label.getTranslation({'choice': 'foo'}), equals('foo-sf: <'));
        expect(label.getTranslation({'choice': 'bar'}), equals('bar-sf: <'));
        expect(label.getTranslation({'choice': 'baz'}), equals('baz-sf: <'));
        expect(label.getTranslation({'choice': 'ups'}), equals('other-sf: <'));
      },
      skip: true,
    );

    test(
      'Test label select translation when value contains select forms with greater-than sign',
      () {
        var label = Label(
          key: 'key',
          value:
              '{choice, select, foo {foo-sf: >} bar {bar-sf: >} baz {baz-sf: >} other {other-sf: >}}',
        );

        expect(label.getTranslation({'choice': 'foo'}), equals('foo-sf: >'));
        expect(label.getTranslation({'choice': 'bar'}), equals('bar-sf: >'));
        expect(label.getTranslation({'choice': 'baz'}), equals('baz-sf: >'));
        expect(label.getTranslation({'choice': 'ups'}), equals('other-sf: >'));
      },
    );

    test(
      'Test label select translation when value contains a simple json string (unsupported)',
      () {
        var label = Label(
          key: 'key',
          value:
              '{choice, select, foo {foo message { "firstName": "John", "lastName": "Doe" }} bar {bar message { "firstName": "John", "lastName": "Doe" }} other {other message { "firstName": "John", "lastName": "Doe" }}}',
        );

        expect(
          label.getTranslation({'choice': 'foo'}),
          equals('foo message { "firstName": "John", "lastName": "Doe" }'),
        );
        expect(
          label.getTranslation({'choice': 'bar'}),
          equals('bar message { "firstName": "John", "lastName": "Doe" }'),
        );
        expect(
          label.getTranslation({'choice': 'other'}),
          equals('other message { "firstName": "John", "lastName": "Doe" }'),
        );
      },
      skip: true,
    );
  });

  group('Label compound translation', () {
    test(
      'Test label compound translation when value consists of literal and plural messages',
      () {
        var label = Label(
          key: 'key',
          value:
              'John has {count, plural, one {{count} apple} other {{count} apples}}.',
        );

        expect(label.getTranslation({'count': 1}), equals('John has 1 apple.'));
        expect(
          label.getTranslation({'count': 5}),
          equals('John has 5 apples.'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of literal and plural messages and content contains a tag',
      () {
        var label = Label(
          key: 'key',
          value:
              '<b>John</b> has {count, plural, one {{count} apple} other {{count} apples}}.',
        );

        expect(
          label.getTranslation({'count': 1}),
          equals('<b>John</b> has 1 apple.'),
        );
        expect(
          label.getTranslation({'count': 5}),
          equals('<b>John</b> has 5 apples.'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of literal and plural messages and content is wrapped with tag',
      () {
        var label = Label(
          key: 'key',
          value:
              '<p><b>John</b> has {count, plural, one {{count} apple} other {{count} apples}}.</p>',
        );

        expect(
          label.getTranslation({'count': 1}),
          equals('<p><b>John</b> has 1 apple.</p>'),
        );
        expect(
          label.getTranslation({'count': 5}),
          equals('<p><b>John</b> has 5 apples.</p>'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of literal and gender messages',
      () {
        var label = Label(
          key: 'key',
          value:
              'Welcome {gender, select, male {Mr {name}} female {Mrs {name}} other {dear {name}}}.',
        );

        expect(
          label.getTranslation({'gender': 'male', 'name': 'John'}),
          equals('Welcome Mr John.'),
        );
        expect(
          label.getTranslation({'gender': 'female', 'name': 'Jane'}),
          equals('Welcome Mrs Jane.'),
        );
        expect(
          label.getTranslation({'gender': 'other', 'name': 'Alex'}),
          equals('Welcome dear Alex.'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of literal and gender messages and content contains a tag',
      () {
        var label = Label(
          key: 'key',
          value:
              'Welcome <b>{gender, select, male {Mr {name}} female {Mrs {name}} other {dear {name}}}</b>.',
        );

        expect(
          label.getTranslation({'gender': 'male', 'name': 'John'}),
          equals('Welcome <b>Mr John</b>.'),
        );
        expect(
          label.getTranslation({'gender': 'female', 'name': 'Jane'}),
          equals('Welcome <b>Mrs Jane</b>.'),
        );
        expect(
          label.getTranslation({'gender': 'other', 'name': 'Alex'}),
          equals('Welcome <b>dear Alex</b>.'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of literal and gender messages and content is wrapped with tag',
      () {
        var label = Label(
          key: 'key',
          value:
              '<p>Welcome <b>{gender, select, male {Mr {name}} female {Mrs {name}} other {dear {name}}}</b>.</p>',
        );

        expect(
          label.getTranslation({'gender': 'male', 'name': 'John'}),
          equals('<p>Welcome <b>Mr John</b>.</p>'),
        );
        expect(
          label.getTranslation({'gender': 'female', 'name': 'Jane'}),
          equals('<p>Welcome <b>Mrs Jane</b>.</p>'),
        );
        expect(
          label.getTranslation({'gender': 'other', 'name': 'Alex'}),
          equals('<p>Welcome <b>dear Alex</b>.</p>'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of literal and select messages',
      () {
        var label = Label(
          key: 'key',
          value:
              'The {choice, select, admin {admin {name}} owner {owner {name}} other {user {name}}}.',
        );

        expect(
          label.getTranslation({'choice': 'admin', 'name': 'Alex'}),
          equals('The admin Alex.'),
        );
        expect(
          label.getTranslation({'choice': 'owner', 'name': 'Alex'}),
          equals('The owner Alex.'),
        );
        expect(
          label.getTranslation({'choice': 'other', 'name': 'Alex'}),
          equals('The user Alex.'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of literal and select messages and content contains a tag',
      () {
        var label = Label(
          key: 'key',
          value:
              'The <b>{choice, select, admin {admin {name}} owner {owner {name}} other {user {name}}}</b>.',
        );

        expect(
          label.getTranslation({'choice': 'admin', 'name': 'Alex'}),
          equals('The <b>admin Alex</b>.'),
        );
        expect(
          label.getTranslation({'choice': 'owner', 'name': 'Alex'}),
          equals('The <b>owner Alex</b>.'),
        );
        expect(
          label.getTranslation({'choice': 'other', 'name': 'Alex'}),
          equals('The <b>user Alex</b>.'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of literal and select messages and content is wrapped with tag',
      () {
        var label = Label(
          key: 'key',
          value:
              '<p>The <b>{choice, select, admin {admin {name}} owner {owner {name}} other {user {name}}}</b>.</p>',
        );

        expect(
          label.getTranslation({'choice': 'admin', 'name': 'Alex'}),
          equals('<p>The <b>admin Alex</b>.</p>'),
        );
        expect(
          label.getTranslation({'choice': 'owner', 'name': 'Alex'}),
          equals('<p>The <b>owner Alex</b>.</p>'),
        );
        expect(
          label.getTranslation({'choice': 'other', 'name': 'Alex'}),
          equals('<p>The <b>user Alex</b>.</p>'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of argument and plural messages',
      () {
        var label = Label(
          key: 'key',
          value:
              '{name} has {count, plural, one {{count} apple} other {{count} apples}} in the bag.',
        );

        expect(
          label.getTranslation({'name': 'Alex', 'count': 1}),
          equals('Alex has 1 apple in the bag.'),
        );
        expect(
          label.getTranslation({'name': 'Alex', 'count': 5}),
          equals('Alex has 5 apples in the bag.'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of argument and plural messages and content contains a tag',
      () {
        var label = Label(
          key: 'key',
          value:
              '<b>{name}</b> has {count, plural, one {{count} apple} other {{count} apples}} in the bag.',
        );

        expect(
          label.getTranslation({'name': 'Alex', 'count': 1}),
          equals('<b>Alex</b> has 1 apple in the bag.'),
        );
        expect(
          label.getTranslation({'name': 'Alex', 'count': 5}),
          equals('<b>Alex</b> has 5 apples in the bag.'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of argument and plural messages and content is wrapped with tag',
      () {
        var label = Label(
          key: 'key',
          value:
              '<p><b>{name}</b> has {count, plural, one {{count} apple} other {{count} apples}} in the bag.</p>',
        );

        expect(
          label.getTranslation({'name': 'Alex', 'count': 1}),
          equals('<p><b>Alex</b> has 1 apple in the bag.</p>'),
        );
        expect(
          label.getTranslation({'name': 'Alex', 'count': 5}),
          equals('<p><b>Alex</b> has 5 apples in the bag.</p>'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of argument and gender messages',
      () {
        var label = Label(
          key: 'key',
          value:
              'The {gender, select, male {Mr {name}} female {Mrs {name}} other {dear {name}}} has the {device}.',
        );

        expect(
          label.getTranslation({
            'gender': 'male',
            'name': 'John',
            'device': 'radio',
          }),
          equals('The Mr John has the radio.'),
        );
        expect(
          label.getTranslation({
            'gender': 'female',
            'name': 'Jane',
            'device': 'radio',
          }),
          equals('The Mrs Jane has the radio.'),
        );
        expect(
          label.getTranslation({
            'gender': 'other',
            'name': 'Alex',
            'device': 'radio',
          }),
          equals('The dear Alex has the radio.'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of argument and gender messages and content contains a tag',
      () {
        var label = Label(
          key: 'key',
          value:
              'The {gender, select, male {Mr {name}} female {Mrs {name}} other {dear {name}}} has the <b>{device}</b>.',
        );

        expect(
          label.getTranslation({
            'gender': 'male',
            'name': 'John',
            'device': 'radio',
          }),
          equals('The Mr John has the <b>radio</b>.'),
        );
        expect(
          label.getTranslation({
            'gender': 'female',
            'name': 'Jane',
            'device': 'radio',
          }),
          equals('The Mrs Jane has the <b>radio</b>.'),
        );
        expect(
          label.getTranslation({
            'gender': 'other',
            'name': 'Alex',
            'device': 'radio',
          }),
          equals('The dear Alex has the <b>radio</b>.'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of argument and gender messages and content is wrapped with tag',
      () {
        var label = Label(
          key: 'key',
          value:
              '<p>The {gender, select, male {Mr {name}} female {Mrs {name}} other {dear {name}}} has the <b>{device}</b>.</p>',
        );

        expect(
          label.getTranslation({
            'gender': 'male',
            'name': 'John',
            'device': 'radio',
          }),
          equals('<p>The Mr John has the <b>radio</b>.</p>'),
        );
        expect(
          label.getTranslation({
            'gender': 'female',
            'name': 'Jane',
            'device': 'radio',
          }),
          equals('<p>The Mrs Jane has the <b>radio</b>.</p>'),
        );
        expect(
          label.getTranslation({
            'gender': 'other',
            'name': 'Alex',
            'device': 'radio',
          }),
          equals('<p>The dear Alex has the <b>radio</b>.</p>'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of argument and select messages',
      () {
        var label = Label(
          key: 'key',
          value:
              'The one {choice, select, coffee {{name} coffee} tea {{name} tea} other {{name} drink}} please for the {client}.',
        );

        expect(
          label.getTranslation({
            'choice': 'coffee',
            'name': 'espresso',
            'client': 'Alex',
          }),
          equals('The one espresso coffee please for the Alex.'),
        );
        expect(
          label.getTranslation({
            'choice': 'tea',
            'name': 'green',
            'client': 'Alex',
          }),
          equals('The one green tea please for the Alex.'),
        );
        expect(
          label.getTranslation({
            'choice': 'other',
            'name': 'juice',
            'client': 'Alex',
          }),
          equals('The one juice drink please for the Alex.'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of argument and select messages and content contains a tag',
      () {
        var label = Label(
          key: 'key',
          value:
              'The one {choice, select, coffee {{name} coffee} tea {{name} tea} other {{name} drink}} please for the <b>{client}</b>.',
        );

        expect(
          label.getTranslation({
            'choice': 'coffee',
            'name': 'espresso',
            'client': 'Alex',
          }),
          equals('The one espresso coffee please for the <b>Alex</b>.'),
        );
        expect(
          label.getTranslation({
            'choice': 'tea',
            'name': 'green',
            'client': 'Alex',
          }),
          equals('The one green tea please for the <b>Alex</b>.'),
        );
        expect(
          label.getTranslation({
            'choice': 'other',
            'name': 'juice',
            'client': 'Alex',
          }),
          equals('The one juice drink please for the <b>Alex</b>.'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of argument and select messages and content is wrapped with tag',
      () {
        var label = Label(
          key: 'key',
          value:
              '<p>The one {choice, select, coffee {{name} coffee} tea {{name} tea} other {{name} drink}} please for the <b>{client}</b>.</p>',
        );

        expect(
          label.getTranslation({
            'choice': 'coffee',
            'name': 'espresso',
            'client': 'Alex',
          }),
          equals('<p>The one espresso coffee please for the <b>Alex</b>.</p>'),
        );
        expect(
          label.getTranslation({
            'choice': 'tea',
            'name': 'green',
            'client': 'Alex',
          }),
          equals('<p>The one green tea please for the <b>Alex</b>.</p>'),
        );
        expect(
          label.getTranslation({
            'choice': 'other',
            'name': 'juice',
            'client': 'Alex',
          }),
          equals('<p>The one juice drink please for the <b>Alex</b>.</p>'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of plural and plural messages',
      () {
        var label = Label(
          key: 'key',
          value:
              '{count1, plural, one {p1 one.} other {p1 other.}}{count2, plural, one {p2 one.} other {p2 other.}}',
        );

        expect(
          label.getTranslation({'count1': 1, 'count2': 2}),
          equals('p1 one.p2 other.'),
        );
        expect(
          label.getTranslation({'count1': 0, 'count2': 0}),
          equals('p1 other.p2 other.'),
        );
        expect(
          label.getTranslation({'count1': 5, 'count2': 1}),
          equals('p1 other.p2 one.'),
        );
      },
    );

    test(
      'Test label compound translation when value consists of plural, literal and plural messages',
      () {
        var label = Label(
          key: 'key',
          value:
              '{count1, plural, one {p1 one} other {p1 other}} and {count2, plural, one {p2 one} other {p2 other}}',
        );

        expect(
          label.getTranslation({'count1': 1, 'count2': 2}),
          equals('p1 one and p2 other'),
        );
        expect(
          label.getTranslation({'count1': 0, 'count2': 0}),
          equals('p1 other and p2 other'),
        );
        expect(
          label.getTranslation({'count1': 5, 'count2': 1}),
          equals('p1 other and p2 one'),
        );
      },
    );

    test(
      'Test label compound translation when value contains a less-than sign',
      () {
        var label = Label(
          key: 'key',
          value:
              '{gender, select, male {Mr} female {Mrs} other {User}} {name} has < {count, plural, one {{count} apple} other {{count} apples}}.',
        );

        expect(
          label.getTranslation({'gender': 'male', 'name': 'John', 'count': 5}),
          equals('Mr John has < 5 apples.'),
        );
        expect(
          label.getTranslation({
            'gender': 'female',
            'name': 'Jane',
            'count': 1,
          }),
          equals('Mrs Jane has < 1 apple.'),
        );
        expect(
          label.getTranslation({
            'gender': 'bla',
            'name': 'Unknown',
            'count': 0,
          }),
          equals('User Unknown has < 0 apples.'),
        );
      },
    );

    test(
      'Test label compound translation when value contains a greater-than sign',
      () {
        var label = Label(
          key: 'key',
          value:
              '{gender, select, male {Mr} female {Mrs} other {User}} {name} has > {count, plural, one {{count} apple} other {{count} apples}}.',
        );

        expect(
          label.getTranslation({'gender': 'male', 'name': 'John', 'count': 5}),
          equals('Mr John has > 5 apples.'),
        );
        expect(
          label.getTranslation({
            'gender': 'female',
            'name': 'Jane',
            'count': 1,
          }),
          equals('Mrs Jane has > 1 apple.'),
        );
        expect(
          label.getTranslation({
            'gender': 'bla',
            'name': 'Unknown',
            'count': 0,
          }),
          equals('User Unknown has > 0 apples.'),
        );
      },
    );

    test(
      'Test label compound translation when value contains a simple json string (unsupported)',
      () {
        var label = Label(
          key: 'key',
          value:
              'The {gender, select, male {Mr} female {Mrs} other {User}} {name} ({choice, select, ADMIN {Admin} MANAGER {Manager} other {User}} with {count, plural, one {{count} badge} other {{count} badges}}): { "firstName": "John", "lastName": "Doe" }',
        );

        expect(
          label.getTranslation({
            'choice': 'ADMIN',
            'gender': 'male',
            'name': 'John',
            'count': 5,
          }),
          equals(
            'The Mr John (Admin with 5 badges): { "firstName": "John", "lastName": "Doe" }',
          ),
        );
      },
      skip: true,
    );
  });
}
