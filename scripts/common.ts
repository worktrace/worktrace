import { spawn, SpawnOptionsWithoutStdio } from "node:child_process"
import { resolve } from "node:path"
import { stdout } from "node:process"

/**
 * Encapsulation of running a shell command.
 *
 * 1. The output will be redirected to the standard output.
 * 2. Attention that some of the command-line animations might not available.
 * 3. It will apply the package root as cwd by default, which you can override.
 *
 * @param command the command to run.
 * @param options the options to pass to spawn.
 * @returns the exit code of the command.
 */
export function run(
  command: string,
  options?: SpawnOptionsWithoutStdio,
): Promise<number> {
  return new Promise((resolve, reject) => {
    const p = spawn(command, { shell: true, cwd: root, ...options })
    p.stdout.on("data", (data) => stdout.write(data))
    p.stderr.on("data", (data) => stdout.write(data))
    p.on("disconnect", () => reject(new Error(`disconnected: ${command}`)))
    p.on("close", (code) => {
      return code === 0
        ? resolve(code)
        : reject(new Error(`command failed (${code}): ${command}`))
    })
  })
}

/** Root of current package (workspace). */
export const root = resolve(import.meta.dirname, "..")
