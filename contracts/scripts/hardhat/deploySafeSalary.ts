import { ethers } from "hardhat";
import { hashEndpointWithScope } from "@selfxyz/core";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const nonce = await ethers.provider.getTransactionCount(deployer.address);
  console.log("Account nonce:", nonce);

  const futureAddress = ethers.getCreateAddress({
    from: deployer.address,
    nonce: nonce
  });
  console.log("Calculated future contract address:", futureAddress);

  // For prod environment
  // const identityVerificationHub = "0x77117D60eaB7C044e785D68edB6C7E0e134970E";
  // For staging environment
  const identityVerificationHub = "0x3e2487a250e2A7b56c7ef5307Fb591Cc8C83623D";

  const scope = hashEndpointWithScope(futureAddress, 'Safe-Salary');
  const attestationId = 1n;

  // Mock passport configuration (development/staging)
  // Set devMode to true when using mock passports
  const devMode = true;

  const olderThanEnabled = false;
  const olderThan = 18n;
  const forbiddenCountriesEnabled = false;
  const forbiddenCountriesListPacked = [0n, 0n, 0n, 0n] as [bigint, bigint, bigint, bigint];
  // IMPORTANT: Set to [false, false, false] for mock passports on staging
  // Set to [true, true, true] for real passports on production
  const ofacEnabled = [false, false, false] as [boolean, boolean, boolean];

  const SelfEmployeeVerification = await ethers.getContractFactory("SelfEmployeeVerification");

  console.log("Deploying SelfEmployeeVerification...");
  const selfEmployeeVerification = await SelfEmployeeVerification.deploy(
    identityVerificationHub,
    scope,
    [attestationId]
  ) as any;

  await selfEmployeeVerification.waitForDeployment();

  const deployedAddress = await selfEmployeeVerification.getAddress();
  console.log("SelfEmployeeVerification deployed to:", deployedAddress);

  console.log("\nSetting verification config...");
  const verificationConfig = {
    olderThanEnabled,
    olderThan,
    forbiddenCountriesEnabled,
    forbiddenCountriesListPacked,
    ofacEnabled
  };

  const setConfigTx = await selfEmployeeVerification.setVerificationConfig(verificationConfig);
  await setConfigTx.wait();
  console.log("Verification config set successfully");

  console.log("\nTo verify on Celoscan:");
  console.log(`npx hardhat verify --network celoAlfajores ${deployedAddress} ${identityVerificationHub} ${scope} "[${attestationId}]"`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });