import * as core from "@actions/core";
import * as exec from "@actions/exec";
import * as matlab from "./matlab_run_command/matlab";
import * as script from "./script";
import * as params from "./options";

/**
 * Gather action inputs and then run action.
 */
 async function run() {
    const platform = process.platform;
    const workspaceDir = process.cwd();

    const command = script.generateCommand(params.create());

    const helperScript = await core.group("Generate script", async () => {
        const helperScript = await matlab.generateScript(workspaceDir, command);
        core.info("Successfully generated script");
        return helperScript;
    });

    await core.group("Run command", async () => {
        await matlab.runCommand(helperScript, platform, exec.exec);
    });
}

run().catch((e) => {
    core.setFailed(e);
});