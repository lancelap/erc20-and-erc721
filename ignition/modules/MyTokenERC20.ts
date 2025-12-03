
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("MyTokenERC20Module", (m) => {
  const deployer = m.getAccount(0);

  // deploy
  const token = m.contract(
    "MyTokenERC20",
    ["MyTokenERC20", "MTE", 18],
    {
      from: deployer,
    }
  );

  return { token };
});
