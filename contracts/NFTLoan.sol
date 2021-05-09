<<<<<<< HEAD
<<<<<<< HEAD
// SPDX-License-Identifier: MIT

/*
name
symbol
Risk Factor
# of Collateral
Past & Current Loans:
Loan Amount
Amount Remaining
Interest Rate
Payment Details
Time Period on Payments
Type of currency
USD Value
Total number of payments/loans
Total Interest
# of Voters - Payout Amount
Any failed loans

Ask: Do we need to make info public when loan is missed? Isnt it better to just show the voters all the info upfront? What kind of info should we show at the start vs make public?
*/
pragma solidity >=0.6.0 <0.8.0;

import "./interfaces/SafeMath.sol";

contract NFTLoan {
    address[16] public loan;
    uint256 item;
    uint256 price;
    uint256 _id;
    bytes32 status;
    string[] public defaults;

    mapping(string => bool) _loanExists;
    mapping(address => uint256[]) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    uint256[] private _allTokens;
    mapping(uint256 => uint256) private _allTokensIndex;

    //  Adding Loan
    function addingLoan(uint256 loanId) public returns (uint256) {
        require(loanId >= 0 && loanId <= 15);

        loan[loanId] = msg.sender;

        return loanId;
    }

    // Retrieving the loan
    function getLoan() public view returns (address[16] memory) {
        return loan;
    }

    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
        private
    {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _ownedTokens[from].length - 1;

        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _mint(address to, uint256 tokenId) private {
        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    // Mint Loan
    function mint(string memory _loan) public {
        require(!_loanExists[_loan]);
        defaults.push(_loan);
        _id = defaults.length -1;
        _mint(msg.sender, _id);
        _loanExists[_loan] = true;
    }
=======
=======
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2
pragma solidity >=0.6.0 <0.8.0;

contract NFTLoan {
    // Events
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    //
    string internal nftName;

    // Attaches the NFT id to a particular address
    mapping(uint256 => address) internal ownerId;

    // Creates a counter for how many NFTokens an account has
    //
    // NOTE ----- Might not need this - We can create another NFT inside
    // another mapping. This should happen on minting.
    mapping(address => uint256) private ownerToNFTokenCount;

    // Attaches the NFT id to a string for the name
    //
    // NOTE --- No need to attach it to a string ID
    mapping(uint256 => string) internal idToUri;

    function _mint(address _to, uint256 _tokenId) internal virtual {
        require(_to != address(0));
        require(ownerId[_tokenId] == address(0));

        _addNFToken(_to, _tokenId);

        // Changed address of event to this
        emit Transfer(address(this), _to, _tokenId);
    }

    function _addNFToken(address _to, uint256 _tokenId) internal virtual {
        require(ownerId[_tokenId] == address(0));

        // Next step would be encrypt the information
        // Create a struct inside the mapping or a different mapping
        // where we could store the data
        ownerId[_tokenId] = _to;
        ownerToNFTokenCount[_to] = ownerToNFTokenCount[_to] + 1;
    }

    function _removeNFToken(address _from, uint256 _tokenId) internal virtual {
        require(ownerId[_tokenId] == _from);
        ownerToNFTokenCount[_from] = ownerToNFTokenCount[_from] - 1;
        delete ownerId[_tokenId];
    }

    // Testing
    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0));
        return _getOwnerNFTCount(_owner);
    }

    function _getOwnerNFTCount(address _owner)
        internal
        view
        virtual
        returns (uint256)
    {
        return ownerToNFTokenCount[_owner];
    }

    // Testing
    function ownerOf(uint256 _tokenId) external view returns (address _owner) {
        _owner = ownerId[_tokenId];
        require(_owner != address(0));
    }

    // Might have to get rid off -- We are accessing the NFT using just wallet address
    function _setTokenUri(uint256 _tokenId, string memory _uri)
        internal
        validNFToken(_tokenId)
    {
        idToUri[_tokenId] = _uri;
        nftName = _uri;
    }

    // Looks good -- Only needs to be accessed by the Oracle after validation goes through
    modifier validNFToken(uint256 _tokenId) {
        require(ownerId[_tokenId] != address(0));
        _;
    }

    //testing
    function name() external view returns (string memory _name) {
        _name = nftName;
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

    modifier canTransfer(uint256 _tokenId) {
        address tokenOwner = ownerId[_tokenId];
        require(tokenOwner == msg.sender);
        _;
    }

    function _transfer(address _to, uint256 _tokenId) internal {
        address from = ownerId[_tokenId];
        _removeNFToken(from, _tokenId);
        _addNFToken(_to, _tokenId);

        emit Transfer(from, _to, _tokenId);
    }

    // Mint is can be the entry point where we check if the Oracle
    // gave this wallet a greenlight and is ready to create the NFT
    function mint(
        address _to,
        uint256 _tokenId,
        string memory _uri
    ) public {
        _mint(_to, _tokenId);
        _setTokenUri(_tokenId, _uri);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        _safeTransferFrom(_from, _to, _tokenId);
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
<<<<<<< HEAD
>>>>>>> 356b79db46ddae412c8182ec59f278828bde0646
=======
>>>>>>> 3848d8968bfc3fce2fc9ef31cedf56cc186704a2
}
