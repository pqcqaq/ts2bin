import type { CreateUser, User } from "./modules/contracts.js";
import { createUser } from "./modules/service.js";

const input: CreateUser = { name: "Ada" };
const created: Promise<User> = createUser(input);

void created;
