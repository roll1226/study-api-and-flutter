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
  const todos = await prisma.todo.findMany({
    where: {
      delete_flag: false,
    },
  });
  await prisma.$disconnect();
  res.json(todos);
});

// 詳細取得
app.get("/todos/:id", async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  const todo = await prisma.todo.findUnique({
    where: {
      id,
    },
  });
  await prisma.$disconnect();
  res.json(todo);
});

// 登録
app.post("/todos", async (req: Request, res: Response) => {
  const { title } = req.body;
  const todo = await prisma.todo.create({
    data: {
      title,
    },
  });
  await prisma.$disconnect();
  res.json(todo);
});

// 更新
app.put("/todos/:id", async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  const { title } = req.body;
  const todo = await prisma.todo.update({
    where: {
      id,
    },
    data: {
      title,
    },
  });
  await prisma.$disconnect();
  res.json(todo);
});

// 削除
app.delete("/todos/:id", async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  const todo = await prisma.todo.update({
    where: {
      id,
    },
    data: {
      delete_flag: true,
    },
  });
  await prisma.$disconnect();
  res.json(todo);
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
