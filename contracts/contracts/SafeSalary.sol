// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { SelfVerificationRoot } from "@selfxyz/contracts/contracts/abstract/SelfVerificationRoot.sol";
import { ISelfVerificationRoot } from "@selfxyz/contracts/contracts/interfaces/ISelfVerificationRoot.sol";
import { SelfCircuitLibrary } from "@selfxyz/contracts/contracts/libraries/SelfCircuitLibrary.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract SelfEmployeeVerification is SelfVerificationRoot, Ownable {
    struct EmployerData {
        string companyName;
        address employerAddress;
        bool isRegistered;
        bool isActive;
    }

    struct UserData {
        string dateOfBirth;
        string name;
        string nationality;
        address employerAddress;
        uint256 salaryAmount; // Monthly salary in USDC (6 decimals)
        uint32 preferredChainId; // Chain ID where user wants to receive payments
        bool isVerified;
    }

    mapping(address => EmployerData) public registeredEmployers;
    mapping(address => UserData) public verifiedUsers;
    mapping(uint256 => bool) internal _nullifiers;
    mapping(address => address[]) public employerToEmployees; // employer -> list of employee addresses

    event EmployerRegistered(address indexed employerAddress, string companyName);
    event EmployerStatusUpdated(address indexed employerAddress, bool isActive);
    event UserVerified(
        address indexed userAddress,
        address indexed employerAddress,
        string name,
        string nationality,
        string dateOfBirth,
        uint32 preferredChainId
    );
    event SalaryUpdated(address indexed employeeAddress, address indexed employerAddress, uint256 newSalary);
    event ChainIdUpdated(address indexed employeeAddress, uint32 oldChainId, uint32 newChainId);
    event BatchPaymentTriggered(address indexed employerAddress, uint256 employeeCount, uint256 totalAmount);

    error RegisteredNullifier();
    error AlreadyVerified();
    error UnauthorizedEmployer();
    error EmployerNotRegistered();
    error EmployerInactive();
    error InvalidSalaryAmount();
    error InvalidChainId();

    constructor(
        address _identityVerificationHub,
        uint256 _scope,
        uint256[] memory _attestationIds
    )
        SelfVerificationRoot(_identityVerificationHub, _scope, _attestationIds)
        Ownable(_msgSender())
    { }

    function setVerificationConfig(ISelfVerificationRoot.VerificationConfig memory newVerificationConfig)
        external
        onlyOwner
    {
        _setVerificationConfig(newVerificationConfig);
    }

    function registerEmployer(address employerAddress, string memory companyName) external onlyOwner {
        require(employerAddress != address(0), "Invalid employer address");
        require(bytes(companyName).length > 0, "Company name cannot be empty");

        registeredEmployers[employerAddress] = EmployerData({
            companyName: companyName,
            employerAddress: employerAddress,
            isRegistered: true,
            isActive: true
        });

        emit EmployerRegistered(employerAddress, companyName);
    }

    function updateEmployerStatus(address employerAddress, bool isActive) external onlyOwner {
        require(registeredEmployers[employerAddress].isRegistered, "Employer not registered");

        registeredEmployers[employerAddress].isActive = isActive;
        emit EmployerStatusUpdated(employerAddress, isActive);
    }

    function verifySelfProof(
        ISelfVerificationRoot.DiscloseCircuitProof memory proof,
        address employerAddress,
        uint256 salaryAmount,
        uint32 preferredChainId
    )
        public
    {
        if (_nullifiers[proof.pubSignals[NULLIFIER_INDEX]]) {
            revert RegisteredNullifier();
        }

        if (!registeredEmployers[employerAddress].isRegistered) {
            revert EmployerNotRegistered();
        }

        if (!registeredEmployers[employerAddress].isActive) {
            revert EmployerInactive();
        }

        if (salaryAmount == 0) {
            revert InvalidSalaryAmount();
        }

        if (preferredChainId == 0) {
            revert InvalidChainId();
        }

        address userAddress = address(uint160(proof.pubSignals[USER_IDENTIFIER_INDEX]));

        if (verifiedUsers[userAddress].isVerified) {
            revert AlreadyVerified();
        }

        super.verifySelfProof(proof);

        uint256[3] memory revealedDataPacked = getRevealedDataPacked(proof.pubSignals);

        string memory dob = SelfCircuitLibrary.getDateOfBirth(revealedDataPacked);
        string memory name = SelfCircuitLibrary.getName(revealedDataPacked);
        string memory nationality = SelfCircuitLibrary.getNationality(revealedDataPacked);

        verifiedUsers[userAddress] = UserData({
            dateOfBirth: dob,
            name: name,
            nationality: nationality,
            employerAddress: employerAddress,
            salaryAmount: salaryAmount,
            preferredChainId: preferredChainId,
            isVerified: true
        });

        employerToEmployees[employerAddress].push(userAddress);
        _nullifiers[proof.pubSignals[NULLIFIER_INDEX]] = true;

        emit UserVerified(userAddress, employerAddress, name, nationality, dob, preferredChainId);
    }

    function updateEmployeeSalary(address employeeAddress, uint256 newSalaryAmount) external {
        require(registeredEmployers[msg.sender].isRegistered, "Caller is not a registered employer");
        require(registeredEmployers[msg.sender].isActive, "Employer is not active");
        require(
            verifiedUsers[employeeAddress].employerAddress == msg.sender, "Employee not associated with this employer"
        );
        require(newSalaryAmount > 0, "Invalid salary amount");

        verifiedUsers[employeeAddress].salaryAmount = newSalaryAmount;
        emit SalaryUpdated(employeeAddress, msg.sender, newSalaryAmount);
    }

    function updatePreferredChainId(uint32 newChainId) external {
        require(verifiedUsers[msg.sender].isVerified, "User not verified");
        require(newChainId != 0, "Invalid chain ID");

        uint32 oldChainId = verifiedUsers[msg.sender].preferredChainId;
        verifiedUsers[msg.sender].preferredChainId = newChainId;

        emit ChainIdUpdated(msg.sender, oldChainId, newChainId);
    }

    function initiateCCTPPayment(
        address[] calldata recipients,
        uint256[] calldata amounts,
        uint32[] calldata destinationChainIds
    )
        external
    {
        require(registeredEmployers[msg.sender].isRegistered, "Caller is not a registered employer");
        require(registeredEmployers[msg.sender].isActive, "Employer is not active");
        require(recipients.length == amounts.length, "Recipients and amounts length mismatch");
        require(recipients.length == destinationChainIds.length, "Recipients and chain IDs length mismatch");

        // TODO: Implement Circle's CCTP integration
        // This function should:
        // 1. Import Circle's CCTP interfaces and contracts
        // 2. Validate all destination chain IDs are supported by CCTP
        // 3. Group payments by destination chain for efficiency
        // 4. Call Circle's TokenMessenger contract to burn tokens for each chain
        // 5. Handle cross-chain message attestation
        // 6. Emit events for cross-chain payment tracking with chain IDs
        // 7. Store payment records for auditing with chain information

        // Placeholder implementation
        revert("CCTP payment functionality not yet implemented");
    }

    function getEmployeesByChain(address employerAddress, uint32 chainId) external view returns (address[] memory) {
        address[] memory allEmployees = employerToEmployees[employerAddress];
        uint256 count = 0;

        // Count employees for this chain
        for (uint256 i = 0; i < allEmployees.length; i++) {
            if (verifiedUsers[allEmployees[i]].preferredChainId == chainId) {
                count++;
            }
        }

        // Create array of employees for this chain
        address[] memory chainEmployees = new address[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < allEmployees.length; i++) {
            if (verifiedUsers[allEmployees[i]].preferredChainId == chainId) {
                chainEmployees[index] = allEmployees[i];
                index++;
            }
        }

        return chainEmployees;
    }

    function getUserData(address userAddress) external view returns (UserData memory) {
        return verifiedUsers[userAddress];
    }

    function isUserVerified(address userAddress) external view returns (bool) {
        return verifiedUsers[userAddress].isVerified;
    }

    function getEmployerData(address employerAddress) external view returns (EmployerData memory) {
        return registeredEmployers[employerAddress];
    }

    function getEmployeesByEmployer(address employerAddress) external view returns (address[] memory) {
        return employerToEmployees[employerAddress];
    }

    function getEmployeeCount(address employerAddress) external view returns (uint256) {
        return employerToEmployees[employerAddress].length;
    }
}
