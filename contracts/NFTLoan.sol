// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
import "./interfaces/SafeMath.sol";

contract NFTLoan {
    string internal nftName;

    mapping(uint256 => address) internal ownerId;

    mapping(address => Data) private userData;

    mapping(address => uint256) private ownerToNFTokenCount;

    mapping(uint256 => string) public idToUri;

    address Oracle;
    address Treasury;

    struct Data {
        uint256 flatfee;
        uint64 riskScore;
        uint64 riskFactor;
        uint64 interestRate;
        uint64 userMaxTier;
    }

    modifier canTransfer(uint256 _tokenId) {
        address tokenOwner = ownerId[_tokenId];
        require(tokenOwner == msg.sender);
        _;
    }

    modifier validNFToken(uint256 _tokenId) {
        require(ownerId[_tokenId] != address(0));
        _;
    }

    modifier validEntry() {
        require(msg.sender == Oracle || msg.sender == Treasury);
        _;
    }

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    constructor() {
        nftName = "CNFT";
        Oracle = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        Treasury = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0));
        return _getOwnerNFTCount(_owner);
    }

    function ownerOf(uint256 _tokenId) external view returns (address _owner) {
        _owner = ownerId[_tokenId];
        require(_owner != address(0));
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) private canTransfer(_tokenId) validNFToken(_tokenId) {
        address tokenOwner = ownerId[_tokenId];
        require(tokenOwner == _from);
        require(_to != address(0));

        _transfer(_to, _tokenId);
    }

    function _transfer(address _to, uint256 _tokenId) internal {
        address from = ownerId[_tokenId];
        _removeNFToken(from, _tokenId);
        _addNFToken(_to, _tokenId);

        emit Transfer(from, _to, _tokenId);
    }

    function name() external view returns (string memory _name) {
        _name = nftName;
    }

    function _setTokenUri(uint256 _tokenId, string memory _uri)
        internal
        validNFToken(_tokenId)
    {
        idToUri[_tokenId] = _uri;
    }

    function _mint(address _to, uint256 _tokenId) internal {
        require(_to != address(0));
        require(ownerId[_tokenId] == address(0));

        _addNFToken(_to, _tokenId);

        emit Transfer(address(this), _to, _tokenId);
    }

    function mintBorrower(
        // Only Oracle
        address _to,
        uint256 _tokenId,
        uint64 _riskScore,
        uint64 _riskFactor,
        uint64 _interestRate,
        uint64 _userMaxTier,
        uint256 _flatfee,
        string memory _uri
    ) public {
        _mint(_to, _tokenId);
        _setTokenUri(_tokenId, _uri);
        userData[_to] = Data(
            _flatfee,
            _riskScore,
            _riskFactor,
            _interestRate,
            _userMaxTier
        );
    }

<<<<<<< HEAD
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        _safeTransferFrom(_from, _to, _tokenId);
    }

    // An encrypter has function for the NFT to protect certain sensitive data.

    function Encrypter(address _to , uint256 _tokenId) 
    public pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(_to , _tokenId));
    }

    
 
    function setEncrypted(address _to, string memory _data) internal {
        data[_to] = _data;
    } 
    
    function seeData(address _from) public view returns (string memory _data) {
        return data[_from];
    }
 
    // ------------------------ Future development ----------------------------
    // Encrypted data
    // Minting two NFTs -- Encrypted data and key do decrypt it
    // If user defaults on loan - Both NFTs is automatically transfered to Oracle
    //
    // Thoughts
    // Loans will have a signature generated on loan application - This signature could
    // be used to link the NFT to the user - It could perhaps be generated on the NFT first
    // and then given to treasure as the key to generate the loan with.
    //
    // Making a payment on loan will connect to the NFT and update the latest loan Status
    // NFT will handle striking system, colleting strikes on missed payments.
=======
    function _addNFToken(address _to, uint256 _tokenId) internal {
        require(ownerId[_tokenId] == address(0));

        ownerId[_tokenId] = _to;
        ownerToNFTokenCount[_to] = ownerToNFTokenCount[_to] + 1;
    }

    function _removeNFToken(address _from, uint256 _tokenId) internal {
        require(ownerId[_tokenId] == _from);
        ownerToNFTokenCount[_from] = ownerToNFTokenCount[_from] - 1;
        delete ownerId[_tokenId];
    }

    function _getOwnerNFTCount(address _owner) internal view returns (uint256) {
        return ownerToNFTokenCount[_owner];
    }

    function getUser(address _from)
        public
        view
        validEntry
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            userData[_from].riskScore,
            userData[_from].riskScore,
            userData[_from].riskScore,
            userData[_from].riskScore,
            userData[_from].riskScore
        );
    }

    function setOracle(address _newOracle) public validEntry {
        Oracle = _newOracle;
    }

    function setTreasury(address _newTreasury) public validEntry {
        Treasury = _newTreasury;
    }
>>>>>>> b1a7b8b14e7e066e9cd3a15b5cc5b8fa50629e37
}
