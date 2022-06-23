pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";



contract ERC721token is ERC721{
    using Strings for uint256;

    event UpdatedURI(
        string _uri
    );

    string private _uri;
    string tokenCurrency;
    uint tokenId;
    uint256 globalPrice;
    address admin;
    mapping(address => uint[]) tokenIds;
    mapping(address => bool) blacklisted;
    mapping(uint => uint) tokenPrice;

    modifier onlyAdmin {
        require(msg.sender == admin, 'access denied');
        _;
    }


    constructor(
        address owner_,
        string memory name_,
        string memory symbol_,
        string memory uri_,
        string memory currency_,
        uint globalPrice_
    )
        ERC721(name_, symbol_)
    {
        uri = uri;
        admin = owner_;
        tokenId = 1;
        tokenCurrency = currency_;
        globalPrice = globalPrice_;
    }


    function _baseURI() internal view virtual override returns (string memory) {
        return _uri;
    }


    function baseURI() external view returns (string memory) {
        return _baseURI();
    }



    function setURI(string memory uri_) external onlyAdmin {
        uri = uri;

        emit UpdatedURI(
            uri_
        );
    }


    function mint(address to, uint price_) external onlyAdmin {
        require(price_>=0);
        
        _safeMint(to, tokenId);
        tokenIds[to].push(tokenId);
        tokenPrice[tokenId] = price_;
        ++tokenId;
    }


    function exists(uint256 tokenId) public view returns (bool){
        return _exists(tokenId);
    }


    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }


    function ownerTokens(address owner_) external view returns( uint[] memory ){
        require(owner_ != address(0));
        return tokenIds[owner_];
    }


    function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) external pure returns (bytes4){
        return 0x150b7a02;
    }


    function blacklistAddress(address blacklist_) external {
        require(blacklist_!=address(0));
        
        if(blacklisted[blacklist_]){
            blacklisted[blacklist_] = false;
        }
        else{
            blacklisted[blacklist_] = true;
        }

    }
    
    
    function getClaimIneligibilityReason(address _userWallet, uint256 _quantity, uint256 _tokenId) public view returns (string memory){
        if(blacklisted[_userWallet]){
            return 'Wallet Blacklisted';
        }
        else{
        return '';
        }
    }


    function unclaimedSupply(uint256 _tokenId) public view returns (uint256){
        if(ownerOf(_tokenId) == address(this)){
        return 1; }
        else{
            return 0;
        }
    }


    function price(uint256 _tokenId) public view returns (uint256){
        if(tokenPrice[_tokenId] == 0){
        return globalPrice;
        }
        else{
            return tokenPrice[_tokenId];
        }
    }


    function claimTo(address _userWallet, uint256 _quantity, uint256 _tokenId) public payable{
        _safeTransfer(address(this), _userWallet, _tokenId, '0x');
    }


    function currency(uint256 _tokenId) public view returns (string memory){
        return tokenCurrency;
    }








}