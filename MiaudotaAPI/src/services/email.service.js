import nodemailer from "nodemailer";
import dotenv from "dotenv";
dotenv.config();

// Create a transporter and try to verify. If verification fails in non-prod,
// fall back to an Ethereal test account so dev can continue working without
// real SMTP credentials.
let transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,
  port: parseInt(process.env.EMAIL_PORT || '587', 10),
  secure: (process.env.EMAIL_SECURE || 'false') === 'true',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// Attempt to verify transporter; if it fails and we're not in production,
// create an Ethereal account for local dev and reassign transporter.
(async () => {
  try {
    await transporter.verify();
    console.log('📧 SMTP transporter verified and ready.');
  } catch (err) {
    console.error('❌ SMTP transporter verification failed:', err.message || err);

    if ((process.env.NODE_ENV || 'development') !== 'production') {
      console.log('🔧 Creating Ethereal test account for dev (nodemailer)');
      const test = await nodemailer.createTestAccount();
      transporter = nodemailer.createTransport({
        host: 'smtp.ethereal.email',
        port: 587,
        secure: false,
        auth: {
          user: test.user,
          pass: test.pass,
        },
      });
      console.log('✅ Using Ethereal SMTP for local development');
    }
  }
})();

export { transporter };
