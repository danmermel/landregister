contract deed {
 
  address public previousDeed;
  address public nextDeed;
  address public owner;
  address public registry;
  boolean public live;
  
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
