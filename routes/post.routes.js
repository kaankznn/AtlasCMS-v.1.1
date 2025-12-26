const express = require("express");
const router = express.Router();
const post = require("../controllers/post.controller");
const { requireAuth } = require("../middlewares/auth.middleware");

router.get("/", requireAuth, post.list);

router.get("/create", requireAuth, post.showCreate);
router.post("/create", requireAuth, post.create);

router.get("/edit/:id", requireAuth, post.showEdit);
router.post("/edit/:id", requireAuth, post.update);

router.get("/delete/:id", requireAuth, post.remove);

module.exports = router;
