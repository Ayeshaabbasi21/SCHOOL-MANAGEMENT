const express = require("express");
const cors = require("cors");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const Routes = require("./routes/route.js");

dotenv.config();

const app = express();

// Middleware
app.use(express.json({ limit: "10mb" }));
app.use(cors());

// MongoDB connection
mongoose.connect(process.env.MONGO_URL, {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
.then(() => console.log("✅ Connected to MongoDB"))
.catch((err) => console.log("❌ NOT CONNECTED TO NETWORK:", err));

// Routes
app.use("/api", Routes);   // ✅ This prefix fixes your 404 issue

// Default route (optional)
app.get("/", (req, res) => {
    res.send("MERN School Management System API is running...");
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`🚀 Server started at port ${PORT}`);
});
