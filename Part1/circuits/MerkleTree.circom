pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    
    /* Hashing all the nodes in the current level */
    component hashes[2**n];
    for (var i = 0; i < 2**n; i++){
        hashes[i] = Poseidon(1);
        hashes[i].inputs[0] <== leaves[i];
    }

    /* Creating new arr to hold to levels within the tree */
    component branches[2**n];
    var hashIdx = 0;
    for (var i = 2**n - 1; i >= ((2**n) \ 2); i--){
        branches[i] = Poseidon(2);
        branches[i].inputs[0] <== hashes[hashIdx].out;
        branches[i].inputs[1] <== hashes[hashIdx + 1].out;
        hashIdx += 2;
    }

    /* Building the levels of the tree */
    hashIdx \= 2;
    while (hashIdx > 1){
        var lvlIdx = hashIdx \ 2;
        for (var i = hashIdx; i < 2 * hashIdx; i+=2){
            branches[lvlIdx] = Poseidon(2);
            branches[lvlIdx].inputs[0] <== branches[i].out;
            branches[lvlIdx].inputs[1] <== branches[i + 1].out;
            lvlIdx++;
        }
        hashIdx \= 2;
    }

    /* Return the root node */
    root <== branches[1].out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    /* Declaring a new array full of hashed nodes on path to the root */
    component nodes[n];
    nodes[0] = Poseidon(2);
    nodes[0].inputs[0] <== leaf;
    nodes[0].inputs[1] <== path_elements[0];

    /* Adding nodes to the array that are on the path to the root */
    for (var i = 1; i < n; i++){
        nodes[i] = Poseidon(2);
        nodes[i].inputs[0] <== nodes[i -1].out;
        nodes[i].inputs[1] <== path_elements[i];
    }

    /* Return the last node in the array which must be the root node */
    root <== nodes[n-1].out;
}