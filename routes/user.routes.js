const express = require("express");
const router = express.Router();
const users = require("../controllers/users.controller");
const { requireAuth } = require("../middlewares/auth.middleware");

router.get("/dashboard/users", requireAuth, users.list);
router.post("/dashboard/users/create", requireAuth, users.create);
router.post("/dashboard/users/delete/:id", requireAuth, users.remove);

module.exports = router;
