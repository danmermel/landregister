contract deed {
 
  address public previousDeed;
  mapping (uint => address) public nextDeeds;
  address public owner;
  address public registry;
  bool public live;
  uint public numNextDeeds;
  
  function deed (address _previousDeed, address _owner) {
    previousDeed = _previousDeed;
    owner = _owner;
    registry = msg.sender;
    live = true;
    numNextDeeds = 0;
  }

  function transferSingle(address _newDeed) {
    if (live == false) throw;
    if (msg.sender != registry) throw;
    nextDeeds[0] = _newDeed;
    live = false;
    numNextDeeds = 1;
  } 

  function addChild(address _child) {
    if (live == false) throw;
    if (msg.sender != registry) throw;
    nextDeeds[numNextDeeds] = _child;
    numNextDeeds++;
  }
 
  function expire() {
    if (live == false) throw;
    if (msg.sender != registry) throw;
    if (numNextDeeds == 0) throw;
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

  function transferSingle(address _existing_deedid, address _newowner) {
    deed existing_deed = deed(_existing_deedid);
    if (existing_deed.owner() != msg.sender) throw;
    var newdeed = new deed(_existing_deedid, _newowner);
    theRegister[deedCount++] = newdeed;
    existing_deed.transferSingle(newdeed);  
  }

  function split(address _existing_deedid, uint _parts) {
    deed existing_deed = deed(_existing_deedid);
    if (existing_deed.owner() != msg.sender) throw;
    for(var i = 0; i < _parts; i++) {
      var newdeed = new deed(_existing_deedid, existing_deed.owner());
      theRegister[deedCount++] = newdeed;
      existing_deed.addChild(newdeed);
    }
    existing_deed.expire();
  }
}
