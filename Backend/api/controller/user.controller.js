import '../models/connection.js'
import url from 'url'
import jwt from 'jsonwebtoken'
import rs from 'randomstring'
import userSchemaModel from '../models/user.model.js'; //model ko import kiya
import sendMail from './emailcontroller.js';
import { error } from 'console';
import { sendEmailOTP, sendSMSOTP } from './otp.controller.js';

//is file pr user related task ke function create krenge
export const save =async(req,res)=>{
    // console.log("its working") //to check
    var userList=await userSchemaModel.find(); //return array of objs from database
    console.log(userList);
    var len = userList.length; //find total number of obj in arr
    // console.log(len);
    // var _id=userList[len-1]._id; // find id of last obj
    // console.log(_id)
    var _id=(len==0)?1:userList[len-1]._id+1; // If len == 0 (i.e., no users exist in the database), _id is set to 1.Otherwise, _id is assigned as last user's ID + 1.
    
    // console.log(_id);

   
    var userDetail=req.body //body se data nikal kr apko obj return krega jisko ham ek var me store ya get kr skte h
    // console.log(userDetail);

    //spread operators are used to append the key values pair in previous object {...object_name} 
    //this will add 4 more fields in previous 7 data fields
    userDetail={...userDetail,"_id":_id,"role":"user","status":0,"info":Date()};
    console.log(userDetail);

    
    try{
        //method created obj return krega
       // The create method inserts the new user document into the database.

        // Check if user already exists
        const existingUser = await userSchemaModel.findOne({
            $or: [
                { email: userDetail.email },
                { mobile: userDetail.mobile }
            ]
        });

        if (existingUser) {
            return res.status(400).json({
                success: false,
                message: "User with this email or phone number already exists"
            });
        }

        // Create new user
        var user = await userSchemaModel.create(userDetail);
    //by default async hoti h iske liye hme await method call krna pdega aur jiske liye method call ho rhi h usko bhi ascyn bnana pdega
        console.log(user)

        // Send verification OTP
        let verificationResult;
        if (userDetail.verificationType === 'email') {
            verificationResult = await sendEmailOTP(user.email);
        } else {
            verificationResult = await sendSMSOTP(user.mobile);
        }

        if (!verificationResult.success) {
            // If OTP sending fails, delete the user and return error
            await userSchemaModel.findByIdAndDelete(user._id);
            return res.status(500).json({
                success: false,
                message: "Registration failed: Could not send verification code"
            });
        }

        res.status(200).json({
            success: true,
            message: "Registration successful. Please verify your account.",
            user: user,
            verificationId: verificationResult.verificationId
        });
    }
    catch(err){
        res.status(500).json({"success":false,"message":"registration failed",
        "error":err.message
        });
        console.log(err)
    }
    

    //res.send("controller working"); //to check
   
}
export const verifyUser = async (req, res) => {
    try {
        const email = req.params.email;

        const user = await userSchemaModel.findOne({ email });

        if (!user) {
            return res.status(404).json({ success: false, message: "User not found" });
        }

        user.status = 1;
        user.__v = 1;

        await user.save();

        res.status(200).json({ success: true, message: "Account verified successfully!" });
    } catch (err) {
        res.status(500).json({ success: false, message: "Verification failed", error: err.message });
    }
};
export const addEmergencyContact = async (req, res) => {
  const { email, contact } = req.body;

  // Check if all required fields are provided
  if (!email || !contact || !contact.name || !contact.relation || !contact.mobile) {
    return res.status(400).json({ success: false, msg: "Missing required fields (name, relation, mobile)" });
  }

  try {
    // Find the user by email
    const user = await userSchemaModel.findOne({ email });

    if (!user) {
      return res.status(404).json({ success: false, msg: "User not found" });
    }

    // Initialize emergencyContacts array if not present
    user.emergencyContacts = user.emergencyContacts || [];

    // Add the new contact with name, relation, and mobile
    user.emergencyContacts.push({
      name: contact.name,
      relation: contact.relation,
      mobile: contact.mobile
    });

    // Save the updated user document
    await user.save();

    // Send success response
    res.status(200).json({ success: true, msg: "Emergency contact saved successfully", user });
  } catch (err) {
    // Handle errors
    res.status(500).json({ success: false, msg: "Error saving contact", error: err.message });
  }
};


export const fetch = async (req, res) => {
    // Extract userId and location from the POST body
    const { userId, latitude, longitude } = req.body;
   

    try {
        // Find user by their _id (passed as userId in request)
        const user = await userSchemaModel.find(userId);
        //  console.log(user)

        if (user && user.location) {
            res.status(200).json({
                location: user.location,
                msg: "Location fetched successfully"
            });
        } else {
            res.status(404).json({ msg: "User or location not found" });
        }
    } catch (err) {
        res.status(500).json({ msg: "Server error", error: err.message });
    }
};
export const updateLocation = async (req, res) => {
  const { email, location } = req.body;
  if (!email || !location) {
    return res.status(400).json({ msg: "Missing email or location" });
  }

  try {
    const updated = await userSchemaModel.updateOne(
      { email },
      { $set: { location: { ...location, timestamp: new Date() } } }
    );

    if (updated.modifiedCount > 0) {
      res.status(200).json({ msg: "Location updated successfully" });
    } else {
      res.status(404).json({ msg: "User not found or no update made" });
    }
  } catch (err) {
    res.status(500).json({ msg: "Server error", error: err.message });
  }
};


export const update=async(req,res)=>{
    //phle check krenge ky data already available h agr nhi h toh ud
    // react by default json me hi pass krta h so no need of json.parse
    // var users = await userSchemaModel.findOne(JSON.parse(req.body.condition_obj));
    var users = await userSchemaModel.findOne(req.body.condition_obj);
    // console.log(users)
    if(users){
        // var userDetail=await userSchemaModel.updateOne(JSON.parse(req.body.condition_obj),{$set:(JSON.parse(req.body.content_obj))})
        var userDetail=await userSchemaModel.updateOne(req.body.condition_obj,{$set:req.body.content_obj})
        console.log(userDetail)
        if(userDetail){
            res.status(200).json({"msg":"user updated successfully"})
        }
        else{
            res.status(500).json({"msg":"user not updated sucessfully"})
        }
    }
    else{
        res.status(404).json({"msg":"user not found"})
    }
}
export const deleteUser=async(req,res)=>{
    // var users = await userSchemaModel.findOne(JSON.parse(req.body.condition_obj));
    var users= await userSchemaModel.findOne(req.body);
    console.log(users)
    if(users){
        // var userDetail=await userSchemaModel.deleteOne(JSON.parse(req.body.condition_obj))
        var userDetail=await userSchemaModel.deleteOne(req.body)
        if(userDetail){
            res.status(200).json({"msg":"user deleted successfully"})
        }
        else{
            res.status(500).json({"msg":"user not deleted sucessfully"})
        }
    }
    else{
        res.status(404).json({"msg":"user not found"})
    }

}

export const login = async (req, res) => {
<<<<<<< HEAD
    const { email, aadhaar, password } = req.body;
    
    if (!email && !aadhaar) {
        return res.status(400).json({
            "error": "Email or Aadhaar is required for login"
        });
    }

    const condition_obj = { "status": 1 };  // Only allow verified users to login

    if (email) {
        condition_obj.email = email;
    } else if (aadhaar) {
        condition_obj.aadhar_no = aadhaar;
    }

    try {
        const user = await userSchemaModel.find(condition_obj);

        if (user.length !== 0) {
            if (user[0].password !== password) {
                return res.status(401).json({
                    "error": "Invalid password"
                });
            }

            const payload = { "subject": user[0].email };
            const key = rs.generate();
            const token = jwt.sign(payload, key);

            res.status(200).json({
                "token": token,
                "userList": user[0]
            });
        } else {
            res.status(404).json({
                "error": "User not found or not verified. Please check your credentials."
            });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({
            "error": "Server error, please try again later."
=======
  const { email, aadhaar, password } = req.body;
  
  // Check if either email or Aadhaar is provided, and password is given
  if (!email && !aadhaar) {
    
    return res.status(400).json({
      "error": "Email or Aadhaar is required for login"
      
    });
  }

  const condition_obj = { "status": 1 };  // Adding status check to filter active users

  // Add email or Aadhaar to the condition based on which one is provided
  if (email) {
    condition_obj.email = email;
  } else if (aadhaar) {
    condition_obj.aadhar_no = aadhaar;
}

  try {
    // Check if the user exists in the database based on the condition
    const user = await userSchemaModel.find(condition_obj);

    if (user.length !== 0) {
      // User found, validate password (You may use bcrypt for actual password checking)
      if (user[0].password !== password) {
        return res.status(401).json({
          "error": "Invalid password"
>>>>>>> 978a57669a192ede359381f40e300cf981ae96a4
        });
    }
};
