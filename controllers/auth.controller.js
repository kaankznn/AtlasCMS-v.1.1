const bcrypt = require("bcrypt");
const db = require("../db");

exports.showLogin = (req, res) => {
  res.render("login", { layout: false, formError: null });
};

exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;

    const [rows] = await db.query(
      "SELECT kullanici_id, sifre_hash FROM kullanicilar WHERE kullanici_adi = ?",
      [username]
    );

    if (!rows.length) {
      return res.status(401).render("login", {
        layout: false,
        formError: "Invalid username or password."
      });
    }

    const user = rows[0];

    const match = await bcrypt.compare(password, user.sifre_hash);

    if (!match) {
      return res.status(401).render("login", {
        layout: false,
        formError: "Invalid username or password."
      });
    }

    req.session.user = { id: user.kullanici_id };
    res.redirect("/dashboard/posts");

  } catch (err) {
    console.error("LOGIN ERROR:", err);
    res.send("Login crashed: " + err.message);
  }
};

exports.logout = (req, res) => {
  req.session.destroy(() => res.redirect("/"));
};
