import * as core from "@actions/core";

export interface Options {
    strMxamDir: string;
    strArtifact: string;
    strArtifactDir: string;
    strCheckset: string;
    strChecksetDir: string;
};

export function create(): Options {
    return {
        strMxamDir: core.getInput("mxam_dir"),
        strArtifact: core.getInput("artifact"),
        strArtifactDir: core.getInput("artifact_dir"),
        strCheckset: core.getInput("checkset"),
        strChecksetDir: core.getInput("checkset_dir"),
    };
}

export function matlabString(options: Options): string {

    const params = Object.entries(options).map(function([key, value]) {
        if (typeof value == "string") {
            return `${key}='${value}'`;
        } else {
            return `${key}=${value}`;
        }
    });

    return `${params.join('; ')}`;
}