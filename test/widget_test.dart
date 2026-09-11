// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shadow_shat/main.dart';

void main() {
  test('duplicate Firebase initialization is ignored safely', () {
    const duplicateError = FirebaseException(
      plugin: 'firebase_core',
      code: 'duplicate-app',
      message: 'A Firebase App named "[DEFAULT]" already exists',
    );

    expect(isDuplicateFirebaseInitializationError(duplicateError), isTrue);
    expect(isDuplicateFirebaseInitializationError(const FirebaseException(
      plugin: 'firebase_core',
      code: 'unknown',
      message: 'other error',
    )), isFalse);
  });

  test('contact docs store the target uid for the current user relationship', () {
    final myRelationship = buildContactRelationshipData(
      currentUserUid: 'user-1',
      targetUid: 'user-2',
      displayName: 'Ali',
      publicId: 'SC-ABC123',
      status: 'pending',
    );

    expect(myRelationship['uid'], 'user-2');
    expect(myRelationship['contactId'], 'SC-ABC123');
    expect(myRelationship['status'], 'pending');

    final incomingRequest = buildIncomingContactRequestData(
      currentUserUid: 'user-1',
      senderUid: 'user-3',
      senderDisplayName: 'Sara',
    );

    expect(incomingRequest['uid'], 'user-3');
    expect(incomingRequest['contactId'], 'user-3');
    expect(incomingRequest['status'], 'incoming');
  });

  test('secret room members are only added by the owner or the same user', () {
    expect(
      canWriteSecretMembership(
        currentUserUid: 'owner',
        memberId: 'member-1',
        addedBy: 'owner',
        isOwner: true,
      ),
      isTrue,
    );
    expect(
      canWriteSecretMembership(
        currentUserUid: 'user-1',
        memberId: 'user-2',
        addedBy: 'user-1',
        isOwner: false,
      ),
      isFalse,
    );
  });

  testWidgets('Shadow Chat app starts', (WidgetTester tester) async {
    appLockEnabledNotifier.value = true;
    appLockPasswordNotifier.value = await hashPassword(defaultAppLockPassword);
    await tester.pumpWidget(const MaterialApp(home: AppLockGate()));

    expect(find.byType(AppLockGate), findsOneWidget);
    expect(find.text('تغيير كلمة سر قفل التطبيق'), findsOneWidget);
  });
}
