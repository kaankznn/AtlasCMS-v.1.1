const express = require("express");
const router = express.Router();
const auth = require("../controllers/auth.controller");

router.get("/", auth.showLogin);
router.post("/login", auth.login);
router.get("/logout", auth.logout);

module.exports = router;