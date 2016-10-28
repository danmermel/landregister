contract deed {
 
  mapping (uint => address) public previousDeeds;
  mapping (uint => address) public nextDeeds;
  address public owner;
  address public registry;
  deed_status public status;
  uint public numNextDeeds;
  uint public numPreviousDeeds;
  bytes32 public url_to_claim;
  bytes32 public claim_hash;
  uint public live_time;
  uint public provisional_time;
  uint public dead_time;
  enum  deed_status { provisional, live, dead }
  
  function deed (address _previousDeed, address _owner) {
    previousDeeds[0] = _previousDeed;
    numPreviousDeeds = 1;
    owner = _owner;
    registry = msg.sender;
    status = deed_status.provisional;
    provisional_time = now;
    live_time = 0 ;
    dead_time = 0;
    numNextDeeds = 0;
    url_to_claim = '';
    claim_hash = '';
  }

  function addParent(address _parent) {
    if (status != deed_status.provisional) throw;
    if (msg.sender != registry) throw;
    previousDeeds[numPreviousDeeds] = _parent;
    numPreviousDeeds++;
  }

  function configure_deed (bytes32 _url, bytes32 _hash) {
    if (status != deed_status.provisional) throw;
    url_to_claim = _url;
    claim_hash = _hash; 
  } 

  function commit (){
    if (status != deed_status.provisional) throw;
    status = deed_status.live;
    live_time = now; 
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
    dead_time = now;
  }
}


contract landregister {
  mapping (uint => deed) public theRegister;
  uint public deedCount;

  function landregister () {
    deedCount=0;
  }

  function createDeed(bytes32 _url, bytes32 _hash) {
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
    newdeed.configure_deed(existing_deed.url_to_claim(), existing_deed.claim_hash());
    newdeed.commit();
    existing_deed.transferSingle(newdeed_address);  
    existing_deed.expire();
  }

  function split(address _existing_deedid, bytes32 _url1, bytes32 _url2, bytes32 _hash1, bytes32 _hash2) {
    deed existing_deed = deed(_existing_deedid);
    if (existing_deed.owner() != msg.sender) throw;
    var newdeed1 = new deed(_existing_deedid, msg.sender);
    var newdeed2 = new deed(_existing_deedid, msg.sender);
    newdeed1.configure_deed(_url1, _hash1);
    newdeed2.configure_deed(_url2, _hash2);
    newdeed1.commit();
    newdeed2.commit();
    theRegister[deedCount++] = newdeed1;
    theRegister[deedCount++] = newdeed2;
    existing_deed.addChild(newdeed1);
    existing_deed.addChild(newdeed2);
    existing_deed.expire();
  }
  
  function join(address _existing_deedid1, address _existing_deedid2, bytes32 _url, bytes32 _hash) {
    deed existing_deed1 = deed(_existing_deedid1);
    if (existing_deed1.owner() != msg.sender) throw;
    deed existing_deed2 = deed(_existing_deedid2);
    if (existing_deed2.owner() != msg.sender) throw;
    var newdeed = new deed(_existing_deedid1, msg.sender);
    newdeed.addParent(_existing_deedid2);
    newdeed.configure_deed(_url, _hash);
    existing_deed1.addChild(newdeed);
    existing_deed2.addChild(newdeed);
    theRegister[deedCount++] = newdeed;
    newdeed.commit();
    existing_deed1.expire();
    existing_deed2.expire();  
  }

}
