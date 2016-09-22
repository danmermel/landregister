contract deed {
 
  address public previousDeed;
  address public nextDeed;
  address public owner;
  address public registry;
  bool public live;
  
  function deed (address _previousDeed, address _owner) {
    previousDeed = _previousDeed;
    owner = _owner;
    registry = msg.sender;
    live = true;
  }

  function transferSingle(address _newDeed) {
    if (live == false) throw;
    if (msg.sender != registry) throw;
    nextDeed = _newDeed;
    live = false;
  } 
}


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
    deed existing_deed = deed(_deedid);
    if (existing_deed.owner() != msg.sender) throw;
    var newdeed = new deed(_deedid, _newowner);
    theRegister[deedCount++] = newdeed;
    existing_deed.transferSingle(newdeed);  
  }
}
