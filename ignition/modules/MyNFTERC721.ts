import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("MyNFTERC721Module", (m) => {
  const deployer = m.getAccount(0);

  // deploy
  const nft = m.contract(
    "MyNFTERC721",
    ["MyCollection", "MNC"],
    {
      from: deployer,
    }
  );

  return { nft };
});
