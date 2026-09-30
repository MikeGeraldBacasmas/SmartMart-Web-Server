const router  = require("express").Router();
const bcrypt  = require("bcryptjs");
const { pool, call } = require("../db");
const { authenticate, requireRole } = require("../middleware/auth");

// GET /api/customers  — registered
router.get("/", authenticate, requireRole("admin", "staff"), async (_req, res) => {
  try {
    res.json(await call("sp_get_registered_customers"));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/customers/pending
router.get("/pending", authenticate, requireRole("admin"), async (_req, res) => {
  try {
    res.json(await call("sp_get_pending_customers"));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/customers/register  — public, no auth
router.post("/register", async (req, res) => {
  const { last_name, first_name, middle_name, address,
          date_of_birth, civil_status, gender, phone,
          discount_type, discount_id_no } = req.body;

  if (!last_name || !first_name || !address || !date_of_birth
      || !civil_status || !gender || !phone)
    return res.status(400).json({ error: "All required fields must be provided" });

  try {
    const rows = await call(
      "sp_submit_customer_registration",
      [last_name, first_name, middle_name || null, address,
       date_of_birth, civil_status, gender, phone]
    );
    const result = rows?.[0] || {};

    if (result.customer_id && (discount_type === "Senior Citizen" || discount_type === "PWD") && discount_id_no?.trim()) {
      await pool.query(
        "UPDATE customers SET discount_type = ?, discount_id_no = ? WHERE id = ?",
        [discount_type, discount_id_no.trim(), result.customer_id]
      );
    }

    res.status(201).json({ message: "Registration submitted", customer_id: result.customer_id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/customers/my-profile — customer fetches own profile
router.get("/my-profile", authenticate, requireRole("customer"), async (req, res) => {
  try {
    const rows = await call("sp_get_customer_profile", [req.user.id]);
    if (!rows || rows.length === 0)
      return res.status(404).json({ error: "Customer profile not found" });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/customers/my-profile — customer updates own profile
router.put("/my-profile", authenticate, requireRole("customer"), async (req, res) => {
  const { first_name, last_name, middle_name, address,
          phone, gender, civil_status, date_of_birth,
          discount_type, discount_id_no } = req.body;

  if (!first_name || !last_name || !address || !phone
      || !gender || !civil_status || !date_of_birth)
    return res.status(400).json({ error: "All required fields must be provided" });

  try {
    const rows = await call("sp_update_customer_profile", [
      req.user.id, first_name, last_name, middle_name || null,
      address, phone, gender, civil_status, date_of_birth,
    ]);
    const updated = rows?.[0];
    if (!updated)
      return res.status(404).json({ error: "Customer profile not found" });

    if (discount_type !== undefined) {
      const dtype = (discount_type === "Senior Citizen" || discount_type === "PWD") ? discount_type : "None";
      const did = dtype !== "None" ? (discount_id_no?.trim() || null) : null;
      await pool.query("UPDATE customers SET discount_type = ?, discount_id_no = ? WHERE user_id = ?", [dtype, did, req.user.id]);
      updated.discount_type = dtype;
      updated.discount_id_no = did;
    }

    res.json({ message: "Profile updated successfully", profile: updated });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/customers/:id/discount — admin/staff updates customer's discount status and ID
router.put("/:id/discount", authenticate, requireRole("admin", "staff"), async (req, res) => {
  const { discount_type, discount_id_no } = req.body;
  const dtype = (discount_type === "Senior Citizen" || discount_type === "PWD") ? discount_type : "None";
  const did = dtype !== "None" ? (discount_id_no?.trim() || null) : null;
  try {
    await pool.query(
      "UPDATE customers SET discount_type = ?, discount_id_no = ? WHERE id = ?",
      [dtype, did, req.params.id]
    );
    res.json({ message: "Customer discount status updated", discount_type: dtype, discount_id_no: did });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/customers/:id/approve
router.post("/:id/approve", authenticate, requireRole("admin"), async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password)
    return res.status(400).json({ error: "username and password are required" });

  try {
    const hash = await bcrypt.hash(password, 10);
    await call("sp_approve_customer", [req.params.id, username, hash, password]);
    res.json({ message: "Customer approved" });
  } catch (err) {
    if (err.message.includes("Username already exists"))
      return res.status(409).json({ error: err.message });
    res.status(500).json({ error: err.message });
  }
});

// POST /api/customers/:id/deny
router.post("/:id/deny", authenticate, requireRole("admin"), async (req, res) => {
  try {
    await call("sp_deny_customer", [req.params.id]);
    res.json({ message: "Customer denied" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
