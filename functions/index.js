const functions = require('firebase-functions');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

// Crée une session Stripe Checkout pour un paiement unique
exports.createStripeCheckoutSession = functions.https.onCall(async (data, context) => {
  const session = await stripe.checkout.sessions.create({
    payment_method_types: ['card'],
    line_items: [{
      price_data: {
        currency: 'eur',
        product_data: {
          name: data.productName || 'Recharge batterie YapluCa',
        },
        unit_amount: data.amount, // en centimes, ex: 200 = 2€
      },
      quantity: 1,
    }],
    mode: 'payment',
    success_url: data.successUrl,
    cancel_url: data.cancelUrl,
  });
  return { id: session.id, url: session.url };
});
