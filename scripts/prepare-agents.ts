import { defaultAgentConfig, prepareAgents } from "./gen-rules.js"

prepareAgents({
  ...defaultAgentConfig,
  showBox: true,
})
