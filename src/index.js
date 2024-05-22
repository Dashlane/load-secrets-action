import { getExecOutput } from "@actions/exec";

const main = () => {
    getExecOutput(`./src/script.sh`);
};

main();
