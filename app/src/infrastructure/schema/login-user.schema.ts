import joi from "joi";
import { IUser } from "../../domain/entities/user.entity";

export const loginUserSchema = joi.object<IUser>({
  email: joi.string().required(),
  password: joi.string().required(),
});
