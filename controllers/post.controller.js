const db = require("../db");

const normalizeStatus = (status) => (status === "draft" ? "draft" : "published");

exports.list = async (req, res) => {
  try {
    const q = (req.query.q || "").trim();
    const category = req.query.category || "all";
    const status = req.query.status || "all";

    const where = [];
    const params = [];

    if (q) {
      where.push("(y.baslik LIKE ? OR y.icerik LIKE ?)");
      params.push(`%${q}%`, `%${q}%`);
    }

    if (category !== "all") {
      where.push("y.kategori_id = ?");
      params.push(category);
    }

    if (status !== "all") {
      where.push("y.durum = ?");
      params.push(status);
    }

    const whereSql = where.length ? `WHERE ${where.join(" AND ")}` : "";

    const [posts] = await db.query(
      `
        SELECT y.yazi_id AS post_id,
               y.baslik AS title,
               y.durum AS status,
               y.olusturma_tarihi AS created_at,
               c.kategori_adi AS category
        FROM yazilar y
        LEFT JOIN kategoriler c ON y.kategori_id = c.kategori_id
        ${whereSql}
        ORDER BY y.olusturma_tarihi DESC
      `,
      params
    );

    const [categories] = await db.query(
      `SELECT kategori_id AS category_id, kategori_adi AS category_name
       FROM kategoriler
       ORDER BY kategori_adi`
    );

    const [[stats]] = await db.query(
      `
        SELECT
          COUNT(*) AS total,
          SUM(CASE WHEN durum = 'published' THEN 1 ELSE 0 END) AS published,
          SUM(CASE WHEN durum = 'draft' THEN 1 ELSE 0 END) AS drafts
        FROM yazilar
      `
    );

    const [[categoryStats]] = await db.query(
      `SELECT COUNT(*) AS categories FROM kategoriler`
    );

    res.render("dashboard", {
      posts,
      categories,
      filters: { q, category, status },
      stats: {
        total: stats.total || 0,
        published: stats.published || 0,
        drafts: stats.drafts || 0,
        categories: categoryStats.categories || 0
      }
    });
  } catch (err) {
    console.error("POST LIST ERROR:", err);
    res.status(503).render("error", {
      title: "Database unavailable",
      message: "We could not load posts right now. Please try again soon."
    });
  }
};

exports.showCreate = async (req, res) => {
  try {
    const [categories] = await db.query(
      `SELECT kategori_id AS category_id, kategori_adi AS category_name
       FROM kategoriler
       ORDER BY kategori_adi`
    );
    res.render("create-post", { categories, defaultStatus: "published" });
  } catch (err) {
    console.error("POST CREATE VIEW ERROR:", err);
    res.status(503).render("error", {
      title: "Database unavailable",
      message: "We could not load the editor right now. Please try again soon."
    });
  }
};

exports.create = async (req, res) => {
  try {
    const { title, content, category_id } = req.body;
    const status = normalizeStatus(req.body.status);

    await db.query(
      `INSERT INTO yazilar(kullanici_id, kategori_id, baslik, icerik, durum)
       VALUES (?, ?, ?, ?, ?)`,
      [req.session.user.id, category_id, title, content, status]
    );

    res.redirect("/dashboard/posts");
  } catch (err) {
    console.error("POST CREATE ERROR:", err);
    res.status(503).render("error", {
      title: "Database unavailable",
      message: "We could not save the post right now. Please try again soon."
    });
  }
};

exports.showEdit = async (req, res) => {
  try {
    const postId = req.params.id;

  const [[post]] = await db.query(
    `SELECT yazi_id AS post_id,
            baslik AS title,
            icerik AS content,
            durum AS status,
            kategori_id AS category_id
     FROM yazilar
     WHERE yazi_id = ? AND kullanici_id = ?`,
    [postId, req.session.user.id]
  );
  if (!post) return res.status(403).render("error", {
    title: "Access denied",
    message: "You are not privileged to edit this post."
  });

    const [categories] = await db.query(
      `SELECT kategori_id AS category_id, kategori_adi AS category_name
       FROM kategoriler
       ORDER BY kategori_adi`
    );
    res.render("edit-posts", { post, categories });
  } catch (err) {
    console.error("POST EDIT VIEW ERROR:", err);
    res.status(503).render("error", {
      title: "Database unavailable",
      message: "We could not load the post editor right now. Please try again soon."
    });
  }
};

exports.update = async (req, res) => {
  try {
    const postId = req.params.id;
    const { title, content, category_id } = req.body;
    const status = normalizeStatus(req.body.status);

  const [result] = await db.query(
    `UPDATE yazilar
     SET baslik = ?, icerik = ?, kategori_id = ?, durum = ?
     WHERE yazi_id = ? AND kullanici_id = ?`,
    [title, content, category_id, status, postId, req.session.user.id]
  );

  if (!result.affectedRows) {
    return res.status(403).render("error", {
      title: "Access denied",
      message: "You are not privileged to update this post."
    });
  }

    res.redirect("/dashboard/posts");
  } catch (err) {
    console.error("POST UPDATE ERROR:", err);
    res.status(503).render("error", {
      title: "Database unavailable",
      message: "We could not update the post right now. Please try again soon."
    });
  }
};

exports.remove = async (req, res) => {
  try {
    const postId = req.params.id;
  const [result] = await db.query(
    `DELETE FROM yazilar WHERE yazi_id = ? AND kullanici_id = ?`,
    [postId, req.session.user.id]
  );

  if (!result.affectedRows) {
    return res.status(403).render("error", {
      title: "Access denied",
      message: "You are not privileged to delete this post."
    });
  }
    res.redirect("/dashboard/posts");
  } catch (err) {
    console.error("POST DELETE ERROR:", err);
    res.status(503).render("error", {
      title: "Database unavailable",
      message: "We could not delete the post right now. Please try again soon."
    });
  }
};
