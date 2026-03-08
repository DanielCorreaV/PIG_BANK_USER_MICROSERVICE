export interface IUser {
  uuid: string;
  name: string;
  lastName: string;
  email: string;
  phone: string;
  address?: string;
  document: string;
  password?: string;
  avatarUrl?: string;
}
