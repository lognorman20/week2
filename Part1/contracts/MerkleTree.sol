//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        for (uint i = 0; i < 8; i++){
            hashes.push(0);
        }
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        index++;
        /* Recalculate the root and return that value for verify function */
        uint256[8] memory calcRoot;
        uint n = 8;
        uint idx = 0;
        while (n > 0){
            for (uint i = 0; i < n; i+=2){
                calcRoot[idx] = (PoseidonT3.poseidon([hashes[i], hashes[i + 1]]));
                idx++;
            }
            n /= 2;
        }

        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        if (verifyProof(a, b, c, input)){
            return root == input[0];
        } else {
            return false;
        }
    }
}
