contract deed {

  uint public cost;
  address public owner;
  
  function deed (uint _cost, address _owner) {
    cost = _cost;
    owner = _owner;
  }

}


contract landregister {
  mapping (uint => deed) public theRegister;
  uint public deedCount;

  function landregister () {
    deedCount=0;
  }

  function createDeed(uint _cost) {
    theRegister[deedCount++] = new deed(_cost, msg.sender);
  }

  function transfer(address _deedid, address _newowner) {
    deed = sfkhafakhsfa(_deedid)
    if (msg.sender == deed.owner()) {
      // newdeed = new deed(0, _newowner);
      // theRegister[deedCount++] = newdeed;
      // deed.setDead(_newdeed.address)
      
    } else {
      throw();
    }
  }
}
