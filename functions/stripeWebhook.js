const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const bodyParser = require('body-parser');
const stripe = require('stripe')(functions.config().stripe.secret);

// IMPORTANT : n'initialise pas admin ici si déjà fait dans index.js

const app = express();
app.use(bodyParser.raw({ type: 'application/json' }));

app.post('/', async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, functions.config().stripe.webhook_secret);
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const userId = session.metadata?.userId;
    const amount = session.amount_total / 100;
    if (userId) {
      await admin.firestore().collection('users').doc(userId).update({
        balance: admin.firestore.FieldValue.increment(amount)
      });
    }
  }
  res.json({ received: true });
});

exports.stripeWebhook = functions.region('us-central1').https.onRequest(app);
