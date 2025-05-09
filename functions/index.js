const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe.secret);
const express = require('express');
const bodyParser = require('body-parser');

admin.initializeApp();

// Fonction pour créer une session Stripe Checkout (avec metadata userId)
exports.createStripeCheckoutSession = functions
  .region('us-central1')
  .https.onCall(async (data, context) => {
    const { amount, productName, successUrl, cancelUrl } = data;
    const userId = context.auth?.uid;
    const userEmail = context.auth?.token?.email;
    try {
      const session = await stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        customer_email: userEmail || undefined,
        line_items: [{
          price_data: {
            currency: 'eur',
            product_data: { name: productName },
            unit_amount: amount,
          },
          quantity: 1,
        }],
        mode: 'payment',
        success_url: successUrl,
        cancel_url: cancelUrl,
        metadata: { userId: userId || '' },
      });
      return { url: session.url };
    } catch (error) {
      throw new functions.https.HttpsError('internal', error.message);
    }
  });

// Webhook Stripe pour créditer le solde utilisateur
const app = express();
app.use(bodyParser.raw({ type: 'application/json' }));

const endpointSecret = functions.config().stripe.webhook_secret || '';

app.post('/', async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const userId = session.metadata?.userId;
    const amount = session.amount_total / 100; // en euros
    if (userId) {
      await admin.firestore().collection('users').doc(userId).update({
        balance: admin.firestore.FieldValue.increment(amount)
      });
    }
  }
  res.json({ received: true });
});

exports.stripeWebhook = functions.region('us-central1').https.onRequest((req, res) => {
  app(req, res);
});