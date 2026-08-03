export interface User {
  id: string;
  name: string;
}

export type CreateUser = Omit<User, "id">;
