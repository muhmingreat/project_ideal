import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const ProjectIdeal = buildModule("ProjectIdeal", (m) => {
  const projectIdeal = m.contract("ProjectIdeal");

  return { projectIdeal };
});

export default ProjectIdeal;
