// Initialize Express
const express = require("express");
const exphbs = require("express-handlebars");
const bodyParser = require("body-parser");
const path = require("path");
const app = express();
const PORT = process.env.PORT || 3000;

// --- In-memory data store (ephemeral) ---
let payments = [];
let nextPaymentId = 1;

// --- Handlebars Middleware ---
app.engine(
  ".hbs",
  exphbs.engine({
    extname: ".hbs",
    defaultLayout: "main",
    layoutsDir: path.join(__dirname, "views/layouts"),
    partialsDir: path.join(__dirname, "views/partials"),
    helpers: {
      formatCurrency: (amount) => {
        return new Intl.NumberFormat("en-US", {
          style: "currency",
          currency: "USD",
        }).format(amount);
      },
      formatDate: (dateString) => {
        return new Date(dateString).toLocaleDateString("en-US", {
          year: "numeric",
          month: "long",
          day: "numeric",
        });
      },
      date: (dateString) => {
        return new Date(dateString).toLocaleDateString("en-US", {
          year: "numeric",
          month: "long",
          day: "numeric",
        });
      },
      eq: function (v1, v2) {
        return v1 === v2;
      },
    },
  })
);
app.set("view engine", ".hbs");
app.set("views", path.join(__dirname, "views"));
console.info("Handlebars middleware initialized");

// --- Static Folder for CSS, JS, Images ---
app.use(express.static(path.join(__dirname, "public")));
console.info("Static folder middleware initialized");

// --- Body Parser Middleware ---
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
console.info("Body parser middleware initialized");

// --- Routes ---

// GET / - Display Payment Form
app.get("/", (req, res) => {
  console.info("GET / - Displaying payment form");
  res.render("index", {
    title: "Secure Payment Portal",
  });
});

// POST /process-payment - Simulate Payment Processing
app.post("/process-payment", (req, res) => {
  console.info("POST /process-payment - Processing payment request");
  const {
    amount,
    cardNumber,
    expiryDate,
    cvv,
    cardHolderName,
    email,
    address,
    city,
    zipCode,
    country,
  } = req.body;

  // Basic Validation (expand as needed)
  if (
    !amount ||
    !cardNumber ||
    !expiryDate ||
    !cvv ||
    !cardHolderName ||
    !email
  ) {
    console.error("Payment validation failed: Missing required fields");
    return res.status(400).render("index", {
      title: "Secure Payment Portal",
      error: "Please fill in all required fields.",
      formData: req.body, // Repopulate form
    });
  }

  const paymentAmount = parseFloat(amount);
  if (isNaN(paymentAmount) || paymentAmount <= 0) {
    console.error(`Payment validation failed: Invalid amount: ${amount}`);
    return res.status(400).render("index", {
      title: "Secure Payment Portal",
      error: "Invalid payment amount.",
      formData: req.body,
    });
  }

  console.info(`Processing payment of ${paymentAmount} for ${cardHolderName}`);

  // Simulate payment gateway interaction (add delay, random success/failure)
  setTimeout(() => {
    const isSuccess = Math.random() > 0.1; // 90% success rate

    if (isSuccess) {
      const newPayment = {
        id: nextPaymentId++,
        amount: paymentAmount,
        currency: "USD",
        cardNumber: `**** **** **** ${cardNumber.slice(-4)}`, // Mask card number
        cardHolderName,
        email,
        address,
        city,
        zipCode,
        country,
        status: "Completed",
        transactionId:
          `txn_${Date.now()}` + Math.random().toString(36).substring(2, 10),
        createdAt: new Date().toISOString(),
      };
      payments.push(newPayment);

      console.info(
        `Payment successful: ID=${newPayment.id}, Transaction=${newPayment.transactionId}`
      );
      res.redirect(`/confirmation/${newPayment.id}`);
    } else {
      const failedPayment = {
        id: nextPaymentId++,
        amount: paymentAmount,
        cardHolderName,
        email,
        status: "Failed",
        reason: "Simulated gateway decline.",
        createdAt: new Date().toISOString(),
      };
      payments.push(failedPayment);

      console.error(
        `Payment failed: ID=${failedPayment.id}, Reason=${failedPayment.reason}`
      );
      res.status(500).render("index", {
        title: "Secure Payment Portal",
        error:
          "Payment failed. Please try again later or use a different card.",
        formData: req.body,
      });
    }
  }, 2000); // Simulate 2 seconds delay
});

// GET /confirmation/:paymentId - Display Payment Confirmation
app.get("/confirmation/:paymentId", (req, res) => {
  const paymentId = parseInt(req.params.paymentId);
  console.info(
    `GET /confirmation/${paymentId} - Fetching payment confirmation`
  );

  const payment = payments.find((p) => p.id === paymentId);

  if (!payment) {
    console.error(`Payment not found: ID=${paymentId}`);
    return res.status(404).send("Payment not found.");
  }

  if (payment.status !== "Completed") {
    console.error(
      `Payment not completed: ID=${paymentId}, Status=${payment.status}`
    );
    return res.status(400).send("This payment was not successfully completed.");
  }

  console.info(`Displaying confirmation for payment ID=${paymentId}`);
  res.render("confirmation", {
    title: "Payment Confirmation",
    payment,
  });
});

// --- Admin/Debug Route (Optional) ---
app.get("/admin/payments", (req, res) => {
  console.info("GET /admin/payments - Admin accessing all payments");
  res.json(payments);
});

// --- Start Server ---
app.listen(PORT, () => {
  console.info(`Server running on http://localhost:${PORT}`);
});
