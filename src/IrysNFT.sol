// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// NOT PRODUCTION READY !!!

/**
 * @title IrysNFT
 * @author 
 * @notice This contract allows users to create and mint NFTs with unique token URIs.
 * It includes features for minting, burning, and managing NFTs, as well as role-based access control.
 * @dev The contract uses OpenZeppelin's ERC721 and AccessControl for NFT functionality and role management.
 * It supports minting NFTs with a unique token URI, tracking mints per address, and blacklisting NFTs.
 */
contract IrysNFT is ERC721, ERC721Burnable, AccessControl, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    error IrysNFT__EmptyTokenURI();
    error IrysNFT__MaxMintsPerAddressExceeded();
    error IrysNFT__URIAlreadyExists();
    error IrysNFT__NFTIsBlacklisted();

    event NFTCreated(
        uint256 indexed tokenId,
        string _tokenURI,
        address indexed creator
    );

    uint256 private _nextTokenId = 0;
    uint256 public  immutable MAX_MINTS_PER_ADDRESS;
    mapping(address => mapping(string => uint256)) public mintsPerAddress;
    mapping(uint256 => string) public tokenIdToURI;
    mapping(address => string[]) public creatorToURI;
    mapping(string => uint256) public NFTMintCount;
    mapping(string => bool) public isNFTblacklisted;

    /**
     * @dev Constructor that initializes the contract with a maximum mints per address and admin roles.
     * @param maxMintsPerAddress The maximum number of mints allowed per address.
     * @param admin1 The address of the first admin.
     * @param admin2 The address of the second admin.
     */
    constructor(uint256 maxMintsPerAddress, address admin1, address admin2)
        ERC721("IrysNFT", "IRYS")    
    {
        MAX_MINTS_PER_ADDRESS = maxMintsPerAddress;
        _grantRole(ADMIN_ROLE, admin1);
        _grantRole(ADMIN_ROLE, admin2);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.irys.xyz/";
    }
    /**
     * @dev Creates and mints a new NFT with the specified token URI.
     * This is the function that will be called by the creator when a new NFT is to be minted.
     * It checks if the token URI is empty or already exists for the creator, and reverts if so.
     * If the token URI is valid, it mints the NFT, updates the mappings, and emits an event.
     * @param _tokenURI The URI of the NFT to be minted.
     * @return The ID of the newly minted NFT.
     */
    function createAndMintNFT(string memory _tokenURI
    ) external nonReentrant returns (uint256) {
        address creator = msg.sender;
        if (keccak256(abi.encodePacked(_tokenURI)) == keccak256(abi.encodePacked(""))) {
            revert IrysNFT__EmptyTokenURI();
        }
        uint256 length = creatorToURI[creator].length;
        for(uint256 i = 0; i < length; i++) {
            if (keccak256(abi.encodePacked(creatorToURI[creator][i])) == keccak256(abi.encodePacked(_tokenURI))) {
                revert IrysNFT__URIAlreadyExists();
            }
        }
        creatorToURI[creator].push(_tokenURI);

        uint256 tokenId = _nextTokenId++;

        tokenIdToURI[tokenId] = _tokenURI;
        mintsPerAddress[creator][_tokenURI]++;
        NFTMintCount[_tokenURI]++;
        _safeMint(creator, tokenId);
        emit NFTCreated(tokenId, _tokenURI, creator);

        return tokenId;
    }
    /**
     * @dev Mints an existing NFT with the specified token URI.
     * This function allows users to mint an NFT that has already been created by another user.
     * It checks if the token URI is empty, if the maximum mints per address has been exceeded,
     * and if the NFT is blacklisted. If all checks pass, it mints the NFT and updates the mappings.
     * @param _tokenURI The URI of the NFT to be minted.
     * @return The ID of the newly minted NFT.
     */
    function mintExistingNFT(string memory _tokenURI) external nonReentrant returns(uint256){
        if(keccak256(abi.encodePacked(_tokenURI)) == keccak256(abi.encodePacked(""))) {
            revert IrysNFT__EmptyTokenURI();
        }
        if(mintsPerAddress[msg.sender][_tokenURI] >= MAX_MINTS_PER_ADDRESS) {
            revert IrysNFT__MaxMintsPerAddressExceeded();
        }
        if(isNFTblacklisted[_tokenURI]) {
            revert IrysNFT__NFTIsBlacklisted();
        }
        uint256 tokenId = _nextTokenId++;

        tokenIdToURI[tokenId] = _tokenURI;
        mintsPerAddress[msg.sender][_tokenURI]++;
        NFTMintCount[_tokenURI]++;
        _safeMint(msg.sender, tokenId);
        return tokenId;
    }

    function setBlacklist(string memory _tokenURI, bool status) external onlyRole(ADMIN_ROLE) {
        isNFTblacklisted[_tokenURI] = status;
    }

    function getTokenURI(uint256 tokenId) external view returns (string memory) {
        return tokenIdToURI[tokenId];
    }
    function getCreatorURIs(address creator) external view returns (string[] memory) {
        return creatorToURI[creator];
    }
    function getNFTMintCount(string memory _tokenURI) external view returns (uint256) {
        return NFTMintCount[_tokenURI];
    }

    function getMintsPerAddress(address creator, string memory _tokenURI) external view returns (uint256) {
        return mintsPerAddress[creator][_tokenURI];
    }
}
