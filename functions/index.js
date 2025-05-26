const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialise Firebase Admin si ce n'est pas déjà fait
if (!admin.apps.length) {
  admin.initializeApp();
}

const stripe = require("stripe")(functions.config().stripe.secret);

// Fonction callable pour créer une session Stripe Checkout
exports.createStripeCheckoutSession = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
      console.log("[DEBUG] context:", JSON.stringify(context));
      console.log("[DEBUG] context.auth:", JSON.stringify(context.auth));
      if (!context.auth) {
        console.error("[DEBUG] Appel sans authentification Firebase !");
        throw new functions.https.HttpsError(
            "unauthenticated",
            "L'utilisateur doit être authentifié.",
        );
      }
      // Vérification explicite App Check
      console.log("[DEBUG] context.app:", JSON.stringify(context.app));
      if (!context.app) {
        console.error("[DEBUG] Appel sans App Check !");
            throw new functions.https.HttpsError(
              "failed-precondition",
              "Un token App Check est requis.",
            );
      }
      const {amount, currency, userId, email} = data;
      try {
        const session = await stripe.checkout.sessions.create({
          payment_method_types: ["card"],
          line_items: [
            {
              price_data: {
                currency: currency || "eur",
                product_data: {name: "Crédit YapluCa"},
                unit_amount: amount,
              },
              quantity: 1,
            },
          ],
          mode: "payment",
          success_url: "https://yapluca.com/success",
          cancel_url: "https://yapluca.com/cancel",
          metadata: {
            userId: userId || (context.auth && context.auth.uid),
            email: email || (context.auth && context.auth.token.email),
          },
        });
        return {sessionId: session.id, url: session.url};
      } catch (error) {
        console.error("Erreur création session Stripe:", error);
        throw new functions.https.HttpsError("internal", error.message);
      }
    });

// Import de la fonction Stripe webhook
const stripeWebhookHandler = require("./stripeWebhook");

// Export de la fonction pour déploiement Firebase
exports.stripeWebhook = functions
    .region("europe-west1")
    .https.onRequest(stripeWebhookHandler);
