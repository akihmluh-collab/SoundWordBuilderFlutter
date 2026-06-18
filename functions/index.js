const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Cloud Function: deleteUser
 * Called from client app to permanently delete a user from Authentication
 * This is CALLABLE, meaning it can be called directly from the Flutter app
 */
exports.deleteUser = functions.https.onCall(async (data, context) => {
  // 1. Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'You must be logged in to delete a user.'
    );
  }

  // 2. Check if the caller is a teacher
  const callerUid = context.auth.uid;
  const callerDoc = await admin.firestore().collection('users').doc(callerUid).get();
  
  if (!callerDoc.exists || callerDoc.data().role !== 'teacher') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only teachers can delete users.'
    );
  }

  // 3. Get the user ID to delete
  const { userId } = data;
  if (!userId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'userId is required.'
    );
  }

  try {
    // 4. Delete the user from Authentication
    await admin.auth().deleteUser(userId);
    
    // 5. Also delete from Firestore (in case it wasn't already deleted)
    await admin.firestore().collection('users').doc(userId).delete();
    
    return {
      success: true,
      message: `User ${userId} deleted successfully.`
    };
  } catch (error) {
    console.error('Error deleting user:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to delete user: ${error.message}`
    );
  }
});