const router  = require("express").Router();
const path    = require("path");
const fs      = require("fs");
const multer  = require("multer");
const { pool, call } = require("../db");
const { authenticate, requireRole } = require("../middleware/auth");

// ─── Multer config for product images ─────────────────────────
const uploadDir = path.join(__dirname, "..", "uploads", "products");
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadDir),
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `product_${Date.now()}${ext}`);
  },
});
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
  fileFilter: (_req, file, cb) => {
    const allowed = /jpeg|jpg|png|gif|webp/;
    const ok = allowed.test(path.extname(file.originalname).toLowerCase()) && allowed.test(file.mimetype.replace("image/", ""));
    cb(ok ? null : new Error("Only image files are allowed"), ok);
  },
});

// GET /api/products
router.get("/", authenticate, async (_req, res) => {
  try {
    res.json(await call("sp_get_all_products"));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/products/low-stock
router.get("/low-stock", authenticate, requireRole("admin", "staff"), async (_req, res) => {
  try {
    res.json(await call("sp_get_low_stock_products"));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/products
router.post("/", authenticate, requireRole("admin"), async (req, res) => {
  const { name, category_id, price, stock } = req.body;
  if (!name || !category_id || price == null || stock == null)
    return res.status(400).json({ error: "name, category_id, price and stock are required" });

  try {
    const conn = await pool.getConnection();
    try {
      await conn.query("CALL sp_create_product(?,?,?,?,@pid)",
        [name, category_id, price, stock]);
      const [[r]] = await conn.query("SELECT @pid AS product_id");
      res.status(201).json({ product_id: r.product_id, name, category_id, price, stock });
    } finally {
      conn.release();
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/products/:id  — full product update
router.put("/:id", authenticate, requireRole("admin"), async (req, res) => {
  const { name, category_id, price, stock, image_url } = req.body;
  if (!name || !category_id || price == null || stock == null)
    return res.status(400).json({ error: "name, category_id, price and stock are required" });

  try {
    await call("sp_update_product", [req.params.id, name, category_id, price, stock, image_url || null]);
    res.json({ message: "Product updated" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/products/:id/image  — upload product image
router.post("/:id/image", authenticate, requireRole("admin"), upload.single("image"), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: "No image uploaded" });

  const imageUrl = `/uploads/products/${req.file.filename}`;
  try {
    // Update only the image_url column
    await pool.execute("UPDATE products SET image_url = ? WHERE id = ?", [imageUrl, req.params.id]);
    res.json({ image_url: imageUrl });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PATCH /api/products/:id/stock
router.patch("/:id/stock", authenticate, requireRole("admin"), async (req, res) => {
  const { stock } = req.body;
  if (stock == null) return res.status(400).json({ error: "stock is required" });

  try {
    await call("sp_update_product_stock", [req.params.id, stock]);
    res.json({ message: "Stock updated" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
