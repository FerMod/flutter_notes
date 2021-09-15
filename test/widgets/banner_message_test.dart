import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_notes/widgets/banner_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BannerMessage', () {
    group('of', () {
      testWidgets('returns the correct $BannerMessageState', (tester) async {
        final GlobalKey<BannerMessageState> bannerMessageKey = GlobalKey<BannerMessageState>();
        final List<BannerMessageState> log = <BannerMessageState>[];
        Widget build() {
          return BannerMessage(
            key: bannerMessageKey,
            messageBuilder: (context, message) => Container(),
            child: Builder(
              builder: (context) {
                log.add(BannerMessage.of(context));
                return Container();
              },
            ),
          );
        }

        await tester.pumpWidget(build());

        expect(log, equals(<BannerMessageState>[bannerMessageKey.currentState!]));
      });

      testWidgets('throws when there is no $BannerMessage in scope', (tester) async {
        final globalKey = GlobalKey(debugLabel: 'Test Key');
        await tester.pumpWidget(Container(key: globalKey));

        expect(
          () => BannerMessage.of(globalKey.currentContext!),
          throwsA(isAssertionError.having(
            (e) => e.message,
            'message',
            contains('No $BannerMessage widget ancestor found.'),
          )),
        );
      });
    });

    group('maybeOf', () {
      testWidgets('returns the correct $BannerMessageState', (tester) async {
        final GlobalKey<BannerMessageState> bannerMessageKey = GlobalKey<BannerMessageState>();
        final List<BannerMessageState> log = <BannerMessageState>[];
        Widget build() {
          return BannerMessage(
            key: bannerMessageKey,
            messageBuilder: (context, message) => Container(),
            child: Builder(
              builder: (context) {
                log.add(BannerMessage.maybeOf(context)!);
                return Container();
              },
            ),
          );
        }

        await tester.pumpWidget(build());

        expect(log, equals(<BannerMessageState>[bannerMessageKey.currentState!]));
      });

      testWidgets('returns null when there is no $BannerMessage in scope', (tester) async {
        final globalKey = GlobalKey(debugLabel: 'Test Key');
        await tester.pumpWidget(Container(key: globalKey));

        expect(BannerMessage.maybeOf(globalKey.currentContext!), isNull);
      });
    });

    group('dataOf', () {
      testWidgets('returns the correct $MessageData', (tester) async {
        final log = <MessageData>[];
        final bannerMessageKey = GlobalKey<BannerMessageState>();

        final builder = Builder(
          builder: (context) {
            log.add(BannerMessage.dataOf(context));
            return Container();
          },
        );

        Widget build(MessageData data) {
          return BannerMessage(
            key: bannerMessageKey,
            messageBuilder: (context, message) => Container(),
            data: data,
            child: builder,
          );
        }

        const firstData = MessageData(message: 'First message');
        await tester.pumpWidget(build(firstData));

        expect(bannerMessageKey.currentState!.data, equals(firstData));
        expect(log, equals(<MessageData>[firstData]));

        const secondData = MessageData(message: 'First message');
        await tester.pumpWidget(build(secondData));

        expect(bannerMessageKey.currentState!.data, equals(secondData));
        expect(log, equals(<MessageData>[firstData]));

        const thirdData = MessageData(message: 'Third message');
        await tester.pumpWidget(build(thirdData));

        expect(bannerMessageKey.currentState!.data, equals(thirdData));
        expect(log, equals(<MessageData>[firstData, thirdData]));
      });

      testWidgets('throws when there is no $BannerMessage in scope', (tester) async {
        final globalKey = GlobalKey(debugLabel: 'Test Key');
        await tester.pumpWidget(Container(key: globalKey));

        expect(
          () => BannerMessage.of(globalKey.currentContext!),
          throwsA(isAssertionError.having(
            (e) => e.message,
            'message',
            contains('No $BannerMessage widget ancestor found.'),
          )),
        );
      });
    });

    group('show', () {
      testWidgets('makes message widget visible', (tester) async {
        final messageKey = GlobalKey(debugLabel: 'Message Widget Key');
        final childKey = GlobalKey(debugLabel: 'Child Widget Key');

        Widget build() {
          return BannerMessage(
            messageBuilder: (context, message) => Container(key: messageKey),
            child: Container(key: childKey),
          );
        }

        await tester.pumpWidget(build());

        final finder = find.byKey(messageKey);
        expect(finder, findsNothing);

        BannerMessage.show(childKey.currentContext!);
        await tester.pump();
        expect(finder, findsOneWidget);
      });
    });

    group('hide', () {
      testWidgets('makes message widget disappear', (tester) async {
        final messageKey = GlobalKey(debugLabel: 'Message Widget Key');
        final childKey = GlobalKey(debugLabel: 'Child Widget Key');

        Widget build() {
          return BannerMessage(
            messageBuilder: (context, message) => Container(key: messageKey),
            data: const MessageData(isVisible: true),
            child: Container(key: childKey),
          );
        }

        await tester.pumpWidget(build());
        await tester.pump();

        final finder = find.byKey(messageKey);
        expect(finder, findsOneWidget);

        BannerMessage.hide(childKey.currentContext!);
        await tester.pump();
        expect(finder, findsNothing);
      });
    });
  });

  group('BannerMessageState', () {
    group('show', () {
      testWidgets('makes message widget visible', (tester) async {
        final bannerMessageKey = GlobalKey<BannerMessageState>();
        final messageKey = GlobalKey(debugLabel: 'Message Widget Key');

        Widget build() {
          return BannerMessage(
            key: bannerMessageKey,
            messageBuilder: (context, message) => Container(key: messageKey),
            child: Container(),
          );
        }

        await tester.pumpWidget(build());

        final finder = find.byKey(messageKey);
        expect(finder, findsNothing);

        bannerMessageKey.currentState!.show();
        await tester.pump();

        expect(finder, findsOneWidget);
      });

      testWidgets('calls message builder only when visible', (tester) async {
        final globalKey = GlobalKey(debugLabel: 'Test Key');

        final contextCompleter = Completer<BuildContext>();
        final messageDataCompleter = Completer<MessageData>();

        Widget build(MessageData messageData) {
          return BannerMessage(
            key: globalKey,
            messageBuilder: (context, message) {
              contextCompleter.complete(context);
              messageDataCompleter.complete(message);
              return Container();
            },
            data: messageData,
            child: Container(),
          );
        }

        const notVisibleMessage = MessageData(message: 'Not visible content');
        await tester.pumpWidget(build(notVisibleMessage));

        expect(contextCompleter.isCompleted, isFalse);
        expect(messageDataCompleter.isCompleted, isFalse);

        const visibleMessage = MessageData(isVisible: true, message: 'Visible content');
        await tester.pumpWidget(build(visibleMessage));

        expect(contextCompleter.isCompleted, isTrue);
        expect(contextCompleter.future, completion(globalKey.currentContext));

        expect(messageDataCompleter.isCompleted, isTrue);
        expect(messageDataCompleter.future, completion(visibleMessage));
      });

      testWidgets('displays the correct $MessageData', (tester) async {
        final log = <MessageData>[];
        final bannerMessageKey = GlobalKey<BannerMessageState>();

        Widget build() {
          return BannerMessage(
            key: bannerMessageKey,
            messageBuilder: (context, message) {
              log.add(message);
              return Container();
            },
            child: Container(),
          );
        }

        await tester.pumpWidget(build());

        const firstData = MessageData(isVisible: true, message: 'First message');
        bannerMessageKey.currentState!.show(message: firstData.message, actions: firstData.actions);
        await tester.pump();

        expect(bannerMessageKey.currentState!.data, equals(firstData));
        expect(log, equals(<MessageData>[firstData]));

        const secondData = MessageData(isVisible: true, message: 'First message');
        bannerMessageKey.currentState!.show(message: secondData.message, actions: secondData.actions);
        await tester.pump();

        expect(bannerMessageKey.currentState!.data, equals(secondData));
        expect(log, equals(<MessageData>[firstData]));

        const thirdData = MessageData(isVisible: true, message: 'Third message', actions: [Text('Test action')]);
        bannerMessageKey.currentState!.show(message: thirdData.message, actions: thirdData.actions);
        await tester.pump();

        expect(bannerMessageKey.currentState!.data, equals(thirdData));
        expect(log, equals(<MessageData>[firstData, thirdData]));
      });

      testWidgets('multiple calls does not create different MessageController', (tester) async {
        final bannerMessageKey = GlobalKey<BannerMessageState>();

        Widget build() {
          return BannerMessage(
            key: bannerMessageKey,
            messageBuilder: (context, message) => Container(),
            child: Container(),
          );
        }

        await tester.pumpWidget(build());

        final firstController = bannerMessageKey.currentState!.show<String>();
        await tester.pump();

        final secondController = bannerMessageKey.currentState!.show<String>(message: 'Test');
        await tester.pump();
        expect(firstController.isClosed, isFalse);
        expect(secondController, firstController);
      });

      testWidgets('creates a MessageController of the correct type', (tester) async {
        final bannerMessageKey = GlobalKey<BannerMessageState>();
        Widget build() {
          return BannerMessage(
            key: bannerMessageKey,
            messageBuilder: (context, value) => Container(),
            child: Container(),
          );
        }

        MessageController<T?> showMessage<T>() {
          return bannerMessageKey.currentState!.show<T>(message: 'Test message');
        }

        await tester.pumpWidget(build());
        expect(showMessage<String>(), isA<MessageController<String>>());
        await tester.pumpWidget(Container());

        await tester.pumpWidget(build());
        expect(showMessage<bool>(), isA<MessageController<bool>>());
        await tester.pumpWidget(Container());

        await tester.pumpWidget(build());
        expect(showMessage<void>(), isA<MessageController<void>>());
      });
    });

    group('hide', () {
      testWidgets('makes message widget disappear', (tester) async {
        final bannerMessageKey = GlobalKey<BannerMessageState>();
        final messageKey = GlobalKey(debugLabel: 'Message Widget Key');

        Widget build() {
          return BannerMessage(
            key: bannerMessageKey,
            messageBuilder: (context, message) => Container(key: messageKey),
            data: const MessageData(isVisible: true),
            child: Container(),
          );
        }

        await tester.pumpWidget(build());

        final finder = find.byKey(messageKey);
        expect(finder, findsOneWidget);

        bannerMessageKey.currentState!.hide();
        await tester.pump();

        expect(finder, findsNothing);

        await tester.pumpWidget(build());

        final messageController = bannerMessageKey.currentState!.show();
        await tester.pump();

        expect(finder, findsOneWidget);

        messageController.close();
        await tester.pump();
        expect(finder, findsNothing);
      });

      testWidgets('returns the correct value', (tester) async {
        final bannerMessageKey = GlobalKey<BannerMessageState>();
        Widget build() {
          return BannerMessage(
            key: bannerMessageKey,
            messageBuilder: (context, value) => Container(),
            child: Container(),
          );
        }

        void testHide<T>([T? result]) {
          final bannerState = bannerMessageKey.currentState!;
          final controller = bannerState.show<T>(message: 'Test');
          expect(controller.closed, completion(allOf([isA<T>(), result])));
          bannerState.hide<T>(result);
        }

        void testClose<T>([T? result]) {
          final bannerState = bannerMessageKey.currentState!;
          final controller = bannerState.show<T>(message: 'Test');
          expect(controller.closed, completion(allOf([isA<T>(), result])));
          controller.close(result);
        }

        await tester.pumpWidget(build());

        testHide<String>('Test value');
        testHide<int>(16);
        testHide<bool>(true);
        testHide<void>();

        testClose<String>('Test value');
        testClose<int>(16);
        testClose<bool>(true);
        testClose<void>();
      });

      testWidgets('multiple calls when already hidden does nothing', (tester) async {
        final bannerMessageKey = GlobalKey<BannerMessageState>();

        const firstResult = 'First result';
        const secondResult = 'Second result';

        Widget build() {
          return BannerMessage(
            key: bannerMessageKey,
            messageBuilder: (context, message) => Container(),
            child: Container(),
          );
        }

        await tester.pumpWidget(build());

        final firstController = bannerMessageKey.currentState!.show<String>();
        await tester.pump();

        expect(firstController.isClosed, isFalse);
        expect(firstController.closed, completion(firstResult));
        bannerMessageKey.currentState!.hide<String>(firstResult);
        await tester.pump();

        expect(firstController.isClosed, isTrue);
        expect(firstController.closed, completion(firstResult));
        bannerMessageKey.currentState!.hide<String>(secondResult);
        await tester.pump();
        expect(firstController.isClosed, isTrue);

        final secondController = bannerMessageKey.currentState!.show<String>();
        await tester.pump();

        expect(secondController.isClosed, isFalse);
        expect(secondController.closed, completion(firstResult));
        secondController.close(firstResult);
        await tester.pump();

        expect(secondController.isClosed, isTrue);
        expect(secondController.closed, completion(firstResult));
        secondController.close(secondResult);
        await tester.pump();
        expect(secondController.isClosed, isTrue);
      });
    });
  });

  testWidgets('Assert debugCheckHasBannerMessage', (tester) async {
    final bannerMessageKey = GlobalKey<BannerMessageState>();
    final childWidgetKey = GlobalKey(debugLabel: 'Child Widget');
    final messageBuilderKey = GlobalKey(debugLabel: 'Message Builder');

    final childWidget = Container(key: childWidgetKey);

    Widget build() {
      return BannerMessage(
        key: bannerMessageKey,
        messageBuilder: (context, message) => Container(key: messageBuilderKey),
        child: childWidget,
      );
    }

    await tester.pumpWidget(build());
    expect(childWidgetKey.currentContext, isNotNull);
    expect(debugCheckHasBannerMessage(childWidgetKey.currentContext!), isTrue);

    bannerMessageKey.currentState!.show();
    await tester.pump();
    expect(messageBuilderKey.currentContext, isNotNull);
    expect(debugCheckHasBannerMessage(messageBuilderKey.currentContext!), isTrue);

    await tester.pumpWidget(childWidget);
    expect(childWidgetKey.currentContext, isNotNull);
    expect(
      () => debugCheckHasBannerMessage(childWidgetKey.currentContext!),
      throwsA(isAssertionError.having(
        (e) => e.message,
        'message',
        contains('No $BannerMessage widget ancestor found.'),
      )),
    );
  });
}
