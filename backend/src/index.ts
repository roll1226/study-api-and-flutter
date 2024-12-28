import { PrismaClient } from "@prisma/client";
import { configDotenv } from "dotenv";
import express, { Request, Response } from "express";

const prisma = new PrismaClient();

configDotenv();

const app = express();
app.use(express.json());
const port = process.env.PORT || 3000;

// 一覧取得
app.get("/todos", async (req: Request, res: Response) => {
  try {
    const todos = await prisma.todo.findMany({
      where: {
        deleteFlag: false,
      },
    });
    res.json(todos);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch todos" });
  }
});

// 詳細取得
app.get("/todos/:id", async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  try {
    const todo = await prisma.todo.findUnique({
      where: { id },
    });
    if (todo) {
      res.json(todo);
    } else {
      res.status(404).json({ error: "Todo not found" });
    }
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch todo" });
  }
});

// 登録
app.post("/todos", async (req: Request, res: Response) => {
  const { title } = req.body;
  try {
    const todo = await prisma.todo.create({
      data: { title },
    });
    res.json(todo);
  } catch (error) {
    res.status(500).json({ error: "Failed to create todo" });
  }
});

// 更新
app.put("/todos/:id", async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  const { title } = req.body;
  try {
    const todo = await prisma.todo.update({
      where: { id },
      data: { title, updatedAt: new Date() },
    });
    res.json(todo);
  } catch (error) {
    res.status(404).json({ error: "Todo not found or failed to update" });
  }
});

// 削除
app.delete("/todos/:id", async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  try {
    const todo = await prisma.todo.update({
      where: { id },
      data: { deleteFlag: true, updatedAt: new Date() },
    });
    res.json(todo);
  } catch (error) {
    res.status(404).json({ error: "Todo not found or already deleted" });
  }
});

// Prisma の切断
process.on("SIGINT", async () => {
  await prisma.$disconnect();
  console.log("Prisma disconnected");
  process.exit(0);
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
