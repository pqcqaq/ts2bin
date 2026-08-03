export {};

type Identified = { id: string };

abstract class Repository<T extends Identified> {
  abstract find(id: string): Promise<T | undefined>;
  abstract save(entity: T): Promise<void>;
}

class Service<T extends Identified> {
  constructor(private readonly repository: Repository<T>) {}

  async require(id: string): Promise<T> {
    const entity = await this.repository.find(id);
    if (!entity) throw new Error(`Missing entity: ${id}`);
    return entity;
  }
}

class Query {
  protected parts: string[] = [];
  where(condition: string): this {
    this.parts.push(condition);
    return this;
  }
}

class UserQuery extends Query {
  active(): this {
    return this.where("active = true");
  }
}

void [Service, new UserQuery().where("role = 'admin'").active()];
