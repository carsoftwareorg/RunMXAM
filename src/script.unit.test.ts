import * as script from "./script";
import {Options} from "./options";

describe("command generation", () => {
    it("contains correct parameter values", () => {
        const options: Options = {
            strMxamDir: "test",
            strArtifact: "test",
            strArtifactDir: "test",
            strCheckset: "test",
            strChecksetDir: "test"
        };

        const actual = script.generateCommand(options);

        expect(actual.includes("strArtifact='test';")).toBeTruthy();
        expect(actual.includes("strArtifactDir='test';")).toBeTruthy();
        expect(actual.includes("strMxamDir='test';")).toBeTruthy();
        expect(actual.includes("strCheckset='test';")).toBeTruthy();
        expect(actual.includes("strChecksetDir='test';")).toBeTruthy();
        expect(actual.includes("; main;")).toBeTruthy();

    });

});