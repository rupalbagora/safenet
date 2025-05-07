import express from 'express';
import url from 'url';

const router = express.Router();

// Import controller functions
import * as emergencyController from '../controller/emergency.controller.js';

// Route to save an emergency contact
// This will call the 'save' method from the emergencyController
router.post("/save", emergencyController.save);

// Route to fetch all emergency contacts for the authenticated user
// This will call the 'fetch' method from the emergencyController
router.get("/fetch", emergencyController.fetch);

// Route to delete an emergency contact by its ID
// This will call the 'deleteContact' method from the emergencyController
// router.delete("/delete", emergencyController.deleteContact);

// Export the router to be used in other parts of the app
export default router;
