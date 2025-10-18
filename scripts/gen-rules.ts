import chalk from "chalk"
import { consola } from "consola"
import { glob } from "glob"
import { copyFileSync, mkdirSync, readFileSync, writeFileSync } from "node:fs"
import { basename, resolve } from "node:path"
import { root } from "./common.js"

/**
 * Configuration type for preparing agents.
 */
export type AgentConfig = {
  sourcePattern: string
  targetDirs: readonly string[]
  outputFiles: readonly string[]
  showBox?: boolean
}

/**
 * Default configuration for preparing agents.
 */
export const defaultAgentConfig: AgentConfig = {
  sourcePattern: "agents/**/*.md",
  targetDirs: [".roo/rules"],
  outputFiles: ["CLAUDE.md", "QWEN.md"],
} as const

const cyanBold = (value: number | string) => chalk.cyan.bold(value)
const dim = (value: string) => chalk.dim(value)

/**
 * Copy all agent files to target directory.
 *
 * @param agentFiles list of agent file paths.
 * @param targetDir target directory path.
 * @returns array of copied file names.
 */
export function copyToRulesDirectory(
  agentFiles: readonly string[],
  targetDir: string,
): string[] {
  const targetDirName = basename(targetDir)
  consola.start(`copying agent files to ${dim(targetDirName)} directory...`)

  // Create target directory.
  mkdirSync(targetDir, { recursive: true })
  consola.success(`created directory: ${dim(targetDir)}`)

  // Copy individual files to target directory.
  const copiedFiles: string[] = []
  for (const file of agentFiles) {
    const sourcePath = resolve(root, file)
    const targetPath = resolve(targetDir, basename(file))
    copyFileSync(sourcePath, targetPath)
    copiedFiles.push(basename(file))
    consola.success(
      `copied file to ${dim(targetDirName)}: ${dim(basename(file))}`,
    )
  }

  consola.success(
    `successfully copied ${cyanBold(copiedFiles.length)} files to ${dim(targetDirName)} directory`,
  )
  return copiedFiles
}

/**
 * Merge all agent files content and output to target files.
 *
 * @param agentFiles list of agent file paths.
 * @param outputFiles array of output file names.
 * @returns merged content string.
 */
export function mergeAndOutputFiles(
  agentFiles: readonly string[],
  outputFiles: readonly string[],
): string {
  consola.start("merging agent files content...")

  // Read all files content.
  const allContents: string[] = []
  for (const file of agentFiles) {
    const content = readFileSync(resolve(root, file), "utf-8")
    allContents.push(content)
  }

  // Merge content with "---" separator.
  const mergedContent = allContents.join("\n\n---\n\n")
  consola.info(
    `merged ${cyanBold(allContents.length)} files content, total length: ${cyanBold(mergedContent.length)} characters`,
  )

  // Output merged content to target files.
  for (const outputFile of outputFiles) {
    const outputPath = resolve(root, outputFile)
    writeFileSync(outputPath, mergedContent, "utf-8")
    consola.success(`generated merged file: ${dim(outputFile)}`)
  }

  consola.success(
    `successfully generated ${cyanBold(outputFiles.length)} merged files`,
  )
  return mergedContent
}

/**
 * Prepare agents files with given configuration.
 *
 * Options:
 *
 * - `sourcePattern`: Source directory pattern for agent files.
 * - `targetDirs`: Target directories for copying individual files.
 * - `outputFiles`: Output files for merged content.
 * - `showBox`: Whether to show processing results box.
 *
 * @param options configuration object for preparing agents.
 */
export function prepareAgents(options: AgentConfig) {
  consola.start("preparing agents files...")

  const agentFiles = glob.sync(options.sourcePattern, { cwd: root })
  const formattedAgentFiles = agentFiles
    .map((f) => `  ${chalk.dim(f)}`)
    .join("\n")
  consola.info(
    `found ${cyanBold(agentFiles.length)} agent files:\n${formattedAgentFiles}`,
  )

  if (agentFiles.length === 0) {
    consola.warn("no agent files found")
    return
  }

  const copiedFiles: string[] = []
  for (const targetDir of options.targetDirs) {
    const resolvedTargetDir = resolve(root, targetDir)
    const files = copyToRulesDirectory(agentFiles, resolvedTargetDir)
    copiedFiles.push(...files)
  }
  const mergedContent = mergeAndOutputFiles(agentFiles, options.outputFiles)

  consola.success("agents preparation completed!")
  if (options.showBox !== false) {
    consola.box({
      title: "processing results",
      message: [
        `found agent files: ${cyanBold(agentFiles.length)}`,
        `copied to ${cyanBold(options.targetDirs.length)} directories: ` +
          `${cyanBold(copiedFiles.length)} files`,
        `generated merged files: ${cyanBold(options.outputFiles.length)} files`,
        `merged content length: ${cyanBold(mergedContent.length)} chars`,
      ].join("\n"),
    })
  }
}
