exports.requireAuth = (req, res, next) => {
  if (!req.session.user) {
    return res.status(403).render("auth-error", {
      layout: false,
      title: "Authorization required",
      message: "You are not privileged to access this area. Please log in."
    });
  }
  next();
};
