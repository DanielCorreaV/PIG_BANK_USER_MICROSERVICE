import joi from "joi";
import { IUser } from "../../domain/entities/user.entity";

export const registerUserSchema = joi.object<IUser>({
  name: joi.string().required(),
  lastName: joi.string().required(),
  email: joi.string().required(),
  documentNumber: joi.number().required(),
  password: joi.string().required(),
  avatarUrl: joi.string(),
});
