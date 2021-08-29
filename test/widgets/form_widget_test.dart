import 'package:flutter_notes/widgets/form_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FieldValidator', () {
    test('returns null when all assertion satisfy', () {
      final validations = <Validation<String?>>[
        Validation<String?>(
          errorMessage: 'Is empty or null',
          assertion: (value) => value != null && value.isNotEmpty,
        ),
        Validation<String?>(
          errorMessage: 'Does not start with "t"',
          assertion: (value) => value!.startsWith('t'),
        ),
        Validation<String?>(
          errorMessage: 'Does not end with "t"',
          assertion: (value) => value!.endsWith('t'),
        ),
      ];
      final fieldValidator = FieldValidator<String?>(validations);

      final intValidator = FieldValidator<int>([
        Validation<int>(
          errorMessage: 'Its negative',
          assertion: (value) => !value!.isNegative,
        ),
        Validation<int>(
          errorMessage: 'Its odd',
          assertion: (value) => value!.isEven,
        )
      ]);

      expect(fieldValidator.validate('test'), isNull);
      expect(intValidator.validate(4), isNull);
    });

    group('validate', () {
      test('handles nullable types correctly', () {
        final fieldValidator1 = FieldValidator<String?>([
          Validation<String?>(
            errorMessage: 'Is empty or null',
            assertion: (value) => value != null && value.isNotEmpty,
          ),
          Validation<String>(
            errorMessage: 'Does not start with "t"',
            assertion: (value) => value!.startsWith('t'),
          ),
        ]);

        expect(fieldValidator1.validate('test'), isNull);
        expect(fieldValidator1.validate(null), fieldValidator1.validations[0].errorMessage);

        final fieldValidator2 = FieldValidator<String?>([
          Validation<String>(
            errorMessage: 'Is empty',
            assertion: (value) => value!.isNotEmpty,
          ),
          Validation<String>(
            errorMessage: 'Does not start with "t"',
            assertion: (value) => value!.startsWith('t'),
          ),
        ]);

        expect(fieldValidator2.validate('test'), isNull);
        expect(
          () => fieldValidator2.validate(null),
          throwsA(const TypeMatcher<TypeError>()),
        );

        final fieldValidator3 = FieldValidator<String?>([
          Validation<String>(
            errorMessage: 'Always true',
            assertion: (value) => true,
          ),
          Validation<String>(
            errorMessage: 'Does not start with "t"',
            assertion: (value) => value!.startsWith('t'),
          ),
        ]);

        expect(fieldValidator3.validate('test'), isNull);
        expect(
          () => fieldValidator3.validate(null),
          throwsA(const TypeMatcher<TypeError>()),
        );
      });

      test('returns null when all assertion satisfy', () {
        final validations = <Validation<String?>>[
          Validation<String?>(
            errorMessage: 'Is empty or null',
            assertion: (value) => value != null && value.isNotEmpty,
          ),
          Validation<String?>(
            errorMessage: 'Does not start with "t"',
            assertion: (value) => value!.startsWith('t'),
          ),
          Validation<String?>(
            errorMessage: 'Does not end with "t"',
            assertion: (value) => value!.endsWith('t'),
          ),
        ];
        final fieldValidator = FieldValidator<String?>(validations);

        final intValidator = FieldValidator<int>([
          Validation<int>(
            errorMessage: 'Its negative',
            assertion: (value) => !value!.isNegative,
          ),
          Validation<int>(
            errorMessage: 'Its odd',
            assertion: (value) => value!.isEven,
          )
        ]);

        expect(fieldValidator.validate('test'), isNull);
        expect(intValidator.validate(4), isNull);
      });

      test('returns the error message when assertion does not satisfy', () {
        final validations = <Validation<String?>>[
          Validation<String?>(
            errorMessage: 'Is empty or null',
            assertion: (value) => value != null && value.isNotEmpty,
          ),
          Validation<String?>(
            errorMessage: 'Does not start with "t"',
            assertion: (value) => value!.startsWith('t'),
          ),
          Validation<String?>(
            errorMessage: 'Does not end with "t"',
            assertion: (value) => value!.endsWith('t'),
          ),
        ];
        final fieldValidator = FieldValidator<String?>(validations);

        expect(fieldValidator.validate(''), validations[0].errorMessage);
        expect(fieldValidator.validate('value'), validations[1].errorMessage);
        expect(fieldValidator.validate('team'), validations[2].errorMessage);
      });

      test('returns null when no assertion exist', () {
        expect(const FieldValidator<String>().validate('test'), isNull);
        expect(const FieldValidator().validate(0), isNull);
      });
    });
  });
}
