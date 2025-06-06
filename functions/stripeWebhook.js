const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Récupère la clé Stripe depuis les configs Firebase ou les variables d'env
const stripeSecret = functions.config().stripe?.secret || process.env.STRIPE_SECRET;
const stripe = require('stripe')(stripeSecret);

// Handler du webhook Stripe (pas d'export Cloud Function ici)
const stripeWebhookHandler = (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }
  const sig = req.headers['stripe-signature'];
  let event;
  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, functions.config().stripe.webhook_secret || process.env.STRIPE_WEBHOOK_SECRET);
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
        res.status(200).send('Balance updated');
      }).catch((e) => {
        console.error('Firestore set error:', e);
        res.status(500).send('Firestore set error');
      });
    } else {
      console.error('userId is undefined in Stripe session metadata');
      res.status(400).send('userId is undefined');
    }
  } else {
    res.status(200).send('Event received');
  }
};

module.exports = stripeWebhookHandler;
