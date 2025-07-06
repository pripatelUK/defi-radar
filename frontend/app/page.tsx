'use client';

import React, { useState, useEffect } from 'react';
import SelfQRcodeWrapper, { SelfApp, SelfAppBuilder } from '@selfxyz/qrcode';
import { logo } from './content/birthdayAppLogo';
import { ethers } from 'ethers';

// Safe Salary contract address (placeholder - would be updated for actual deployment)
const SAFE_SALARY_CONTRACT_ADDRESS = "0x5Cb62C0F4ab2b9258E18eFD9D6f914783a44fB82";

// Company departments
const departments = [
    { id: "engineering", name: "Engineering Department" },
    { id: "marketing", name: "Marketing Department" },
    { id: "finance", name: "Finance Department" },
    { id: "hr", name: "Human Resources" },
];

function SafeSalary() {
    const [input, setInput] = useState('0x0000000000000000000000000000000000000003');
    const [address, setAddress] = useState('0x0000000000000000000000000000000000000003');
    const [selectedDepartment, setSelectedDepartment] = useState(departments[0]);

    const [verificationSuccess, setVerificationSuccess] = useState(false);
    const [txHash, setTxHash] = useState<string | null>(null);

    useEffect(() => {
        if (ethers.isAddress(input)) {
            setAddress(input);
        }
    }, [input]);

    const selfApp = new SelfAppBuilder({
        // appName: "Safe Salary Employee Verifier",
        appName: "Safe Salary",
        scope: "Safe-Salary",
        // scope: "safe-salary-verification",
        endpoint: SAFE_SALARY_CONTRACT_ADDRESS,
        endpointType: "staging_celo",
        logoBase64: logo,
        userId: address,
        userIdType: "hex",
        disclosures: {
            name: true,
            date_of_birth: true,
            nationality: true
        },
        devMode: true,
    } as Partial<SelfApp>).build();

    const handleSuccess = async (data?: any) => {
        console.log('Verification successful', data);
        setVerificationSuccess(true);
        // If we get a tx hash from the data, use it
        if (data?.txHash) {
            setTxHash(data.txHash);
        }
    };

    return (
        <div className="min-h-screen bg-white text-black">
            <nav className="w-full bg-white border-b border-gray-200 py-3 px-6 flex items-center justify-between">
                <div className="flex items-center">
                    <div className="mr-8">
                        <span className="text-xl font-bold text-blue-600">Safe Salary</span>
                    </div>
                    <div className="hidden md:block">
                        <select
                            value={selectedDepartment.id}
                            onChange={(e) => {
                                const dept = departments.find(d => d.id === e.target.value) || departments[0];
                                setSelectedDepartment(dept);
                            }}
                            className="text-sm font-medium px-3 py-1 rounded-full bg-blue-50 text-blue-800 border border-blue-200 focus:outline-none focus:ring-1 focus:ring-blue-300"
                        >
                            {departments.map((dept) => (
                                <option key={dept.id} value={dept.id}>
                                    {dept.name}
                                </option>
                            ))}
                        </select>
                    </div>
                </div>
                <div className="flex items-center space-x-4">
                    <a
                        className="flex items-center justify-center gap-2 hover:underline hover:underline-offset-4"
                        href="https://self.xyz"
                        target="_blank"
                        rel="noopener noreferrer"
                    >
                        Go to self.xyz →
                    </a>
                </div>
            </nav>

            <div className="container mx-auto max-w-2xl px-4 py-8">
                <div className="bg-white rounded-lg shadow-md p-6 border border-gray-300">
                    <h1 className="text-3xl font-bold text-center mb-2 bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                        Safe Salary
                    </h1>
                    <h2 className="text-lg font-medium text-center mb-6 text-gray-600">
                        Secure Employee Verification Without Revealing Your Passport
                    </h2>

                    <div className="mb-6 bg-blue-50 p-4 rounded-lg">
                        <h3 className="font-semibold text-blue-800 mb-2">
                            {selectedDepartment.name} Employee Verification
                        </h3>
                        <p className="text-blue-700 text-sm">
                            Verify your identity for secure salary processing in {selectedDepartment.name} without revealing your passport details.
                        </p>
                    </div>

                    {/* North Korea crypto joke */}
                    <div className="mb-6 bg-amber-50 border border-amber-200 rounded-lg p-3">
                        <div className="flex items-start">
                            <div className="bg-amber-100 rounded-full p-1 mr-2">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 text-amber-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.728-.833-2.498 0L4.316 16.5c-.77.833.192 2.5 1.732 2.5z" />
                                </svg>
                            </div>
                            <div>
                                <p className="text-amber-700 text-sm font-medium">Security Note</p>
                                <p className="text-amber-600 text-xs">
                                    Our system automatically excludes North Korean nationals from crypto salary payments.
                                    <br />
                                    <span className="italic">Because even Kim Jong Un can&apos;t mine his way out of international sanctions! 🚫⛏️</span>
                                </p>
                            </div>
                        </div>
                    </div>

                    <div className="mb-6">
                        <label className="block text-sm font-medium mb-2">
                            Enter your wallet address for salary processing:
                        </label>
                        <input
                            type="text"
                            value={input}
                            onChange={(e) => setInput(e.target.value)}
                            placeholder="0x..."
                            className="w-full p-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                        />
                    </div>

                    {address && (
                        <div className="mb-6">
                            <h3 className="text-lg font-semibold mb-3">Step 1: Verify Your Identity with Self Protocol</h3>
                            <div className="mb-4">
                                <p className="text-sm text-gray-600 mb-2">How it works:</p>
                                <ol className="list-decimal pl-5 text-sm text-gray-600 space-y-1">
                                    <li>Scan this QR code with your Self app</li>
                                    <li>Allow Self to confirm your verified details (name, nationality, date of birth)</li>
                                    <li>Wait for confirmation to proceed with salary setup</li>
                                </ol>
                            </div>
                        </div>
                    )}

                    {selfApp && address && (
                        <div className="flex justify-center mb-6">
                            <div className="bg-gray-50 p-4 rounded-lg">
                                <p className="text-center text-sm text-gray-600 mb-3">
                                    Open your Self app and scan this QR code
                                </p>
                                <SelfQRcodeWrapper
                                    selfApp={selfApp}
                                    type='websocket'
                                    onSuccess={handleSuccess}
                                />
                                <p className="text-center text-xs text-gray-500 mt-3">
                                    Your passport stays private and secure
                                </p>
                            </div>
                        </div>
                    )}

                    {verificationSuccess && (
                        <div className="mt-6 p-4 bg-green-50 border border-green-200 rounded-lg">
                            <h3 className="text-lg font-semibold text-green-800 mb-2">
                                ✅ Employee Verification Complete!
                            </h3>
                            <p className="text-sm text-green-700 mb-3">
                                Welcome to {selectedDepartment.name}! Your identity has been verified and your salary processing is now secure. Your personal data remains private.
                            </p>
                            <div className="space-y-2">
                                {txHash ? (
                                    <a
                                        href={`https://alfajores.celoscan.io/tx/${txHash}`}
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        className="inline-flex items-center text-blue-600 hover:underline"
                                    >
                                        View Transaction on Celoscan →
                                    </a>
                                ) : (
                                    <a
                                        href={`https://alfajores.celoscan.io/address/${address}#tokentxns`}
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        className="inline-flex items-center text-blue-600 hover:underline"
                                    >
                                        View Your Address on Celoscan →
                                    </a>
                                )}
                            </div>
                        </div>
                    )}

                    {!address && (
                        <div className="text-center text-gray-500">
                            <p className="text-sm">Enter a valid wallet address to begin employee verification</p>
                        </div>
                    )}
                </div>

                <div className="text-center mt-6">
                    <p className="text-xs text-gray-500 mb-1">
                        By verifying, you confirm your employment eligibility and consent to secure salary processing.
                    </p>
                    <p className="text-xs text-gray-400">
                        Safe Salary • Privacy-Preserving Employee Identity Verification
                    </p>
                </div>
            </div>
        </div>
    );
}

export default SafeSalary;
