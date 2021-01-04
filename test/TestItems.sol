pragma solidity ^0.7.4;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Items.sol";

contract TestItems {
  // The address of the items contract to be tested
  HBItems items = HBItems(DeployedAddresses.HBItems());

  // The id of the pet that will be used for testing
  uint expectedPetId = 8;

  //The expected owner of adopted pet is this contract
  address ceoAddress = address(this);

  // Testing the adopt() function
  function testCEOCanCreateItem() public {
    uint returnedId = adoption.adopt(expectedPetId);

    Assert.equal(returnedId, expectedPetId, "Adoption of the expected pet should match what is returned.");
  }

  // Testing retrieval of a single pet's owner
  function testGetAdopterAddressByPetId() public {
   address adopter = adoption.adopters(expectedPetId);

   Assert.equal(adopter, expectedAdopter, "Owner of the expected pet should be this contract");
  }

  // Testing retrieval of all pet owners
  function testGetAdopterAddressByPetIdInArray() public {
   // Store adopters in memory rather than contract's storage
   address[16] memory adopters = adoption.getAdopters();

   Assert.equal(adopters[expectedPetId], expectedAdopter, "Owner of the expected pet should be this contract");
  }
}