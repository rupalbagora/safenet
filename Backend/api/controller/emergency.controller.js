import '../models/connection.js'
import emergencySchemaModel from '../models/emergency.model.js';  // Importing the Emergency model
import userSchemaModel from '../models/user.model.js';  // Importing the User model

export const save = async (req, res) => {
  // Extract the fields from the request body
  const { email, name, relation, mobile } = req.body;

  // Validate the fields
  if (!email || !name || !relation || !mobile) {
    return res.status(400).json({ success: false, msg: "All fields are required" });
  }

  try {
    // Find the user by email
    const user = await userSchemaModel.findOne({ email });

    // If user doesn't exist, return an error
    if (!user) {
      return res.status(404).json({ success: false, msg: "User not found" });
    }

    // Create the emergency contact
    const emergencyContact = await emergencySchemaModel.create({
      userEmail: user.email,  // Use userEmail from the user document
      name,
      relation,
      mobile
    });

    // Return success response
    res.status(200).json({
      success: true,
      msg: "Emergency contact saved successfully",
      emergencyContact
    });
  } catch (err) {
    // If an error occurs, return a failure response
    console.error(err);
    res.status(500).json({
      success: false,
      msg: "Failed to save emergency contact",
      error: err.message
    });
  }
};
export const fetch = async (req, res) => {
  // Extract email from the request body or URL (depending on your routing logic)
  const { email } = req.body;

  // Validate the email
  if (!email) {
    return res.status(400).json({ success: false, msg: "Email is required" });
  }

  try {
    // Find the user by email
    const user = await userSchemaModel.findOne({ email });

    // If user doesn't exist, return an error
    if (!user) {
      return res.status(404).json({ success: false, msg: "User not found" });
    }

    // Find all emergency contacts associated with the user's email
    const emergencyContacts = await emergencySchemaModel.find({ userEmail: user.email });

    // If no emergency contacts are found
    if (emergencyContacts.length === 0) {
      return res.status(404).json({ success: false, msg: "No emergency contacts found" });
    }

    // Return success response with the emergency contacts
    res.status(200).json({
      success: true,
      msg: "Emergency contacts fetched successfully",
      emergencyContacts
    });
  } catch (err) {
    // If an error occurs, return a failure response
    console.error(err);
    res.status(500).json({
      success: false,
      msg: "Failed to fetch emergency contacts",
      error: err.message
    });
  }
};
// export const deleteContact = async (req, res) => {
//   // Extract email and contact ID from the request body
//   const { email, contactId } = req.body;

//   // Validate the inputs
//   if (!email || !contactId) {
//     return res.status(400).json({ success: false, msg: "Email and contact ID are required" });
//   }

//   try {
//     // Find the user by email
//     const user = await userSchemaModel.findOne({ email });

//     // If user doesn't exist, return an error
//     if (!user) {
//       return res.status(404).json({ success: false, msg: "User not found" });
//     }

//     // Find and delete the emergency contact by its ID and userEmail (to make sure it's the correct user's contact)
//     const result = await emergencySchemaModel.deleteOne({ _id: contactId, userEmail: user.email });

//     // If no contact was deleted, it means the contact does not exist
//     if (result.deletedCount === 0) {
//       return res.status(404).json({ success: false, msg: "Emergency contact not found or not associated with this user" });
//     }

//     // Return success response
//     res.status(200).json({
//       success: true,
//       msg: "Emergency contact deleted successfully"
//     });
//   } catch (err) {
//     // If an error occurs, return a failure response
//     console.error(err);
//     res.status(500).json({
//       success: false,
//       msg: "Failed to delete emergency contact",
//       error: err.message
//     });
//   }
// };
