const functions = require("firebase-functions/v1");
const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");

initializeApp();

/** Thrown when the caller of a Cloud Function is not signed in. */
class UnauthenticatedError extends Error {
  /** @param {string} message Description of the failure. */
  constructor(message) {
    super(message);
    this.message = message;
    this.type = "UnauthenticatedError";
  }
}

/** Thrown when the caller is signed in but holds no admin claim. */
class NotAnAdminError extends Error {
  /** @param {string} message Description of the failure. */
  constructor(message) {
    super(message);
    this.message = message;
    this.type = "NotAnAdminError";
  }
}

/** Thrown when the requested role is outside the accepted list. */
class InvalidRoleError extends Error {
  /** @param {string} message Description of the failure. */
  constructor(message) {
    super(message);
    this.message = message;
    this.type = "InvalidRoleError";
  }
}

/**
 * Reports whether a role may be assigned to a newly created user.
 * @param {string} role The role carried by the creation request.
 * @return {boolean} True when the role is accepted.
 */
function roleIsValid(role) {
  // To be adapted with your own list of roles
  const validRoles = ["lecturer", "student"];
  return validRoles.includes(role);
}

exports.createUser = functions.https.onCall(async (data, context) => {
  try {
    // Checking that the user calling the Cloud Function is authenticated
    if (!context.auth) {
      throw new UnauthenticatedError(
          "The user is not authenticated. Only authenticated Admin users " +
          "can create new users.");
    }

    // Checking that the user calling the Cloud Function is an Admin user
    // uid of the user calling the Cloud Function
    const callerUid = context.auth.uid;
    const callerUserRecord = await getAuth().getUser(callerUid);
    if (!callerUserRecord.customClaims.admin) {
      throw new NotAnAdminError("Only Admin users can create new users.");
    }

    // Checking that the new user role is valid
    const role = data.role;
    if (!roleIsValid(role)) {
      throw new InvalidRoleError(
          "The \"" + role + "\" role is not a valid role");
    }

    const userCreationRequest = {
      userDetails: data,
      status: "Pending",
      createdBy: callerUid,
      createdOn: FieldValue.serverTimestamp(),
    };

    const userCreationRequestRef = await getFirestore()
        .collection("userCreationRequests")
        .add(userCreationRequest);

    const newUser = {
      email: data.email,
      emailVerified: false,
      password: data.password,
      displayName: data.name,
      id: data.id,
      tag: data.tag,
      token: data.token,
      disabled: false,
    };

    const userRecord = await getAuth().createUser(newUser);

    const userId = userRecord.uid;

    const claims = {};
    claims[role] = true;
    claims["HCMIU"] = true;

    await getAuth().setCustomUserClaims(userId, claims);

    await getFirestore().collection("users").doc(userId).set(data);

    await userCreationRequestRef.update({status: "Treated"});

    return {result: "The new user has been successfully created."};
  } catch (error) {
    if (error.type === "UnauthenticatedError") {
      throw new functions.https.HttpsError("unauthenticated", error.message);
    } else if (error.type === "NotAnAdminError" ||
        error.type === "InvalidRoleError") {
      throw new functions.https.HttpsError(
          "failed-precondition", error.message);
    } else {
      throw new functions.https.HttpsError("internal", error.message);
    }
  }
});

// The bootstrap trigger that used to live here (`assignAdminClaim`) granted
// the `admin` custom claim to a hard-coded uid whenever any document appeared
// under `tempoAssignClaim/{Id}`. It performed no authorisation check of its
// own, so any principal able to write that collection could escalate that
// account. It was scaffolding used while bringing the prototype up, and it
// has been removed.
//
// Grant the first admin claim out of band instead, with the Admin SDK under
// credentials only the project owner holds:
//
//   getAuth().setCustomUserClaims(uid, {admin: true, HCMIU: true});
//
// Every later account is created through `createUser` above, which does check
// that its caller already holds the `admin` claim.
