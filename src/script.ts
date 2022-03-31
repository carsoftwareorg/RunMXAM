import * as path from "path";
import { Options, matlabString } from "./options";

export function generateCommand(options: Options): string {
    const command = `
        addpath('${path.join(__dirname, "script")}');
        ${matlabString(options)};
        main;
    `
    .replace(/$\n^\s*/gm, " ")
    .trim();

    return command;
}