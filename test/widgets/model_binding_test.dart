import 'package:flutter_notes/model_binding.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'test_widgets.dart';

@immutable
class TestModel {
  const TestModel({this.value = 0});

  final int value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final TestModel otherModel = other;
    return otherModel.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TestModel(value: $value)';
}

void main() {
  List log;

  setUp(() {
    log = <dynamic>[];
  });

  group('ModelBinding.of', () {
    testWidgets('returns the correct model', (tester) async {
      final builder = Builder(
        builder: (context) {
          log.add(ModelBinding.of<TestModel>(context));
          return Container();
        },
      );

      final firstModel = TestModel(value: 1);
      final firstWidget = ModelBinding(
        initialModel: firstModel,
        child: builder,
      );
      await tester.pumpWidget(firstWidget);

      expect(log, equals(<TestModel>[firstModel]));

      final secondModel = TestModel(value: 1);
      final secondWidget = ModelBinding(
        initialModel: secondModel,
        child: builder,
      );
      await tester.pumpWidget(secondWidget);

      expect(log, equals(<TestModel>[firstModel]));

      final thirdModel = TestModel(value: 3);
      final thirdWidget = ModelBinding(
        initialModel: thirdModel,
        child: builder,
      );
      await tester.pumpWidget(thirdWidget);

      expect(log, equals(<TestModel>[firstModel, thirdModel]));
    });

    testWidgets('returns null when no model exist', (tester) async {
      final globalKey = GlobalKey(debugLabel: 'Test Key');
      await tester.pumpWidget(Container(key: globalKey));

      expect(ModelBinding.of<TestModel>(globalKey.currentContext), isNull);
    });

    /*
    testWidgets('returns correctly the model of `dynamic` type', (tester) async {
      final globalKey = GlobalKey(debugLabel: 'Test Key');

      final model = TestModel();

      ModelBinding build() {
        return ModelBinding(
          key: UniqueKey(),
          initialModel: model,
          child: Container(
            key: globalKey,
            child: Builder(
              builder: (context) {
                log.add(ModelBinding.of(context));
                return Container();
              },
            ),
          ),
        );
      }

      final widget = build();
      await tester.pumpWidget(widget);

      expect(log, [model]);
    });
    */

    testWidgets('throws when initialModel is null', (tester) async {
      expect(
        () => ModelBinding(initialModel: null),
        throwsA(isAssertionError),
      );
    });

    testWidgets('throws when context is null', (tester) async {
      expect(
        () => ModelBinding.of<TestModel>(null),
        throwsA(isAssertionError),
      );
    });

    testWidgets('throws when retrieving a model of type `dynamic`', (tester) async {
      final globalKey = GlobalKey(debugLabel: 'Test Key');
      final model = TestModel();

      ModelBinding buildOfTypeDynamic() {
        return ModelBinding(
          key: UniqueKey(),
          initialModel: model,
          child: Container(
            child: Builder(
              key: globalKey,
              builder: (context) {
                return Container();
              },
            ),
          ),
        );
      }

      final widgetDynamic = buildOfTypeDynamic();
      await tester.pumpWidget(widgetDynamic);

      expect(
        () => ModelBinding.of(globalKey.currentContext),
        throwsA(isAssertionError.having(
          (e) => e.message,
          'message',
          contains('Tried to call ModelBinding.of<dynamic>'),
        )),
      );

      ModelBinding<Object> buildOfTypeObject() {
        return ModelBinding<Object>(
          key: UniqueKey(),
          initialModel: model,
          child: Container(
            child: Builder(
              key: globalKey,
              builder: (context) {
                return Container();
              },
            ),
          ),
        );
      }

      final widgetObject = buildOfTypeObject();
      await tester.pumpWidget(widgetObject);

      expect(model, equals(ModelBinding.of<Object>(globalKey.currentContext)));
    });
  });

  group('ModelBinding.update', () {
    testWidgets('updates correctly the model', (tester) async {
      final globalKey = GlobalKey(debugLabel: 'Test Key');

      final firstModel = TestModel(value: 1);
      final secondModel = TestModel(value: 2);

      ModelBinding<TestModel> build() {
        return ModelBinding<TestModel>(
          key: UniqueKey(),
          initialModel: firstModel,
          child: Container(
            child: Builder(
              key: globalKey,
              builder: (context) {
                log.add(ModelBinding.of<TestModel>(context));
                return Container();
              },
            ),
          ),
        );
      }

      final widget = build();
      await tester.pumpWidget(widget);

      // The first model is present
      expect(log, <TestModel>[firstModel]);

      log.clear();
      await tester.pump();

      // No new models added
      expect(log, equals(<TestModel>[]));

      log.clear();
      ModelBinding.update<TestModel>(globalKey.currentContext, secondModel);
      await tester.pump();

      // The new model should be present
      expect(log, equals(<TestModel>[secondModel]));
    });

    testWidgets('throws when no ancestor is found', (tester) async {
      final globalKey = GlobalKey(debugLabel: 'Test Key');
      final model = TestModel();
      await tester.pumpWidget(Container(key: globalKey));

      expect(
        () => ModelBinding.update<TestModel>(globalKey.currentContext, model),
        throwsA(isAssertionError.having(
          (e) => e.message,
          'message',
          contains('ancestor was not found'),
        )),
      );
    });

    testWidgets('throws when updating a model of type `dynamic`', (tester) async {
      final globalKeyDynamic = GlobalKey(debugLabel: 'ModelBinding<dynamic> Key');
      final globalKeyObject = GlobalKey(debugLabel: 'ModelBinding<Object> Key');

      final firstModel = TestModel(value: 1);
      final secondModel = TestModel(value: 2);

      ModelBinding<dynamic> buildOfTypeDynamic() {
        return ModelBinding<dynamic>(
          key: UniqueKey(),
          initialModel: firstModel,
          child: Container(
            child: Builder(
              key: globalKeyDynamic,
              builder: (context) {
                return Container();
              },
            ),
          ),
        );
      }

      final widgetDynamic = buildOfTypeDynamic();
      await tester.pumpWidget(widgetDynamic);

      expect(
        () => ModelBinding.update<dynamic>(globalKeyDynamic.currentContext, firstModel),
        throwsA(isAssertionError.having(
          (e) => e.message,
          'message',
          contains('Tried to call ModelBinding.update<dynamic>'),
        )),
      );

      ModelBinding<Object> buildOfTypeObject() {
        return ModelBinding<Object>(
          key: UniqueKey(),
          initialModel: firstModel,
          child: Container(
            child: Builder(
              key: globalKeyObject,
              builder: (context) {
                log.add(ModelBinding.of<Object>(context));
                return Container();
              },
            ),
          ),
        );
      }

      final widgetObject = buildOfTypeObject();
      await tester.pumpWidget(widgetObject);
      // The first model should be present
      expect(log, equals(<Object>[firstModel]));

      ModelBinding.update<Object>(globalKeyObject.currentContext, secondModel);
      await tester.pump();

      // The new model should be present
      expect(log, equals(<Object>[firstModel, secondModel]));
    });

    /*
    testWidgets('updates correctly the model from `dynamic` type', (tester) async {
      final globalKey = GlobalKey(debugLabel: 'Test Key');

      final firstModel = TestModel(value: 1);
      final secondModel = TestModel(value: 2);

      ModelBinding build() {
        return ModelBinding(
          key: UniqueKey(),
          initialModel: firstModel,
          child: Container(
            child: Builder(
              key: globalKey,
              builder: (context) {
                log.add(ModelBinding.of(context));
                return Container();
              },
            ),
          ),
        );
      }

      final widget = build();
      await tester.pumpWidget(widget);

      // The first model is present
      expect(log, <TestModel>[firstModel]);

      log.clear();
      await tester.pump();

      // No new models added
      expect(log, equals(<TestModel>[]));

      log.clear();
      ModelBinding.update(globalKey.currentContext, secondModel);
      await tester.pump();

      // The new model should be present
      expect(log, equals(<TestModel>[secondModel]));
    });
    */

    testWidgets('only notifies when the model changes', (tester) async {
      final globalKey = GlobalKey(debugLabel: 'Test Key');

      final builder = Builder(
        key: globalKey,
        builder: (context) {
          log.add(ModelBinding.of<TestModel>(context));
          return Container();
        },
      );

      final firstModel = TestModel();
      final firstWidget = ModelBinding(
        initialModel: firstModel,
        child: builder,
      );
      await tester.pumpWidget(firstWidget);
      ModelBinding.update<TestModel>(globalKey.currentContext, firstModel);

      expect(log, equals(<TestModel>[firstModel]));

      final secondModel = TestModel();
      final secondWidget = ModelBinding(
        initialModel: secondModel,
        child: builder,
      );
      await tester.pumpWidget(secondWidget);
      ModelBinding.update<TestModel>(globalKey.currentContext, secondModel);

      expect(log, equals(<TestModel>[firstModel]));

      final thirdModel = TestModel(value: 1);
      final thirdWidget = ModelBinding(
        initialModel: thirdModel,
        child: builder,
      );
      await tester.pumpWidget(thirdWidget);
      ModelBinding.update<TestModel>(globalKey.currentContext, thirdModel);

      expect(log, equals(<TestModel>[firstModel, thirdModel]));
    });

    testWidgets('throws when context is null', (tester) async {
      final model = TestModel();

      expect(
        () => ModelBinding.update<TestModel>(null, model),
        throwsA(isAssertionError),
      );
    });
  });

  testWidgets('Update model when reparenting state', (tester) async {
    final globalKey = GlobalKey();

    ModelBinding<TestModel> build() {
      return ModelBinding(
        key: UniqueKey(),
        initialModel: TestModel(),
        child: Container(
          key: globalKey,
          child: Builder(
            builder: (context) {
              log.add(ModelBinding.of<TestModel>(context));
              return Container();
            },
          ),
        ),
      );
    }

    final first = build();
    await tester.pumpWidget(first);

    expect(log, equals(<TestModel>[first.initialModel]));

    final second = build();
    await tester.pumpWidget(second);

    expect(log, equals(<TestModel>[first.initialModel, second.initialModel]));
  });

  testWidgets('Update model when removing node', (tester) async {
    final widget = Container(
      child: ModelBinding(
        initialModel: TestModel(value: 1),
        child: FlipWidget(
          left: Container(
            child: ModelBinding(
              initialModel: TestModel(value: 2),
              child: Container(
                child: ModelBinding(
                  initialModel: TestModel(value: 3),
                  child: Container(
                    child: Builder(builder: (context) {
                      final testModel = ModelBinding.of<TestModel>(context);
                      log.add('a: ${testModel.value}');
                      return Container();
                    }),
                  ),
                ),
              ),
            ),
          ),
          right: Container(
            child: ModelBinding(
              initialModel: TestModel(value: 2),
              child: Container(
                child: Container(
                  child: Builder(builder: (context) {
                    final testModel = ModelBinding.of<TestModel>(context);
                    log.add('b: ${testModel.value}');
                    return Container();
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(widget);

    expect(log, equals(<String>['a: 3']));
    log.clear();

    await tester.pump();

    expect(log, equals(<String>[]));
    log.clear();

    flipStatefulWidget(tester);
    await tester.pump();

    expect(log, equals(<String>['b: 2']));
    log.clear();

    flipStatefulWidget(tester);
    await tester.pump();

    expect(log, equals(<String>['a: 3']));
    log.clear();
  });
}
