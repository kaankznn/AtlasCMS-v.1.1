const db = require("../db");

const bcrypt = require("bcrypt");

exports.list = async (req, res) => {
  try {
    const [users] = await db.query(
      `
        SELECT kullanici_id AS user_id,
               kullanici_adi AS username,
               eposta AS email,
               olusturma_tarihi AS created_at
        FROM kullanicilar
        ORDER BY olusturma_tarihi DESC
      `
    );

    res.render("users", { users, formError: null });
  } catch (err) {
    console.error("USERS LIST ERROR:", err);
    res.status(503).render("error", {
      title: "Database unavailable",
      message: "We could not load users right now. Please try again soon."
    });
  }
};

exports.create = async (req, res) => {
  try {
    const username = (req.body.username || "").trim();
    const email = (req.body.email || "").trim() || null;
    const password = req.body.password || "";

    if (!username || password.length < 8) {
      const [users] = await db.query(
        `SELECT kullanici_id AS user_id,
                kullanici_adi AS username,
                eposta AS email,
                olusturma_tarihi AS created_at
         FROM kullanicilar
         ORDER BY olusturma_tarihi DESC`
      );
      return res.status(400).render("users", {
        users,
        formError: "Username is required and password must be at least 8 characters."
      });
    }

    const [existing] = await db.query(
      `SELECT kullanici_id FROM kullanicilar WHERE kullanici_adi = ?`,
      [username]
    );

    if (existing.length) {
      const [users] = await db.query(
        `SELECT kullanici_id AS user_id,
                kullanici_adi AS username,
                eposta AS email,
                olusturma_tarihi AS created_at
         FROM kullanicilar
         ORDER BY olusturma_tarihi DESC`
      );
      return res.status(409).render("users", {
        users,
        formError: "That username is already taken."
      });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    await db.query(
      `INSERT INTO kullanicilar(kullanici_adi, eposta, sifre_hash) VALUES (?, ?, ?)`,
      [username, email, passwordHash]
    );

    res.redirect("/dashboard/users");
  } catch (err) {
    console.error("USERS CREATE ERROR:", err);
    res.status(503).render("error", {
      title: "Database unavailable",
      message: "We could not create the user right now. Please try again soon."
    });
  }
};

exports.remove = async (req, res) => {
  try {
    const userId = Number(req.params.id);
    if (Number.isNaN(userId)) {
      return res.status(400).render("error", {
        title: "Invalid request",
        message: "User id is not valid."
      });
    }

    if (userId === req.session.user.id) {
      return res.status(403).render("error", {
        title: "Action blocked",
        message: "You cannot delete your own account."
      });
    }

    const [result] = await db.query(
      `DELETE FROM kullanicilar WHERE kullanici_id = ?`,
      [userId]
    );

    if (!result.affectedRows) {
      return res.status(404).render("error", {
        title: "User not found",
        message: "The user you tried to delete does not exist."
      });
    }

    res.redirect("/dashboard/users");
  } catch (err) {
    console.error("USERS DELETE ERROR:", err);
    res.status(503).render("error", {
      title: "Database unavailable",
      message: "We could not delete the user right now. Please try again soon."
    });
  }
};
