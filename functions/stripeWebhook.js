const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe.secret);

// PAS de admin.initializeApp() ici si déjà fait dans index.js

exports.stripeWebhook = functions.region('europe-west9').https.onRequest((req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }
  const sig = req.headers['stripe-signature'];
  let event;
  try {
    // Stripe attend un Buffer !
    event = stripe.webhooks.constructEvent(req.rawBody, sig, functions.config().stripe.webhook_secret);
  } catch (err) {
    console.error('Webhook signature error:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }
  console.log('Stripe event received:', event.type);
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const userId = session.metadata?.userId;
    const amount = session.amount_total / 100;
    console.log('userId:', userId, 'amount:', amount);
    if (userId) {
      if (!admin.apps.length) {
        console.error('Firebase admin not initialized!');
        return res.status(500).send('Firebase admin not initialized');
      }
      admin.firestore().collection('users').doc(userId).set({
        balance: admin.firestore.FieldValue.increment(amount)
      }, { merge: true })
      .then(() => {
        console.log('Balance updated for user:', userId);
      }).catch((e) => {
        console.error('Firestore set error:', e);
      });
    } else {
      console.error('userId is undefined in Stripe session metadata');
    }
  }
  res.json({ received: true });
});
