contract deed {
 
  address public previousDeed;
  mapping (uint => address) public nextDeeds;
  address public owner;
  address public registry;
  deed_status public status;
  uint public numNextDeeds;
  string public url_to_claim;
  string public claim_hash;
  enum  deed_status { provisional, live, dead }
  
  function deed (address _previousDeed, address _owner) {
    previousDeed = _previousDeed;
    owner = _owner;
    registry = msg.sender;
    status = deed_status.provisional;
    numNextDeeds = 0;
    url_to_claim ='';
    claim_hash='';
  }

  function configure_deed (string _url, string _hash) {
    if (status != deed_status.provisional) throw;
    url_to_claim = _url;
    claim_hash = _hash; 
  } 

  function commit (){
    if (status != deed_status.provisional) throw;
    status = deed_status.live;
  }

  function transferSingle(address _newDeed) {
    if (status != deed_status.live) throw;
    if (msg.sender != registry) throw;
    nextDeeds[0] = _newDeed;
    numNextDeeds = 1;
  } 

  function addChild(address _child) {
    if (status != deed_status.live) throw;
    if (msg.sender != registry) throw;
    nextDeeds[numNextDeeds] = _child;
    numNextDeeds++;
  }
 
  function expire() {
    if (status != deed_status.live) throw;
    if (msg.sender != registry) throw;
    if (numNextDeeds == 0) throw;
    status = deed_status.dead;
  }
}


contract landregister {
  mapping (uint => deed) public theRegister;
  uint public deedCount;

  function landregister () {
    deedCount=0;
  }

  function createDeed(string  _url, string  _hash) {
    var d = new deed(0x0, msg.sender);
    theRegister[deedCount++] = d;
    deed newdeed = deed(d);
    newdeed.configure_deed (_url, _hash);
    newdeed.commit();
  }

  function transferSingle(address _existing_deedid, address _newowner) {
    deed existing_deed = deed(_existing_deedid);
    if (existing_deed.owner() != msg.sender) throw;
    var newdeed_address = new deed(_existing_deedid, _newowner);
    theRegister[deedCount++] = newdeed_address;
    deed newdeed = deed(newdeed_address);
    newdeed.configure_deed('scoot.co.uk', 'abc12345fgfr4567');
    newdeed.commit();
    existing_deed.transferSingle(newdeed_address);  
    existing_deed.expire();
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
