import { IUser } from "../entities/user.entity";

export interface UserRepository {
  save(user: IUser): Promise<void>;
}
