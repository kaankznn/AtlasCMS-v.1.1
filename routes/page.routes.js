const express = require("express");
const router = express.Router();
const pages = require("../controllers/pages.controller");

router.get("/posts/:id", pages.show);

module.exports = router;
