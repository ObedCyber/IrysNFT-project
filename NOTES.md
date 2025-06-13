# Irys NFT Minting Project - Notes and Guide

## 🧩 Project Overview

This project is a simple and interactive NFT minting dApp designed to drive attention to **Irys**, a powerful datachain built for decentralized, permanent storage. The goal is to let users:

* Select or upload NFT artwork
* Add a description
* Mint NFTs where the **image and metadata** are **stored entirely on Irys**

The minting will be **open**, with **no supply cap**, and allow **community participation** by enabling users to submit their own artwork. Other users can then mint those submitted pieces.

---

## 🚀 MVP Features

### Smart Contract

* **ERC721 Token** implementation using OpenZeppelin
* No max cap on supply
* Minting logic with `safeMint`
* New artwork submission system
* Approval system to moderate submissions
* Irys-hosted metadata and image storage

### Solidity Structure

```solidity
struct Artwork {
    string metadataURI;
    address submitter;
    bool approved;
}

mapping(uint256 => Artwork) public artworks;
uint256 public artworkCount;

function submitArtwork(string calldata metadataURI) external {
    artworks[artworkCount] = Artwork(metadataURI, msg.sender, false);
    artworkCount++;
}

function approveArtwork(uint256 artworkId) external onlyOwner {
    artworks[artworkId].approved = true;
}

function mint(uint256 artworkId) external returns (uint256) {
    require(artworks[artworkId].approved, "Not approved yet");
    uint256 tokenId = _nextTokenId++;
    _safeMint(msg.sender, tokenId);
    _setTokenURI(tokenId, artworks[artworkId].metadataURI);
    return tokenId;
}
```

### Frontend (dApp)

#### Basic UI Pages

1. **Home**: Welcome message and short explanation of Irys.
2. **Gallery**: View all approved artworks available for minting.
3. **Submit Artwork**: Upload form for submitting metadata URI (must be hosted on Irys).
4. **Mint NFT**: Mint any approved NFT by clicking a button after wallet connection.

#### Key Features

* Wallet Connect (e.g., MetaMask)
* Upload artwork & description form (generate metadata JSON and upload to Irys)
* Fetch and display Irys-hosted metadata
* Status of artwork submission (Pending / Approved)

---

## 📦 Uploading to Irys

### Image + Metadata

1. Upload image to Irys using CLI, SDK, or frontend integration
2. Get image URI
3. Create a JSON metadata file

```json
{
  "name": "Cool Character",
  "description": "A heroic image from the Irys collection",
  "image": "irys://<imageID>"
}
```

4. Upload the metadata JSON to Irys
5. Use metadata URI in the smart contract

### Docs Reference:

[Uploading NFTs to Irys](https://docs.irys.xyz/build/d/guides/uploading-nfts)

---

## ✨ Future Features

* **Voting system**: Users can vote on which submissions should be approved
* **Categories**: Organize NFTs into genres (e.g., memes, illustrations, abstract art)
* **Search & Filters**: Make browsing easier by tags or creators
* **Leaderboards**: Track top mintable artworks or most minted submissions
* **Reward system**: Option to reward submitters (e.g., tokens, points, badges)
* **Email notifications**: Notify submitters when their artwork is approved
* **Social sharing**: Allow users to share minted NFTs directly to Twitter (X)
* **NFT Preview**: Interactive preview before minting

---

## 🛡️ Security Best Practices

* Use OpenZeppelin standards
* Validate metadata URIs to ensure they're pointing to valid Irys-hosted files
* Add cooldown between submissions per wallet (optional)
* Consider a moderation DAO for future decentralization of approval

---

## 📌 Summary

This project is a fun, low-barrier way to introduce more people to the power of permanent, programmable data on Irys. It enables both NFT creators and collectors to engage with decentralized storage in a meaningful, interactive way.

Start small, grow fast. 🧠✨
