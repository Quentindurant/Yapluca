const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const bodyParser = require('body-parser');
const stripe = require('stripe')(functions.config().stripe.secret);

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

// Import du webhook Stripe isolé
exports.stripeWebhook = require('./stripeWebhook').stripeWebhook;