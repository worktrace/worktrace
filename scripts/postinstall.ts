import consola from "consola"
import { defaultAgentConfig, prepareAgents } from "./gen-rules"

async function main() {
  consola.start("running postinstall script...")

  prepareAgents({ ...defaultAgentConfig, showBox: false })

  consola.success("postinstall script completed")
}

await main()
