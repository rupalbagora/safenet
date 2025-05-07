import nodemailer from 'nodemailer';
import twilio from 'twilio';
import userSchemaModel from '../models/user.model.js';

// Configure email transporter
const emailTransporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'pawarh421@gmail.com',
    pass: 'vlow xotj cgpg upxo' // Using the existing app password
  }
});

// Configure Twilio client
const twilioClient = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

// Store OTPs temporarily (in production, use Redis or similar)
const otpStore = new Map();

// Generate a random 6-digit OTP
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Send OTP via email
async function sendEmailOTP(email) {
  const otp = generateOTP();
  const verificationId = Date.now().toString();

  const mailOptions = {
    from: 'pawarh421@gmail.com',
    to: email,
    subject: 'SafeNet Account Verification',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #1a73e8; text-align: center;">Welcome to SafeNet</h1>
        <div style="background-color: #f8f9fa; padding: 20px; border-radius: 5px;">
          <p style="font-size: 16px;">Your verification code is:</p>
          <h2 style="color: #1a73e8; text-align: center; font-size: 32px; letter-spacing: 5px; background-color: #e8f0fe; padding: 10px; border-radius: 5px;">${otp}</h2>
          <p style="font-size: 14px; color: #666;">This code will expire in 10 minutes.</p>
          <hr style="border: 1px solid #ddd; margin: 20px 0;">
          <p style="font-size: 14px; color: #666;">If you didn't request this verification code, please ignore this email.</p>
        </div>
        <div style="text-align: center; margin-top: 20px; color: #666; font-size: 12px;">
          <p>This is an automated message, please do not reply.</p>
        </div>
      </div>
    `
  };

  try {
    await emailTransporter.sendMail(mailOptions);
    otpStore.set(verificationId, {
      otp,
      type: 'email',
      contact: email,
      timestamp: Date.now()
    });
    return { success: true, verificationId };
  } catch (error) {
    console.error('Error sending email:', error);
    return { success: false, error: 'Failed to send verification email' };
  }
}

// Send OTP via SMS
async function sendSMSOTP(phoneNumber) {
  const otp = generateOTP();
  const verificationId = Date.now().toString();

  try {
    await twilioClient.messages.create({
      body: `Your SafeNet verification code is: ${otp}. This code will expire in 10 minutes.`,
      to: phoneNumber,
      from: '+19786349521' // Your Twilio phone number
    });

    otpStore.set(verificationId, {
      otp,
      type: 'phone',
      contact: phoneNumber,
      timestamp: Date.now()
    });
    return { success: true, verificationId };
  } catch (error) {
    console.error('Error sending SMS:', error);
    return { success: false, error: 'Failed to send verification SMS' };
  }
}

// Verify OTP
export const verifyOTP = async (req, res) => {
  const { verificationId, otp, type, contact } = req.body;

  if (!verificationId || !otp || !type || !contact) {
    return res.status(400).json({
      success: false,
      error: 'Missing required fields'
    });
  }

  const storedData = otpStore.get(verificationId);

  if (!storedData) {
    return res.status(400).json({
      success: false,
      error: 'Invalid verification ID'
    });
  }

  // Check if OTP has expired (10 minutes)
  if (Date.now() - storedData.timestamp > 10 * 60 * 1000) {
    otpStore.delete(verificationId);
    return res.status(400).json({
      success: false,
      error: 'OTP has expired'
    });
  }

  // Verify OTP
  if (storedData.otp !== otp || storedData.type !== type || storedData.contact !== contact) {
    return res.status(400).json({
      success: false,
      error: 'Invalid OTP'
    });
  }

  // Update user status
  try {
    const updateField = type === 'email' ? { email: contact } : { mobile: contact };
    await userSchemaModel.findOneAndUpdate(
      updateField,
      { status: 1 },
      { new: true }
    );

    // Clean up OTP
    otpStore.delete(verificationId);

    return res.status(200).json({
      success: true,
      message: 'Verification successful'
    });
  } catch (error) {
    console.error('Error updating user status:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to update user status'
    });
  }
};

// Resend OTP
export const resendOTP = async (req, res) => {
  const { type, contact } = req.body;

  if (!type || !contact) {
    return res.status(400).json({
      success: false,
      error: 'Missing required fields'
    });
  }

  try {
    let result;
    if (type === 'email') {
      result = await sendEmailOTP(contact);
    } else {
      result = await sendSMSOTP(contact);
    }

    if (result.success) {
      return res.status(200).json({
        success: true,
        message: `Verification code sent to your ${type}`,
        verificationId: result.verificationId
      });
    } else {
      return res.status(500).json({
        success: false,
        error: result.error
      });
    }
  } catch (error) {
    console.error('Error resending OTP:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to resend verification code'
    });
  }
}; 