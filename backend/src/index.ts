import { configDotenv } from "dotenv";
import express, { Request, Response } from "express";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

configDotenv();

const app = express();
app.use(express.json());
const port = process.env.PORT || 3000;

app.get("/", (req: Request, res: Response) => {
  res.send("Hello World!");
});

app.get("/todos", async (req: Request, res: Response) => {
  const todos = await prisma.todo.findMany();
  await prisma.$disconnect();
  res.json(todos);
});

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

app.get("/qeury", async (req: Request, res: Response) => {
  const query = req.query;
  console.log(query);
  res.json(query);
});

app.delete("/todos/:id", async (req: Request, res: Response) => {
  const id = Number(req.params.id);
  const todo = await prisma.todo.delete({
    where: {
      id,
    },
  });
  await prisma.$disconnect();
  res.json(todo);
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
