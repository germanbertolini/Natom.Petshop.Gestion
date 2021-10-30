import { User } from "../user.model";

export class LoginResult {
    public User: User;
    public Token: string;
    public Permissions: Array<string>;
}