import type { CreateUser, User } from "./contracts.js";

export async function createUser(input: CreateUser): Promise<User> {
  return { id: crypto.randomUUID(), ...input };
}
