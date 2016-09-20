

contract landregister {
  mapping (uint => deed) public theRegister;
  uint public deedCount;

  function landregister () {
    deedCount=0;
  }

  function createDeed() {
    theRegister[deedCount++] = new deed(0x0, msg.sender);
  }

  function transferSingle(address _deedid, address _newowner) {
    var newdeed = new deed(_deedid, _newowner);
    theRegister[deedCount++] = newdeed;
    //deed.transferSingle(newdeed);  
  }
}
