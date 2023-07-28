import {
    printCheckResults,
} from "./deps.ts"
import { execDotfiles } from "./src/exec.ts"
import { linkDotfile } from "./src/link.ts"

switch (Deno.args[0]) {
    case 'deploy':
        await linkDotfile.run()
        break;
    case 'setup':
        await execDotfiles.run()
        break;
    case 'check':
        console.log("Checking...")
        printCheckResults(await linkDotfile.check())
        printCheckResults(await execDotfiles.check())
        break;
    default:
        console.log('Usage: deno run --allow-read --allow-write dotfiles.ts [deploy|setup]')
        console.log('Usage(using task): deno task [deploy|setup|check]')
        Deno.exit(1)
}
