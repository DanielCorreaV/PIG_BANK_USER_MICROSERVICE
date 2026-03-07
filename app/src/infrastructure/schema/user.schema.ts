import joi from "joi";
import { IUser } from "../../domain/entities/user.entity";

export const userSchema = joi.object<IUser>({
  name: joi.string().required(),
  lastName: joi.string().required(),
  email: joi.string().required(),
  documentNumber: joi.number().required(),
  password: joi.string(),
  avatarUrl: joi.string(),
});
