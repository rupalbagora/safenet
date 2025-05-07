import express from 'express'
import url from 'url'
import * as userController from '../controller/user.controller.js'
import * as otpController from '../controller/otp.controller.js'

const router= express.Router();
//router path match kre uske phle controller ko link kre
//to link controller on router file
//sbhi func ka instance bnao or var me get kr lo

//sbse phle method type check hoga
router.post("/register", userController.save) //check path and send control to userController
router.get("/fetch",userController.fetch);
router.patch("/update",userController.update)
router.delete("/delete",userController.deleteUser)
<<<<<<< HEAD
router.post("/login", userController.login)

// OTP verification routes
router.post("/verify-otp", otpController.verifyOTP);
router.post("/resend-otp", otpController.resendOTP);
=======
router.post("/login",userController.login)
router.post("/updateLocation",userController.updateLocation)
router.get('/verify/:email', userController.verifyUser);
router.post("/addEmergencyContact", userController.addEmergencyContact);
>>>>>>> 978a57669a192ede359381f40e300cf981ae96a4

export default router;

//base url check krne ke liye app.use krte h - only request ko yad rkhte ke liye use krte h
// hmesha configuration ko yad rkhne ke liye app.set use krte h