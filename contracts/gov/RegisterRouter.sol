// SPDX-License-Identifier: MIT
// Stratonet Contracts (last updated v1.1.0) (gov/SdsRouter.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./versions/Version1.sol";

import "../utils/Bech32.sol";
import "../utils/CosmosLib.sol";

contract SdsRouter is Version1, OwnableUpgradeable {
    using CosmosLib for string;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    enum NodeType {
        TEST
    }

    enum NodeStatus {
        // UNSPECIFIED defines an invalid validator status.
        UNSPECIFIED,
        // UNBONDED defines a validator that is not bonded.
        UNBONDED,
        // UNBONDING defines a validator that is unbonding.
        UNBONDING,
        // BONDED defines a validator that is bonded.
        BONDED
    }

    struct ResourceNode {
        NodeType _type;
        NodeStatus status;
        bool suspend;
        address networkAddr;
        address owner;
        string description;
        uint256 tokens;
        uint256 effectiveTokens;
        uint256 blockNumber;
        uint256 createdAt;
    }

    event NewNode(address indexed networkAddr);

    event Stake(
        address indexed networkAddr,
        uint256 ozoneAmount,
        uint256 tokensBefore,
        uint256 tokensAfter
    );

    IERC20 public weth9;

    mapping(address => ResourceNode) public resourceNodes;
    Counters.Counter private _boundCounter;

    // ----- proxy ------
    uint256[49] private __gap;

    // Initialize function for proxy constructor. Must be used atomically
    function initialize(IERC20 _weth9) public initializer {
        weth9 = _weth9;

        // proxy inits
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function createResourceNode(
        address networkAddr,
        NodeType _type,
        uint256 amount,
        string calldata description
    ) external payable {
        require(networkAddr != address(0), "RR: EMPTY_ADDRESS");

        ResourceNode storage node = resourceNodes[networkAddr];
        require(node.networkAddr == address(0), "RR: ENTITY_EXISTS");

        node._type = _type;
        node.status = NodeStatus.BONDED;
        node.suspend = true;
        node.networkAddr = networkAddr;
        node.owner = _msgSender();
        node.description = description;
        node.tokens = 0;
        node.effectiveTokens = 0;
        node.blockNumber = block.number;
        node.createdAt = block.timestamp;

        emit NewNode(networkAddr);

        _stake(node, amount);
    }

    function _stake(ResourceNode storage node, uint256 amount) private {
        require(node.status != NodeStatus.UNBONDING, "RR: UNBOUNDING");
        require(node.status != NodeStatus.UNSPECIFIED, "RR: UNSPECIFIED");

        // TODO: getUnbondingNodeBalance(addr)
        uint256 unbondingStake = 0;

        uint256 availableTokenAmtBefore = node.tokens - unbondingStake;

        string memory targetModuleAccName;

        if (node.status == NodeStatus.UNBONDED) {
            targetModuleAccName = "resource_node_not_bonded_pool";
        } else if (node.status == NodeStatus.BONDED) {
            targetModuleAccName = "resource_node_bonded_pool";
        }

        require(bytes(targetModuleAccName).length > 0, "RR: NO_TARGET");

        address targetAddr = targetModuleAccName.toModuleAddress();
        // TODO: Add go impl with assembly for balance withdraw
        weth9.safeTransferFrom(node.owner, targetAddr, amount);

        node.tokens += amount;

        if (node.status == NodeStatus.UNBONDED) {
            node.status = NodeStatus.BONDED;

            string memory fromModuleAccName = "resource_node_not_bonded_pool";
            targetModuleAccName = "resource_node_bonded_pool";

            address fromAddr = fromModuleAccName.toModuleAddress();
            targetAddr = targetModuleAccName.toModuleAddress();

            // TODO: Add go impl with assembly for balance withdraw
            weth9.safeTransferFrom(fromAddr, targetAddr, node.tokens);
        }

        if (node.status != NodeStatus.BONDED) {
            _boundCounter.increment();
        }

        uint256 availableTokenAmtAfter = availableTokenAmtBefore + amount;

        emit Stake(
            node.networkAddr,
            0,
            availableTokenAmtBefore,
            availableTokenAmtAfter
        );
    }
}
