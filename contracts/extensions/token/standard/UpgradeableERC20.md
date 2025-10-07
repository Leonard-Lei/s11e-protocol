# ERC20 Token Contract Documentation

## Overview

This is an advanced ERC20 token implementation that extends OpenZeppelin's upgradeable contracts with additional
features including access control, pausability, burning, flash minting, and Conflux-specific functionality.

## Contract Variants

### StandardERC20

A simplified, non-upgradeable ERC20 token implementation suitable for basic token operations.

**Features**:

- Basic ERC20 functionality (transfer, approve, allowance)
- Burnable tokens
- Owner-based access control (Ownable)
- Mintable with max supply limit (10,000,000 tokens)
- Batch transfer capability
- ERC20Permit for gasless approvals
- Lower deployment cost

**Use Cases**:

- Simple token deployments
- Fixed governance tokens
- Utility tokens without upgrade requirements
- Gas-efficient basic tokens

### UpgradeableERC20

An advanced, upgradeable ERC20 token with comprehensive features and Conflux integration.

**Features**:

- All StandardERC20 features plus:
- UUPS upgradeable pattern
- Role-based access control (multiple roles)
- Pausable transfers
- Flash minting capability
- ERC1363 payable token support
- Conflux sponsor control for gas fee management
- ETH/BNB deposit and withdrawal

**Use Cases**:

- Long-term token projects requiring future updates
- DeFi protocols needing advanced features
- Conflux ecosystem integration
- Enterprise-grade token implementations

### Comparison Table

| Feature                 | StandardERC20            | UpgradeableERC20            |
| ----------------------- | ------------------------ | --------------------------- |
| **Upgradeability**      | ❌ No                    | ✅ UUPS Pattern             |
| **Access Control**      | Ownable (single owner)   | Role-based (multiple roles) |
| **Pausable**            | ❌ No                    | ✅ Yes                      |
| **Flash Minting**       | ❌ No                    | ✅ Yes                      |
| **ERC1363**             | ❌ No                    | ✅ Yes                      |
| **ERC20Permit**         | ✅ Yes                   | ✅ Yes                      |
| **Burnable**            | ✅ Yes                   | ✅ Yes                      |
| **Mintable**            | ✅ Yes (with max supply) | ✅ Yes (unlimited)          |
| **Batch Transfer**      | ✅ Yes                   | ❌ No                       |
| **Conflux Integration** | ❌ No                    | ✅ Sponsor Control          |
| **ETH Handling**        | ❌ No                    | ✅ Deposit/Withdraw         |
| **Deployment Cost**     | ~1.36M gas               | Higher (proxy + impl)       |
| **Complexity**          | Low                      | High                        |
| **Best For**            | Simple tokens            | Enterprise/DeFi             |

## Contract Features (UpgradeableERC20)

### Core Features

- **Upgradeable**: Uses UUPS (Universal Upgradeable Proxy Standard) pattern
- **Access Control**: Role-based permissions system
- **Pausable**: Can pause/unpause token transfers
- **Burnable**: Tokens can be burned by holders
- **Flash Minting**: Supports flash loans
- **ERC1363**: Payable token standard support
- **ERC20Permit**: Gasless approvals via signatures
- **Conflux Integration**: Sponsor control for gas fee management

### Inherited Contracts

- `Initializable` - Initialization pattern for upgradeable contracts
- `ERC20Upgradeable` - Basic ERC20 functionality
- `ERC20BurnableUpgradeable` - Token burning capability
- `ERC20PausableUpgradeable` - Pause/unpause functionality
- `AccessControlUpgradeable` - Role-based access control
- `ERC1363Upgradeable` - Payable token standard
- `ERC20PermitUpgradeable` - Gasless approvals
- `ERC20FlashMintUpgradeable` - Flash loan functionality
- `UUPSUpgradeable` - Upgrade mechanism

## Roles

### Role Constants

- `DEFAULT_ADMIN_ROLE` - Full administrative access
- `PAUSER_ROLE` - Can pause/unpause the contract
- `MINTER_ROLE` - Can mint new tokens
- `UPGRADER_ROLE` - Can upgrade the contract

## Contract Interface

### Initialization

```solidity
function initialize(
    string memory _name,
    string memory _symbol,
    uint256 _initialSupply,
    address _owner
) public initializer
```

**Description**: Initializes the contract with token details and assigns roles to the owner and deployer.

**Parameters**:

- `_name`: Token name
- `_symbol`: Token symbol
- `_initialSupply`: Initial token supply
- `_owner`: Owner address who will receive admin roles

### Token Transfer Functions

#### Standard Transfer

```solidity
function transfer(address to, uint256 amount) public virtual returns (bool)
```

**Description**: Standard ERC20 transfer function.

#### Enhanced Transfer with Privilege

```solidity
function transfer(
    address _recipient,
    uint256 _amount,
    bool _addPrivilege
) public returns (bool)
```

**Description**: Extended transfer function that can optionally add the recipient to the privilege list for gas fee
sponsorship.

**Parameters**:

- `_recipient`: Recipient address
- `_amount`: Amount to transfer
- `_addPrivilege`: Whether to add recipient to privilege list

### Administrative Functions

#### Pause Control

```solidity
function pause() public onlyRole(PAUSER_ROLE)
function unpause() public onlyRole(PAUSER_ROLE)
```

**Description**: Pause or unpause token transfers.

#### Minting

```solidity
function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE)
```

**Description**: Mint new tokens to a specified address.

### Conflux-Specific Functions

#### Privilege Management

```solidity
function addPrivilege(address[] memory _account) public payable onlyRole(DEFAULT_ADMIN_ROLE)
function removePrivilege(address[] memory _account) public payable onlyRole(DEFAULT_ADMIN_ROLE)
```

**Description**: Manage gas fee sponsorship privileges for Conflux network.

**Parameters**:

- `_account`: Array of addresses to add/remove from privilege list
- Special case: `["0x0000000000000000000000000000000000000000"]` allows all addresses

### Upgrade Functions

#### Contract Upgrade

```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE)
```

**Description**: Authorizes contract upgrades (internal function).

### Financial Functions

#### Withdraw

```solidity
function withdraw(uint256 _amount) external
```

**Description**: Withdraw ETH/BNB from the contract.

**Requirements**:

- Caller must have `DEFAULT_ADMIN_ROLE`
- Amount must not exceed contract balance

#### Balance Check

```solidity
function balance() public view returns (uint256)
```

**Description**: Returns the ETH/BNB balance of the contract.

### Event Handling

#### Receive Function

```solidity
receive() external payable virtual
```

**Description**: Allows the contract to receive ETH/BNB transfers.

## Override Functions

### Update Function

```solidity
function _update(
    address from,
    address to,
    uint256 value
) internal override(ERC20Upgradeable, ERC20PausableUpgradeable)
```

**Description**: Overrides the update function to handle both ERC20 and pausable functionality.

### Interface Support

```solidity
function supportsInterface(bytes4 interfaceId) public view override(AccessControlUpgradeable, ERC1363Upgradeable) returns (bool)
```

**Description**: Returns whether the contract supports the specified interface.

## Security Features

### Access Control

- Role-based permissions for all administrative functions
- Multiple roles for different levels of access
- Owner and deployer both receive admin roles during initialization

### Upgrade Safety

- UUPS pattern for secure upgrades
- Only `UPGRADER_ROLE` can authorize upgrades
- Constructor disables initializers for security

### Pausability

- Emergency pause functionality
- Only `PAUSER_ROLE` can pause/unpause
- Affects all token transfers when paused

## Gas Optimization

### Conflux Integration

- Sponsor control for gas fee management
- Privilege system to reduce user transaction costs
- Payable functions for gas fee handling

## Usage Examples

### Basic Token Operations

```solidity
// Initialize token
erc20.initialize("MyToken", "MTK", 1000000, owner);

// Transfer with privilege
erc20.transfer(recipient, 1000, true);

// Mint new tokens
erc20.mint(user, 5000);
```

### Administrative Operations

```solidity
// Pause transfers
erc20.pause();

// Add gas fee privilege
address[] memory privileged = new address[](1);
privileged[0] = userAddress;
erc20.addPrivilege(privileged);
```

## Network Compatibility

- **Ethereum**: Full functionality
- **Conflux**: Enhanced with sponsor control for gas fee management
- **Other EVM-compatible chains**: Standard ERC20 functionality

## Deployment and Testing

### Prerequisites

- Node.js and npm installed
- Hardhat configured
- Private key or mnemonic for deployment
- Sufficient ETH/CFX for gas fees

### Deployment Steps

#### 1. Deploy ERC20 Token

```bash
# Deploy to local network
npx hardhat run scripts/deploy-erc20.js --network hardhat

# Deploy to testnet
npx hardhat run scripts/deploy-erc20.js --network goerli

# Deploy to mainnet
npx hardhat run scripts/deploy-erc20.js --network mainnet
```

#### 2. Environment Variables

Set the following environment variables in `.env` file:

```bash
OWNER_ADDRESS=0x...  # Address that will receive admin roles
ETH_NODE_URL=https://...  # RPC URL for the network
WALLET_MNEMONIC="your mnemonic phrase"
```

#### 3. Deployment Script Features

The deployment script (`scripts/deploy-erc20.js`) includes:

- Automatic proxy deployment using UUPS pattern
- Role assignment to owner and deployer
- Token information verification
- Implementation and admin address logging

### Testing

#### 1. StandardERC20 Tests

The StandardERC20 contract is a simplified, non-upgradeable version for basic token functionality testing.

```bash
# Run StandardERC20 tests
npx hardhat test test/standard_erc20/StandardERC20.ts

# Run with gas reporting
REPORT_GAS=true npx hardhat test test/standard_erc20/StandardERC20.ts
```

**Test Coverage (39 tests)**:

- **Deployment (6 tests)**: Token name, symbol, decimals, owner, max supply, initial supply
- **getTokenInfo (1 test)**: Token information retrieval
- **Minting (6 tests)**: Owner minting, supply management, max supply limits, permission checks
- **Transfer (4 tests)**: Basic transfers, balance updates, insufficient balance checks, events
- **BatchTransfer (5 tests)**: Batch operations, permissions, array validation, balance checks
- **Allowance (5 tests)**: Approve/transferFrom, allowance management, events
- **Burn (5 tests)**: Burn and burnFrom, supply reduction, allowance consumption
- **Permit/EIP-2612 (2 tests)**: DOMAIN_SEPARATOR, nonces
- **Ownership (5 tests)**: Transfer ownership, renounce ownership, permission changes

**Gas Usage**:

- Deployment: ~1,360,898 gas
- Mint: ~70,887 gas
- Transfer: ~51,603 gas
- BatchTransfer: 80,867 - 106,593 gas
- Burn: ~33,881 gas
- Approve: ~46,401 gas

#### 2. UpgradeableERC20 Tests

```bash
# Run all upgradeable ERC20 tests
npx hardhat test test/upgradeable_erc20/UpgradeableERC20.ts

# Run with gas reporting
REPORT_GAS=true npx hardhat test test/upgradeable_erc20/UpgradeableERC20.ts

# Run specific test
npx hardhat test test/upgradeable_erc20/UpgradeableERC20.ts --grep "Upgrade"
```

#### 3. Comprehensive Test Script

```bash
# Run comprehensive test suite
npx hardhat run scripts/test-standard-erc20.js --network hardhat
```

#### 4. Test Coverage

The upgradeable version test suite covers:

- **Deployment Tests**: Name, symbol, decimals, total supply, role assignment
- **Basic ERC20 Functions**: Transfer, approve, transferFrom, allowance
- **Enhanced Features**: Privilege transfer, pause/unpause, minting, burning
- **Conflux Integration**: Privilege management, sponsor control
- **Financial Functions**: ETH deposits, withdrawals
- **Advanced Features**: ERC1363, ERC20Permit, flash minting
- **Upgrade Functions**: UUPS upgradeability verification
- **Interface Support**: ERC20, ERC1363, AccessControl interfaces

### Upgrade Process

#### 1. Prepare New Implementation

```solidity
// Create new contract with additional features
contract ERC20V2 is ERC20 {
  // Add new functionality
  function newFeature() public {
    // Implementation
  }
}
```

#### 2. Deploy Upgrade

```bash
# Upgrade existing proxy
npx hardhat run scripts/upgrade-standard-erc20.js --network mainnet

# With specific proxy address
npx hardhat run scripts/upgrade-standard-erc20.js --network mainnet -- 0x1234...
```

#### 3. Verify Upgrade

```bash
# Verify implementation changed
npx hardhat run scripts/verify-upgrade.js --network mainnet
```

### Network-Specific Configuration

#### Ethereum Networks

```javascript
// hardhat.config.js
module.exports = {
  networks: {
    mainnet: {
      url: process.env.ETH_NODE_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    goerli: {
      url: process.env.GOERLI_NODE_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};
```

#### Conflux Networks

```javascript
// For Conflux, additional configuration needed
module.exports = {
  networks: {
    conflux: {
      url: process.env.CONFLUX_NODE_URL,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 1029,
    },
  },
};
```

### Security Considerations

#### 1. Role Management

- Ensure only trusted addresses have admin roles
- Use multi-sig wallets for production deployments
- Regularly audit role assignments

#### 2. Upgrade Safety

- Test upgrades on testnets first
- Verify state preservation after upgrades
- Have rollback plan ready

#### 3. Gas Optimization

- Use appropriate gas limits for different networks
- Consider gas price optimization for Conflux
- Monitor gas usage in production

### Troubleshooting

#### Common Issues

1. **Deployment Fails**: Check network configuration and gas limits
2. **Role Assignment Fails**: Verify owner address and permissions
3. **Upgrade Fails**: Ensure new implementation is compatible
4. **Test Failures**: Check network connectivity and account balances

#### Debug Commands

```bash
# Check contract state
npx hardhat console --network mainnet
> const contract = await ethers.getContractAt("ERC20", "0x...")
> await contract.name()

# Verify implementation
npx hardhat verify --network mainnet 0x... "constructor args"
```

## License

MIT License - Compatible with OpenZeppelin Contracts ^5.4.0
