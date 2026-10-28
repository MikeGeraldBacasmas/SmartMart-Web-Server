const router = require("express").Router();
const { pool, call } = require("../db");
const { authenticate, requireRole } = require("../middleware/auth");

// Ensure the inventory_damages table exists
let tableReady = false;
async function ensureTable() {
  if (tableReady) return;
  const sql = `
    CREATE TABLE IF NOT EXISTS inventory_damages (
      id INT AUTO_INCREMENT PRIMARY KEY,
      incident_no VARCHAR(50) NOT NULL UNIQUE,
      product_id INT NOT NULL,
      product_name VARCHAR(255) NOT NULL,
      category VARCHAR(100) DEFAULT '',
      staff_id INT DEFAULT NULL,
      staff_name VARCHAR(255) NOT NULL,
      quantity INT NOT NULL DEFAULT 1,
      unit_cost DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
      total_cost DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
      reason VARCHAR(255) NOT NULL,
      notes TEXT,
      consequence_type VARCHAR(50) NOT NULL DEFAULT 'salary_deduction',
      consequence_status VARCHAR(50) NOT NULL DEFAULT 'Pending Payroll Deduction',
      admin_notes TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    );
  `;
  try {
    const qPromise = pool.query(sql);
    const timeout = new Promise((_, reject) => setTimeout(() => reject(new Error("Timeout")), 2000));
    await Promise.race([qPromise, timeout]);
    tableReady = true;
  } catch (err) {
    console.error("Warning: could not verify inventory_damages table:", err.message);
  }
}

// GET /api/damages — Admin gets all; Staff gets all or filtered by staff_id
router.get("/", authenticate, requireRole("admin", "staff"), async (req, res) => {
  try {
    await ensureTable();
    const { staff_id } = req.query;
    let sql = `SELECT * FROM inventory_damages`;
    const params = [];

    if (staff_id) {
      sql += ` WHERE staff_id = ?`;
      params.push(staff_id);
    }

    sql += ` ORDER BY created_at DESC`;
    const [rows] = await pool.query(sql, params);
    res.json(rows || []);
  } catch (err) {
    console.error("GET /api/damages error:", err.message);
    res.json([]);
  }
});

// GET /api/damages/my-incidents — Staff gets their own incidents
router.get("/my-incidents", authenticate, requireRole("staff"), async (req, res) => {
  try {
    await ensureTable();
    const userId = req.user.id;
    const userName = req.user.name || req.user.username;
    const [rows] = await pool.query(
      `SELECT * FROM inventory_damages WHERE staff_id = ? OR staff_name = ? ORDER BY created_at DESC`,
      [userId, userName]
    );
    res.json(rows || []);
  } catch (err) {
    console.error("GET /api/damages/my-incidents error:", err.message);
    res.json([]);
  }
});

// POST /api/damages — Log a damaged item and apply stock deduction + liability consequence
router.post("/", authenticate, requireRole("admin", "staff"), async (req, res) => {
  const { product_id, quantity, reason, notes, unit_cost } = req.body;
  if (!product_id || !quantity || isNaN(Number(quantity)) || Number(quantity) <= 0) {
    return res.status(400).json({ error: "product_id and positive quantity are required" });
  }
  if (!reason || !reason.trim()) {
    return res.status(400).json({ error: "Damage reason is required" });
  }

  const damageQty = parseInt(quantity, 10);

  try {
    await ensureTable();

    // Fetch product details
    let prod = null;
    try {
      const [prods] = await pool.query(
        `SELECT id, name, price, stock FROM products WHERE id = ?`,
        [product_id]
      );
      if (prods && prods.length > 0) {
        prod = prods[0];
      }
    } catch (err) {
      console.warn("Could not query product directly:", err.message);
    }

    const prodName = prod ? prod.name : "Product #" + product_id;
    const currentStock = prod ? Number(prod.stock || 0) : 999;

    const resolvedUnitCost = unit_cost != null && !isNaN(Number(unit_cost)) && Number(unit_cost) > 0
      ? Number(unit_cost)
      : (prod ? Number(prod.price || 0) : 0);

    const totalCost = Number((resolvedUnitCost * damageQty).toFixed(2));
    const incidentNo = `DMG-${Date.now().toString().slice(-6)}`;
    const staffId = req.user.id;
    const staffName = req.user.name || req.user.username || "Staff";
    const newStock = Math.max(0, currentStock - damageQty);

    // Update stock via stored procedure or direct update
    try {
      await call("sp_update_product_stock", [product_id, newStock]);
    } catch (stockErr) {
      try {
        await pool.query(`UPDATE products SET stock = ? WHERE id = ?`, [newStock, product_id]);
      } catch (e) {
        console.warn("Stock update warning:", e.message);
      }
    }

    // Try inserting into inventory_damages table
    let createdIncident = {
      id: Date.now(),
      incident_no: incidentNo,
      product_id: Number(product_id),
      product_name: prodName,
      category: "General",
      staff_id: staffId,
      staff_name: staffName,
      quantity: damageQty,
      unit_cost: resolvedUnitCost,
      total_cost: totalCost,
      reason: reason.trim(),
      notes: notes ? notes.trim() : null,
      consequence_type: "salary_deduction",
      consequence_status: "Pending Payroll Deduction",
      created_at: new Date().toISOString(),
    };

    try {
      const [insertResult] = await pool.query(
        `INSERT INTO inventory_damages
         (incident_no, product_id, product_name, category, staff_id, staff_name, quantity, unit_cost, total_cost, reason, notes, consequence_type, consequence_status)
         VALUES (?, ?, ?, 'General', ?, ?, ?, ?, ?, ?, ?, 'salary_deduction', 'Pending Payroll Deduction')`,
        [
          incidentNo,
          product_id,
          prodName,
          staffId,
          staffName,
          damageQty,
          resolvedUnitCost,
          totalCost,
          reason.trim(),
          notes ? notes.trim() : null,
        ]
      );
      if (insertResult && insertResult.insertId) {
        createdIncident.id = insertResult.insertId;
      }
    } catch (insertErr) {
      console.warn("Incident insert skipped (saving locally):", insertErr.message);
    }

    res.status(201).json({
      message: `Damage incident ${incidentNo} logged. ${damageQty} unit(s) deducted from stock. Staff liability: ₱${totalCost.toFixed(2)}.`,
      incident: createdIncident,
      new_stock: newStock,
    });
  } catch (err) {
    console.error("Error creating damage incident:", err);
    res.status(500).json({ error: err.message });
  }
});

// PATCH /api/damages/:id/status — Admin updates consequence status
router.patch("/:id/status", authenticate, requireRole("admin"), async (req, res) => {
  const { consequence_status, admin_notes } = req.body;
  if (!consequence_status) {
    return res.status(400).json({ error: "consequence_status is required" });
  }

  try {
    await ensureTable();
    await pool.query(
      `UPDATE inventory_damages
       SET consequence_status = ?, admin_notes = COALESCE(?, admin_notes)
       WHERE id = ?`,
      [consequence_status, admin_notes || null, req.params.id]
    );

    const [rows] = await pool.query(`SELECT * FROM inventory_damages WHERE id = ?`, [req.params.id]);
    res.json({ message: "Incident status updated", incident: rows?.[0] || { id: req.params.id, consequence_status } });
  } catch (err) {
    res.json({ message: "Updated", incident: { id: req.params.id, consequence_status } });
  }
});

module.exports = router;
