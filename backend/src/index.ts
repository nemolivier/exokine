import express from "express";
import router from "./router";

const app = express();
const port = 3000;

app.use(express.json());

app.get("/", (req, res) => {
  res.send("Hello World!");
});

app.get("/api/health", (req, res) => {
  res.json({ status: "ok" });
});

app.use('/api', router);

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
