import express from "express";
import type { Request, Response, NextFunction } from "express";
import path from "path";
import expressSession from "express-session";
import pg from "pg";
import grant from "grant";
import dotenv from "dotenv";
dotenv.config();

export const dbClient = new pg.Client({
  database: process.env.DB_NAME,
  user: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
});
dbClient.connect();

const grantExpress = grant.express({
  defaults: {
    origin: "http://localhost:8080",
    transport: "session",
    state: true,
  },
  google: {
    key: process.env.GOOGLE_CLIENT_ID || "",
    secret: process.env.GOOGLE_CLIENT_SECRET || "",
    scope: ["profile", "email"],
    callback: "/usersLogin/google",
  },
});

declare module "express-session" {
  interface SessionData {
    userIsLoggedIn?: boolean;
    driverIsLoggedIn?: boolean;
    users_id: number;
    drivers_id: number;
    firstName: string;
    loginType: string;
}}

const app = express();

// Section 1: Middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(
  expressSession({
    secret: "group 2 is the best",
    resave: true,
    saveUninitialized: true,
  })
);

app.use(grantExpress as express.RequestHandler);

// logging 用 middleware
app.use((req, _res, next) => {
  console.log(`Path ${req.path}, Method: ${req.method}`);
  next();
});

// Section 2: Route Handlers
import { authRoutes } from "./routers/authRoutes";
import { usersAuthRoutes } from "./routers/usersAuthRoutes";
import { usersCreateRoutes } from "./routers/usersCreateRoutes";
import { driversAuthRoutes } from "./routers/driversAuthRouters";
import { driversCreateRoutes } from "./routers/driversCreateRoutes";
import { driversMainRoutes } from "./routers/driversMainRoutes";
import { driverIsLoggedInApi } from "./utils/guard"
// import { userIsLoggedInApi } from "./utils/guard";

app.use("/login", authRoutes);
app.use("/usersLogin", usersAuthRoutes);
app.use("/usersCreate", usersCreateRoutes);
app.use("/driversLogin", driversAuthRoutes);
app.use("/driversCreate", driversCreateRoutes);
app.use("/driversMain", driverIsLoggedInApi, driversMainRoutes);
// app.use("/usersMain",userIsLoggedInApi, usersMainRoutes);

// Section 3: Serve
app.use(express.static(path.join(__dirname, "public")));

const guardUsersMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (req.session.userIsLoggedIn) next();
  else res.sendFile(path.join(__dirname, "public", "index.html"));
};

const guardDriversMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (req.session.driverIsLoggedIn) next();
  else res.sendFile(path.join(__dirname, "public", "index.html"));
};

app.use(
  "/private/usersPrivate",
  guardUsersMiddleware,
  express.static(path.join(__dirname, "private", "usersPrivate"))
);
app.use(
  "/private/driversPrivate",
  guardDriversMiddleware,
  express.static(path.join(__dirname, "private", "driversPrivate"))
);

// Section 4: Error Handling
app.use((_req, res) => {
  res.sendFile(path.join(__dirname, "public", "404.html"));
});

const PORT = 8080;

app.listen(PORT, () => {
  console.log(`Listening at http://localhost:${PORT}/`);
})
