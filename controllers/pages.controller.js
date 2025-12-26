const db = require("../db");

exports.show = async (req, res) => {
  try {
    const postId = req.params.id;
    const [[post]] = await db.query(
      `
        SELECT y.yazi_id AS post_id,
               y.baslik AS title,
               y.icerik AS content,
               y.olusturma_tarihi AS created_at,
               c.kategori_adi AS category
        FROM yazilar y
        JOIN kategoriler c ON y.kategori_id = c.kategori_id
        WHERE y.yazi_id = ? AND y.durum = 'published'
      `,
      [postId]
    );

    if (!post) {
      return res.status(404).render("public-error", {
        title: "Post not found",
        message: "The post you are looking for does not exist.",
        layout: false
      });
    }

    res.render("post", { post, layout: false });
  } catch (err) {
    console.error("POST PAGE ERROR:", err);
    res.status(503).render("public-error", {
      title: "Database unavailable",
      message: "We could not load this post right now. Please try again soon.",
      layout: false
    });
  }
};
