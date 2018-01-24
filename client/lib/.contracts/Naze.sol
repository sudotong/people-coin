pragma solidity ^0.4.18;

contract Naze {
    function Naze() public { }
}

contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) payable public returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) payable public returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) payable public returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) payable public returns (bytes32 _id);
    function queryN(uint _timestamp, string _datasource, bytes _argN) payable public returns (bytes32 _id);
    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) payable returns (bytes32 _id);
    function getPrice(string _datasource) public returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);
    function useCoupon(string _coupon) public;
    function setProofType(byte _proofType) public;
    function setConfig(bytes32 _config) public;
    function setCustomGasPrice(uint _gasPrice) public;
    function randomDS_getSessionPubKeyHash() public returns(bytes32);
}
contract OraclizeAddrResolverI {
    function getAddress() public returns (address _addr);
}
contract usingOraclize {
    uint constant day = 60*60*24;
    uint constant week = 60*60*24*7;
    uint constant month = 60*60*24*30;
    byte constant proofType_NONE = 0x00;
    byte constant proofType_TLSNotary = 0x10;
    byte constant proofType_Android = 0x20;
    byte constant proofType_Ledger = 0x30;
    byte constant proofType_Native = 0xF0;
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;

    OraclizeI oraclize;
    modifier oraclizeAPI {
        if((address(OAR)==0)||(getCodeSize(address(OAR))==0))
            oraclize_setNetwork(networkID_auto);

        if(address(oraclize) != OAR.getAddress())
            oraclize = OraclizeI(OAR.getAddress());

        _;
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        oraclize.useCoupon(code);
        _;
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){
        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet
            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
            oraclize_setNetworkName("eth_mainnet");
            return true;
        }
        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet
            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
            oraclize_setNetworkName("eth_ropsten3");
            return true;
        }
        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet
            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
            oraclize_setNetworkName("eth_kovan");
            return true;
        }
        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet
            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
            oraclize_setNetworkName("eth_rinkeby");
            return true;
        }
        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge
            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
            return true;
        }
        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide
            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
            return true;
        }
        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity
            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
            return true;
        }
        return false;
    }

    function __callback(bytes32 myid, string result) public {
        __callback(myid, result, new bytes(0));
    }
    function __callback(bytes32 myid, string result, bytes proof) public {
    }

    function oraclize_useCoupon(string code) oraclizeAPI multi internal {
        oraclize.useCoupon(code);
    }

    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource);
    }

    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource, gaslimit);
    }

    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(0, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(timestamp, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(0, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {
        return oraclize.setProofType(proofP);
    }
    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {
        return oraclize.setCustomGasPrice(gasPrice);
    }
    function oraclize_setConfig(bytes32 config) oraclizeAPI internal {
        return oraclize.setConfig(config);
    }

    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){
        return oraclize.randomDS_getSessionPubKeyHash();
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }

    function parseAddr(string _a) internal returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }

    function strCompare(string _a, string _b) internal returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

    function indexOf(string _haystack, string _needle) internal returns (int) {
        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if(h.length < 1 || n.length < 1 || (n.length > h.length))
            return -1;
        else if(h.length > (2**128 -1))
            return -1;
        else
        {
            uint subindex = 0;
            for (uint i = 0; i < h.length; i ++)
            {
                if (h[i] == n[0])
                {
                    subindex = 1;
                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])
                    {
                        subindex++;
                    }
                    if(subindex == n.length)
                        return int(i);
                }
            }
            return -1;
        }
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    // parseInt
    function parseInt(string _a) internal returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                if (decimals){
                    if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mint *= 10**_b;
        return mint;
    }

    function uint2str(uint i) internal returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    function stra2cbor(string[] arr) internal returns (bytes) {
        uint arrlen = arr.length;

        // get correct cbor output length
        uint outputlen = 0;
        bytes[] memory elemArray = new bytes[](arrlen);
        for (uint i = 0; i < arrlen; i++) {
            elemArray[i] = (bytes(arr[i]));
            outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types
        }
        uint ctr = 0;
        uint cborlen = arrlen + 0x80;
        outputlen += byte(cborlen).length;
        bytes memory res = new bytes(outputlen);

        while (byte(cborlen).length > ctr) {
            res[ctr] = byte(cborlen)[ctr];
            ctr++;
        }
        for (i = 0; i < arrlen; i++) {
            res[ctr] = 0x5F;
            ctr++;
            for (uint x = 0; x < elemArray[i].length; x++) {
                // if there's a bug with larger strings, this may be the culprit
                if (x % 23 == 0) {
                    uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
                    elemcborlen += 0x40;
                    uint lctr = ctr;
                    while (byte(elemcborlen).length > ctr - lctr) {
                        res[ctr] = byte(elemcborlen)[ctr - lctr];
                        ctr++;
                    }
                }
                res[ctr] = elemArray[i][x];
                ctr++;
            }
            res[ctr] = 0xFF;
            ctr++;
        }
        return res;
    }

    function ba2cbor(bytes[] arr) internal returns (bytes) {
        uint arrlen = arr.length;

        // get correct cbor output length
        uint outputlen = 0;
        bytes[] memory elemArray = new bytes[](arrlen);
        for (uint i = 0; i < arrlen; i++) {
            elemArray[i] = (bytes(arr[i]));
            outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types
        }
        uint ctr = 0;
        uint cborlen = arrlen + 0x80;
        outputlen += byte(cborlen).length;
        bytes memory res = new bytes(outputlen);

        while (byte(cborlen).length > ctr) {
            res[ctr] = byte(cborlen)[ctr];
            ctr++;
        }
        for (i = 0; i < arrlen; i++) {
            res[ctr] = 0x5F;
            ctr++;
            for (uint x = 0; x < elemArray[i].length; x++) {
                // if there's a bug with larger strings, this may be the culprit
                if (x % 23 == 0) {
                    uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
                    elemcborlen += 0x40;
                    uint lctr = ctr;
                    while (byte(elemcborlen).length > ctr - lctr) {
                        res[ctr] = byte(elemcborlen)[ctr - lctr];
                        ctr++;
                    }
                }
                res[ctr] = elemArray[i][x];
                ctr++;
            }
            res[ctr] = 0xFF;
            ctr++;
        }
        return res;
    }


    string oraclize_network_name;
    function oraclize_setNetworkName(string _network_name) internal {
        oraclize_network_name = _network_name;
    }

    function oraclize_getNetworkName() internal returns (string) {
        return oraclize_network_name;
    }

    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){
        if ((_nbytes == 0)||(_nbytes > 32)) throw;
        bytes memory nbytes = new bytes(1);
        nbytes[0] = byte(_nbytes);
        bytes memory unonce = new bytes(32);
        bytes memory sessionKeyHash = new bytes(32);
        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();
        assembly {
            mstore(unonce, 0x20)
            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))
            mstore(sessionKeyHash, 0x20)
            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)
        }
        bytes[3] memory args = [unonce, nbytes, sessionKeyHash];
        bytes32 queryId = oraclize_query(_delay, "random", args, _customGasLimit);
        oraclize_randomDS_setCommitment(queryId, keccak256(bytes8(_delay), args[1], sha256(args[0]), args[2]));
        return queryId;
    }

    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {
        oraclize_randomDS_args[queryId] = commitment;
    }

    mapping(bytes32=>bytes32) oraclize_randomDS_args;
    mapping(bytes32=>bool) oraclize_randomDS_sessionKeysHashVerified;

    function verifySig(bytes32 tosignh, bytes dersig, bytes pubkey) internal returns (bool){
        bool sigok;
        address signer;

        bytes32 sigr;
        bytes32 sigs;

        bytes memory sigr_ = new bytes(32);
        uint offset = 4+(uint(dersig[3]) - 0x20);
        sigr_ = copyBytes(dersig, offset, 32, sigr_, 0);
        bytes memory sigs_ = new bytes(32);
        offset += 32 + 2;
        sigs_ = copyBytes(dersig, offset+(uint(dersig[offset-1]) - 0x20), 32, sigs_, 0);

        assembly {
            sigr := mload(add(sigr_, 32))
            sigs := mload(add(sigs_, 32))
        }


        (sigok, signer) = safer_ecrecover(tosignh, 27, sigr, sigs);
        if (address(keccak256(pubkey)) == signer) return true;
        else {
            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);
            return (address(sha3(pubkey)) == signer);
        }
    }

    function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes proof, uint sig2offset) internal returns (bool) {
        bool sigok;

        // Step 6: verify the attestation signature, APPKEY1 must sign the sessionKey from the correct ledger app (CODEHASH)
        bytes memory sig2 = new bytes(uint(proof[sig2offset+1])+2);
        copyBytes(proof, sig2offset, sig2.length, sig2, 0);

        bytes memory appkey1_pubkey = new bytes(64);
        copyBytes(proof, 3+1, 64, appkey1_pubkey, 0);

        bytes memory tosign2 = new bytes(1+65+32);
        tosign2[0] = 1; //role
        copyBytes(proof, sig2offset-65, 65, tosign2, 1);
        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";
        copyBytes(CODEHASH, 0, 32, tosign2, 1+65);
        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);

        if (sigok == false) return false;


        // Step 7: verify the APPKEY1 provenance (must be signed by Ledger)
        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";

        bytes memory tosign3 = new bytes(1+65);
        tosign3[0] = 0xFE;
        copyBytes(proof, 3, 65, tosign3, 1);

        bytes memory sig3 = new bytes(uint(proof[3+65+1])+2);
        copyBytes(proof, 3+65, sig3.length, sig3, 0);

        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);

        return sigok;
    }

    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {
        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)
        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) throw;

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        if (proofVerified == false) throw;

        _;
    }

    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string _result, bytes _proof) internal returns (uint8){
        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)
        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) return 1;

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        if (proofVerified == false) return 2;

        return 0;
    }

    function matchBytes32Prefix(bytes32 content, bytes prefix, uint n_random_bytes) internal returns (bool){
        bool match_ = true;

        for (uint256 i=0; i< n_random_bytes; i++) {
            if (content[i] != prefix[i]) match_ = false;
        }

        return match_;
    }

    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){

        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)
        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;
        bytes memory keyhash = new bytes(32);
        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);
        if (!(sha3(keyhash) == sha3(sha256(context_name, queryId)))) return false;

        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);
        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);

        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)
        if (!matchBytes32Prefix(sha256(sig1), result, uint(proof[ledgerProofLength+32+8]))) return false;

        // Step 4: commitment match verification, sha3(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.
        // This is to verify that the computed args match with the ones specified in the query.
        bytes memory commitmentSlice1 = new bytes(8+1+32);
        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);

        bytes memory sessionPubkey = new bytes(64);
        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;
        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);

        bytes32 sessionPubkeyHash = sha256(sessionPubkey);
        if (oraclize_randomDS_args[queryId] == sha3(commitmentSlice1, sessionPubkeyHash)){ //unonce, nbytes and sessionKeyHash match
            delete oraclize_randomDS_args[queryId];
        } else return false;


        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)
        bytes memory tosign1 = new bytes(32+8+1+32);
        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);
        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) return false;

        // verify if sessionPubkeyHash was verified already, if not.. let's do it!
        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){
            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);
        }

        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];
    }


    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal returns (bytes) {
        uint minLength = length + toOffset;

        if (to.length < minLength) {
            // Buffer too small
            throw; // Should be a better way?
        }

        // NOTE: the offset 32 is added to skip the `size` field of both bytes variables
        uint i = 32 + fromOffset;
        uint j = 32 + toOffset;

        while (i < (32 + fromOffset + length)) {
            assembly {
                let tmp := mload(add(from, i))
                mstore(add(to, j), tmp)
            }
            i += 32;
            j += 32;
        }

        return to;
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    // Duplicate Solidity's ecrecover, but catching the CALL return value
    function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {
        // We do our own memory management here. Solidity uses memory offset
        // 0x40 to store the current end of memory. We write past it (as
        // writes are memory extensions), but don't update the offset so
        // Solidity will reuse it. The memory used here is only needed for
        // this context.

        // FIXME: inline assembly can't access return values
        bool ret;
        address addr;

        assembly {
            let size := mload(0x40)
            mstore(size, hash)
            mstore(add(size, 32), v)
            mstore(add(size, 64), r)
            mstore(add(size, 96), s)

        // NOTE: we can reuse the request memory because we deal with
        //       the return code
            ret := call(3000, 1, 0, size, 128, size, 32)
            addr := mload(size)
        }

        return (ret, addr);
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    function ecrecovery(bytes32 hash, bytes sig) internal returns (bool, address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (sig.length != 65)
            return (false, 0);

        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))

        // Here we are loading the last 32 bytes. We exploit the fact that
        // 'mload' will pad with zeroes if we overread.
        // There is no 'mload8' to do this, but that would be nicer.
            v := byte(0, mload(add(sig, 96)))

        // Alternative solution:
        // 'byte' is not working due to the Solidity parser, so lets
        // use the second best option, 'and'
        // v := and(mload(add(sig, 65)), 255)
        }

        // albeit non-transactional signatures are not specified by the YP, one would expect it
        // to match the YP range of [27, 28]
        //
        // geth uses [0, 1] and some clients have followed. This might change, see:
        //  https://github.com/ethereum/go-ethereum/issues/2053
        if (v < 27)
            v += 27;

        if (v != 27 && v != 28)
            return (false, 0);

        return safer_ecrecover(hash, v, r, s);
    }

}
// </ORACLIZE_API>

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
//contract Ownable {
//    address public owner;
//
//
//    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
//
//
//    /**
//     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
//     * account.
//     */
//    function Ownable() public {
//        owner = msg.sender;
//    }
//
//
//    /**
//     * @dev Throws if called by any account other than the owner.
//     */
//    modifier onlyOwner() {
//        require(msg.sender == owner);
//        _;
//    }
//
//
//    /**
//     * @dev Allows the current owner to transfer control of the contract to a newOwner.
//     * @param newOwner The address to transfer ownership to.
//     */
//    function transferOwnership(address newOwner) public onlyOwner {
//        require(newOwner != address(0));
//        OwnershipTransferred(owner, newOwner);
//        owner = newOwner;
//    }
//
//}

contract WagersController is Ownable {
    mapping (address => bool) private isAuthorized;
    Mevu mevu;
    Wagers wagers;
    Events events;
    Admin admin;
    Rewards rewards;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    modifier requireMinWager() {
        require (msg.value >= admin.getMinWagerAmount());
        _;
    }

    modifier eventUnlocked(bytes32 eventId){
        require (!events.getLocked(eventId));
        _;
    }

    modifier wagerUnlocked (bytes32 wagerId) {
        require (!wagers.getLocked(wagerId));
        _;
    }

    modifier mustBeTaken (bytes32 wagerId) {
        require (wagers.getTaker(wagerId) != address(0));
        _;
    }

    modifier notSettled(bytes32 wagerId) {
        require (!wagers.getSettled(wagerId));
        _;
    }

    modifier checkBalance (uint wagerValue) {
        require (rewards.getUnlockedEthBalance(msg.sender) + msg.value >= wagerValue);
        _;
    }

    modifier notPaused() {
        require (!mevu.getContractPaused());
        _;
    }


    modifier onlyBettor (bytes32 wagerId) {
        require (msg.sender == wagers.getMaker(wagerId) || msg.sender == wagers.getTaker(wagerId));
        _;
    }

    modifier notTaken (bytes32 wagerId) {
        require (wagers.getTaker(wagerId) == address(0));
        _;
    }

    modifier notMade (bytes32 wagerId) {
        require (wagers.getMaker(wagerId) != address(0));
        _;
    }

    function grantAuthority (address nowAuthorized) onlyOwner {
        isAuthorized[nowAuthorized] = true;
    }

    function removeAuthority (address unauthorized) onlyOwner {
        isAuthorized[unauthorized] = false;
    }

    function setMevuContract (address thisAddr) external onlyOwner {
        mevu = Mevu(thisAddr);
    }

    function setWagersContract (address thisAddr) external onlyOwner {
        wagers = Wagers(thisAddr);
    }

    function setRewardsContract (address thisAddr) external onlyOwner {
        rewards = Rewards(thisAddr);
    }

    function setAdminContract (address thisAddr) external onlyOwner {
        admin = Admin(thisAddr);
    }

    function setEventsContract (address thisAddr) external onlyOwner {
        events = Events(thisAddr);
    }

    /** @dev Creates a new Standard wager for a user to take and adds it to the standardWagers mapping.
      * @param wagerId sha3 hash of the msg.sender concat timestamp.
      * @param eventId int id for the standard event the wager is based on.
      * @param odds decimal of maker chosen odds * 100.
      */
    function makeWager(
        bytes32 wagerId,
        uint value,
        bytes32 eventId,
        uint odds,
        uint makerChoice
    )
    notMade(wagerId)
    eventUnlocked(eventId)
    requireMinWager
    checkBalance(value)
    notPaused
    payable
    {

        uint takerChoice;
        if (makerChoice == 1) {
            takerChoice = 2;
        } else {
            takerChoice = 1;
        }
        uint winningValue = value + (value / (odds/100));
        wagers.makeWager  ( wagerId,
            eventId,
            value,
            winningValue,
            makerChoice,
            takerChoice,
            odds,
            0,
            0,
            msg.sender);
        transferEthToMevu(msg.value);
        mevu.addToPlayerFunds(msg.value);
        //events.addWager(eventId, wagerId);
        rewards.addEth(msg.sender, msg.value);
        rewards.subUnlockedEth(msg.sender, (value - msg.value));
    }

    /** @dev Takes a listed wager for a user -- adds address to StandardWager struct.
     * @param id sha3 hash of the msg.sender concat timestamp.
     */
    function takeWager (
        bytes32 id
    )
    eventUnlocked(wagers.getEventId(id))
    wagerUnlocked(id)
    notPaused
    payable
    {
        uint expectedValue = wagers.getOrigValue(id) / (wagers.getOdds(id) / 100);
        require (rewards.getUnlockedEthBalance(msg.sender) + msg.value >= expectedValue);
        address taker = msg.sender;
        transferEthToMevu(msg.value);
        mevu.addToPlayerFunds(msg.value);
        rewards.subUnlockedEth(msg.sender, (expectedValue - msg.value));
        rewards.addEth(msg.sender, msg.value);
        uint winningValue = wagers.getOrigValue(id) + expectedValue;
        wagers.setTaker(id, taker);
        wagers.setLocked(id);
        wagers.setWinningValue(id, winningValue);
        events.addWager(wagers.getEventId(id), winningValue);

    }

    function cancelWager (
        bytes32 wagerId,
        bool withdraw
    )
    onlyBettor(wagerId)
    notPaused
    notTaken(wagerId)
    wagerUnlocked(wagerId)
    {
        wagers.setLocked(wagerId);
        wagers.setSettled(wagerId);
        if (withdraw) {
            rewards.subEth(msg.sender, wagers.getOrigValue(wagerId));
            msg.sender.transfer (wagers.getOrigValue(wagerId));
        } else {
            rewards.addUnlockedEth(msg.sender, wagers.getOrigValue(wagerId));
        }
    }

    function requestWagerCancel(bytes32 wagerId)
    mustBeTaken(wagerId)
    notSettled(wagerId)
    {
        if (msg.sender == wagers.getTaker(wagerId)) {
            if (wagers.getMakerCancelRequest(wagerId)) {
                wagers.setSettled(wagerId);
                events.removeWager(wagers.getEventId(wagerId), wagers.getWinningValue(wagerId));
                rewards.addUnlockedEth(wagers.getMaker(wagerId), wagers.getOrigValue(wagerId));
                rewards.addUnlockedEth(wagers.getTaker(wagerId),  (wagers.getWinningValue(wagerId) - wagers.getOrigValue(wagerId)));
            } else {
                wagers.setTakerCancelRequest(wagerId);
            }
        }
        if (msg.sender ==  wagers.getMaker(wagerId)) {
            if (wagers.getTakerCancelRequest(wagerId)) {
                wagers.setSettled(wagerId);
                events.removeWager(wagers.getEventId(wagerId), wagers.getWinningValue(wagerId));
                rewards.addUnlockedEth(wagers.getMaker(wagerId), wagers.getOrigValue(wagerId));
                rewards.addUnlockedEth(wagers.getTaker(wagerId),  (wagers.getWinningValue(wagerId) - wagers.getOrigValue(wagerId)));
            } else {
                wagers.setMakerCancelRequest(wagerId);
            }
        }
    }

    function transferEthToMevu (uint amount) internal {
        mevu.transfer(amount);
    }

}

contract Wagers is Ownable {

    Events events;
    Rewards rewards;
    Mevu mevu;

    struct Wager {
        bytes32 eventId;
        uint origValue;
        uint winningValue;
        uint makerChoice;
        uint takerChoice;
        uint odds;
        uint makerWinnerVote;
        uint takerWinnerVote;
        address maker;
        address taker;
        address winner;
        address loser;
        bool makerCancelRequest;
        bool takerCancelRequest;
        bool locked;
        bool settled;
    }

    mapping (bytes32 => Wager) wagersMap;
    mapping (address => mapping (bytes32 => bool)) recdRefund;
    mapping (address => bool) private isAuthorized;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    function grantAuthority (address nowAuthorized) external onlyOwner {
        isAuthorized[nowAuthorized] = true;
    }

    function removeAuthority (address unauthorized) external onlyOwner {
        isAuthorized[unauthorized] = false;
    }

    function makeWager (
        bytes32 wagerId,
        bytes32 eventId,
        uint origValue,
        uint winningValue,
        uint makerChoice,
        uint takerChoice,
        uint odds,
        uint makerWinnerVote,
        uint takerWinnerVote,
        address maker
    )
    external
    onlyAuth
    {
        Wager memory thisWager = Wager (eventId,
            origValue,
            winningValue,
            makerChoice,
            takerChoice,
            odds,
            makerWinnerVote,
            takerWinnerVote,
            maker,
            address(0),
            address(0),
            address(0),
            false,
            false,
            false,
            false);
        wagersMap[wagerId] = thisWager;
    }

    function setLocked (bytes32 wagerId) external onlyAuth {
        wagersMap[wagerId].locked = true;
    }

    function setSettled (bytes32 wagerId) external onlyAuth {
        wagersMap[wagerId].settled = true;
    }

    function setMakerWinVote (bytes32 id, uint winnerVote) external onlyAuth {
        wagersMap[id].makerWinnerVote = winnerVote;
    }

    function setTakerWinVote (bytes32 id, uint winnerVote) external onlyAuth {
        wagersMap[id].takerWinnerVote = winnerVote;
    }

    function setRefund (address bettor, bytes32 wagerId) external onlyAuth {
        recdRefund[bettor][wagerId] = true;
    }

    function setMakerCancelRequest (bytes32 id) external onlyAuth {
        wagersMap[id].makerCancelRequest = true;
    }

    function setTakerCancelRequest (bytes32 id) external onlyAuth {
        wagersMap[id].takerCancelRequest = true;
    }

    function setTaker (bytes32 wagerId, address taker) external onlyAuth {
        wagersMap[wagerId].taker = taker;
    }

    function setWinner (bytes32 id, address winner) external onlyAuth {
        wagersMap[id].winner = winner;
    }

    function setLoser (bytes32 id, address loser) external onlyAuth {
        wagersMap[id].loser = loser;
    }

    function setWinningValue (bytes32 wagerId, uint value) external onlyAuth {
        wagersMap[wagerId].winningValue = value;
    }

    function getEventId(bytes32 wagerId) external view returns (bytes32) {
        return wagersMap[wagerId].eventId;
    }

    function getLocked (bytes32 id)  view returns (bool) {
        return wagersMap[id].locked;
    }

    function getSettled (bytes32 id)  view returns (bool) {
        return wagersMap[id].settled;
    }

    function getMaker(bytes32 id)  view returns (address) {
        return wagersMap[id].maker;
    }

    function getTaker(bytes32 id)  view returns (address) {
        return wagersMap[id].taker;
    }

    function getMakerChoice (bytes32 id) external view returns (uint) {
        return wagersMap[id].makerChoice;
    }

    function getTakerChoice (bytes32 id) external view returns (uint) {
        return wagersMap[id].takerChoice;
    }

    function getMakerCancelRequest (bytes32 id) external view returns (bool) {
        return wagersMap[id].makerCancelRequest;
    }

    function getTakerCancelRequest (bytes32 id) external view returns (bool) {
        return wagersMap[id].takerCancelRequest;
    }

    function getMakerWinVote (bytes32 id) external view returns (uint) {
        return wagersMap[id].makerWinnerVote;
    }

    function getRefund (address bettor, bytes32 wagerId) external view returns (bool) {
        return recdRefund[bettor][wagerId];
    }

    function getTakerWinVote (bytes32 id) external view returns (uint) {
        return wagersMap[id].takerWinnerVote;
    }

    function getOdds (bytes32 id) external view returns (uint) {
        return wagersMap[id].odds;
    }

    function getOrigValue (bytes32 id) external view returns (uint) {
        return wagersMap[id].origValue;
    }

    function getWinningValue (bytes32 id) external view returns (uint) {
        return wagersMap[id].winningValue;
    }

    function getWinner (bytes32 id) external view returns (address) {
        return wagersMap[id].winner;
    }

    function getLoser (bytes32 id) external view returns (address) {
        return wagersMap[id].loser;
    }

}
/**
 * @title MvuToken
 * @dev Mintable ERC20 Token which also controls a one-time bet contract, token transfers locked until sale ends.
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

// TODO import MintableToken



contract MvuTokenBet is Ownable /*is MintableToken */{
    event TokensMade(address indexed to, uint amount);
    uint  saleEnd = 1519022651; // TODO: Update with actual date
    uint betsEnd = 1519000651;  // TODO: Update with actual date
    uint tokenCap = 100000000; // TODO: Update with actual cap
    bool public mintingFinished = false;

    MvuTokenBet public bet;
    uint totalSupply = 0;
    mapping (address => uint) private balances;

    modifier saleOver () {
        require (now > saleEnd);
        _;
    }

    modifier canMint() {
        if(mintingFinished) throw;
        _;
    }

    modifier betsAllowed () {
        require (now < betsEnd);
        _;
    }

    modifier underCap (uint tokens) {
        require(totalSupply + tokens < tokenCap);
        _;
    }

    function MvuToken (uint initFounderSupply) {
        balances[msg.sender] = initFounderSupply;
        TokensMade(msg.sender, initFounderSupply);
        totalSupply += initFounderSupply;
        //bet = createBetContract();
    }

    function transfer (address _to, uint _value) saleOver public returns (bool) {
        //        super.transfer(_to, _value);
    }

    function mint(address _to, uint _amount) onlyOwner canMint underCap(_amount) public returns (bool) {
        //        super.mint(_to, _amount);
    }


}

contract Rewards is Ownable {
    mapping (address => bool) private isAuthorized;
    Admin admin;
    Wagers wagers;
    Oracles oracles;
    mapping(address => int) public playerRep;
    mapping (address => int) public oracleRep;
    mapping (address => uint) public ethBalance;
    mapping (address => uint) public mvuBalance;
    mapping(address => uint) public unlockedEthBalance;
    mapping (address => uint) public unlockedMvuBalance;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    function grantAuthority (address nowAuthorized) onlyOwner {
        isAuthorized[nowAuthorized] = true;
    }

    function removeAuthority (address unauthorized) onlyOwner {
        isAuthorized[unauthorized] = false;
    }

    function setOraclesContract (address thisAddr) external onlyOwner {
        oracles = Oracles(thisAddr);
    }

    function setAdminContract (address thisAddr) external onlyOwner {
        admin = Admin(thisAddr);
    }

    function setWagersContract (address thisAddr) external onlyOwner {
        wagers = Wagers(thisAddr);
    }

    function getEthBalance(address user) external view returns (uint) {
        return ethBalance[user];
    }

    function getMvuBalance(address user) external view returns (uint) {
        return mvuBalance[user];
    }

    function getUnlockedEthBalance(address user) external view returns (uint) {
        return unlockedEthBalance[user];
    }

    function getUnlockedMvuBalance(address user) external view returns (uint) {
        return unlockedMvuBalance[user];
    }

    function subEth(address user, uint amount) external onlyAuth {
        ethBalance[user] -= amount;
    }

    function subMvu(address user, uint amount) external onlyAuth {
        mvuBalance[user] -= amount;
    }

    function addEth(address user, uint amount) external onlyAuth {
        ethBalance[user] += amount;
    }

    function addMvu(address user, uint amount) external onlyAuth {
        mvuBalance[user] += amount;
    }

    function subUnlockedMvu(address user, uint amount) external onlyAuth {
        unlockedMvuBalance[user] -= amount;
    }

    function subUnlockedEth(address user, uint amount) external onlyAuth {
        unlockedEthBalance[user] -= amount;
    }

    function addUnlockedMvu(address user, uint amount) external onlyAuth {
        unlockedMvuBalance[user] += amount;
    }

    function addUnlockedEth(address user, uint amount) external onlyAuth {
        unlockedEthBalance[user] += amount;
    }

    function subOracleRep(address oracle, int value) external onlyAuth {
        oracleRep[oracle] -= value;
    }

    function subPlayerRep(address player, int value) external onlyAuth {
        playerRep[player] -= value;
    }

    function addOracleRep(address oracle, int value) external onlyAuth {
        oracleRep[oracle] += value;
    }

    function addPlayerRep(address player, int value) external onlyAuth {
        playerRep[player] += value;
    }
}

contract OraclesController is Ownable {
    Events events;
    Rewards rewards;
    Admin admin;
    Wagers wagers;
    MvuTokenBet mvuToken;
    Mevu mevu;
    Oracles oracles;

    modifier eventUnlocked(bytes32 eventId){
        require (!events.getLocked(eventId));
        _;
    }

    modifier eventLocked (bytes32 eventId){
        require (events.getLocked(eventId));
        _;
    }

    modifier onlyOracle (bytes32 eventId) {
        require (oracles.checkOracleStatus(msg.sender, eventId));
        _;
    }

    modifier mustBeAllowed (bytes32 eventId) {
        require (oracles.getAllowed(eventId, msg.sender));
        _;
    }

    modifier mustBeVoteReady(bytes32 eventId) {
        require (events.getVoteReady(eventId));
        _;
    }

    modifier notClaimed (bytes32 eventId) {
        require (!oracles.getPaid(eventId, msg.sender));
        _;
    }

    function setRewardsContract   (address thisAddr) external onlyOwner {
        rewards = Rewards(thisAddr);
    }

    function setEventsContract (address thisAddr) external onlyOwner {
        events = Events(thisAddr);
    }

    function setAdminContract (address thisAddr) external onlyOwner {
        admin = Admin(thisAddr);
    }

    function setMvuTokenContract (address thisAddr) external onlyOwner {
        mvuToken = MvuTokenBet(thisAddr);
    }

    function setMevuContract (address thisAddr) external onlyOwner {
        mevu = Mevu(thisAddr);
    }

    /** @dev Registers a user as an Oracle for the chosen event. Before being able to register the user must
      * allow the contract to move their MVU through the Token contract.
      * @param eventId int id for the standard event the oracle is registered for.
      * @param mvuStake Amount of mvu (in lowest base unit) staked.
      * @param winnerVote uint of who they voted as winning
    */
    function registerOracle (
        bytes32 eventId,
        uint mvuStake,
        uint winnerVote
    )
    eventUnlocked(eventId)
    mustBeVoteReady(eventId)
    mustBeAllowed(eventId)
    {
        //require (keccak256(strConcat(addrToString(msg.sender),  bytes32ToString(eventId))) == oracleId);
        require(mvuStake >= admin.getMinOracleStake());
        require(winnerVote == 1 || winnerVote == 2 || winnerVote == 3);
        bytes32 empty;
        if (oracles.getLastEventOraclized(msg.sender) == empty) {
            oracles.addToOracleList(msg.sender);
        }
        oracles.setLastEventOraclized(msg.sender, eventId) ;
        transferTokensToMevu(msg.sender, mvuStake);
        if (oracles.getMvuStake(eventId, msg.sender) == 0) {
            oracles.addOracle (msg.sender, eventId, mvuStake, winnerVote);
            rewards.addMvu(msg.sender, mvuStake);
        }
    }

    // Called by oracle to get paid after event voting closes
    function claimReward (bytes32 eventId )
    onlyOracle(eventId)
    notClaimed(eventId)
    eventLocked(eventId)
    {
        oracles.setPaid(msg.sender, eventId);
        uint ethReward;
        uint mvuReward;
        uint mvuRewardPool;
        if (events.getWinner(eventId) == 1) {
            mvuRewardPool = oracles.getTotalOracleStake(eventId) - oracles.getStakeForOne(eventId);
        }
        if (events.getWinner(eventId) == 2) {
            mvuRewardPool = oracles.getTotalOracleStake(eventId) - oracles.getStakeForTwo(eventId);
        }
        if (events.getWinner(eventId) == 3) {
            mvuRewardPool = oracles.getTotalOracleStake(eventId) - oracles.getStakeForThree(eventId);
        }

        uint twoPercentRewardPool = 2 * events.getTotalAmountResolvedWithoutOracles(eventId)/100;
        uint threePercentRewardPool = 3 * (events.getTotalAmountBet(eventId) - events.getTotalAmountResolvedWithoutOracles(eventId))/100;
        uint totalRewardPool = (threePercentRewardPool/12) + (threePercentRewardPool/3) + (twoPercentRewardPool/8);
        uint stakePercentageTimesTen = 1000 * oracles.getMvuStake(eventId, msg.sender);
        stakePercentageTimesTen /= oracles.getTotalOracleStake(eventId);

        if (oracles.getWinnerVote(eventId, msg.sender) == events.getWinner(eventId)) {
            ethReward = (totalRewardPool/1000) * stakePercentageTimesTen;
            rewards.addUnlockedEth(msg.sender, ethReward);
            rewards.addEth(msg.sender, ethReward);

            mvuReward = (mvuRewardPool/1000) * stakePercentageTimesTen;
            rewards.addMvu(msg.sender, mvuReward);
            mvuReward += oracles.getMvuStake(eventId, msg.sender);
            rewards.addUnlockedMvu(msg.sender, mvuReward);



        } else {
            mvuReward = oracles.getMvuStake(eventId, msg.sender)/2;
            rewards.subMvu(msg.sender, mvuReward);
            rewards.addUnlockedMvu(msg.sender, mvuReward);
            rewards.subOracleRep(msg.sender, admin.getOracleRepPenalty());
        }


    }

    // called by oracle to get refund if not enough oracles register and oracle settlement is cancelled
    function claimRefund (bytes32 eventId) {


    }



    function transferTokensToMevu (address oracle, uint mvuStake) internal {
        // TODO uncomment when MintableToken is implemented
        // mvuToken.transferFrom(oracle, address(mevu), mvuStake);
    }


}

contract Oracles is Ownable {

    struct OracleStruct {
        bytes32 eventId;
        uint mvuStake;
        uint winnerVote;
        bool paid;
    }

    struct EventStruct {
        uint oracleVotes;
        uint totalOracleStake;
        uint votesForOne;
        uint votesForTwo;
        uint votesForThree;
        uint stakeForOne;
        uint stakeForTwo;
        uint stakeForThree;
        mapping (address => uint) oracleStakes;
        address[] oracles;
    }

    uint oracleServiceFee = 3; //Percent
    mapping (address => mapping(bytes32 => bool)) rewardClaimed;
    mapping (address => mapping(bytes32 => bool)) preventedFromOraclize;
    mapping (address => bool) private isAuthorized;
    mapping (address => mapping (bytes32 => OracleStruct)) oracleStructs;
    mapping (bytes32 => EventStruct) eventStructs;
    mapping (address => bytes32) lastEventOraclized;
    //mapping(address => bytes32[])  oracles;
    //mapping(bytes32 => OracleStruct) oracleStructs;
    address[] oracleList; // List of people who have ever registered as an oracle
    address[] correctOracles;
    bytes32[] correctStructs;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    function grantAuthority (address nowAuthorized) onlyOwner {
        isAuthorized[nowAuthorized] = true;
    }

    function removeAuthority (address unauthorized) onlyOwner {
        isAuthorized[unauthorized] = false;
    }

    function removeOracle (address oracle, bytes32 eventId) onlyAuth {
        OracleStruct memory thisOracle;
        bytes32 empty;
        thisOracle = OracleStruct (empty,0,0, false);
        oracleStructs[oracle][eventId] = thisOracle;
    }

    function addOracle (address oracle, bytes32 eventId, uint mvuStake, uint winnerVote) onlyAuth {
        OracleStruct memory thisOracle;
        thisOracle = OracleStruct (eventId, mvuStake, winnerVote, false);
        oracleStructs[msg.sender][eventId] = thisOracle;
        if (winnerVote == 1) {
            eventStructs[eventId].votesForOne ++;
        }
        if (winnerVote == 2) {
            eventStructs[eventId].votesForTwo ++;
        }
        if (winnerVote == 3) {
            eventStructs[eventId].votesForThree ++;
        }
        eventStructs[eventId].oracleStakes[oracle] = mvuStake;
        eventStructs[eventId].totalOracleStake += mvuStake;
        eventStructs[eventId].oracleVotes += 1;
    }


    function addToOracleList (address oracle) onlyAuth {
        oracleList.push(oracle);
    }

    function setPaid (address oracle, bytes32 eventId) onlyAuth {
        oracleStructs[oracle][eventId].paid = true;
    }

    function setLastEventOraclized (address oracle, bytes32 eventId) onlyAuth {
        lastEventOraclized[oracle] = eventId;
    }

    function setAllowed (address oracle, bytes32 eventId, bool allowance) onlyAuth {
        preventedFromOraclize[msg.sender][eventId] = !allowance;
    }

    function getAllowed (bytes32 eventId, address oracle) view returns (bool) {
        return !preventedFromOraclize[oracle][eventId];
    }

    function getWinnerVote(bytes32 eventId, address oracle)  view returns (uint) {
        return oracleStructs[oracle][eventId].winnerVote;
    }

    function getPaid (bytes32 eventId, address oracle)  view returns (bool) {
        return oracleStructs[oracle][eventId].paid;
    }

    function getVotesForOne (bytes32 eventId) view returns (uint) {
        return eventStructs[eventId].votesForOne;
    }

    function getVotesForTwo (bytes32 eventId) view returns (uint) {
        return eventStructs[eventId].votesForTwo;
    }

    function getVotesForThree (bytes32 eventId) view returns (uint) {
        return eventStructs[eventId].votesForThree;
    }

    function getStakeForOne (bytes32 eventId) view returns (uint) {
        return eventStructs[eventId].stakeForOne;
    }

    function getStakeForTwo (bytes32 eventId) view returns (uint) {
        return eventStructs[eventId].stakeForTwo;
    }

    function getStakeForThree (bytes32 eventId) view returns (uint) {
        return eventStructs[eventId].stakeForThree;
    }

    function getMvuStake (bytes32 eventId, address oracle) view returns (uint) {
        return oracleStructs[oracle][eventId].mvuStake;
    }

    function getEventOraclesLength (bytes32 eventId) external view returns (uint) {
        return eventStructs[eventId].oracles.length;
    }

    function getOracleVotesNum (bytes32 eventId) view returns (uint) {
        return eventStructs[eventId].oracleVotes;
    }


    function getTotalOracleStake (bytes32 eventId) external view returns (uint) {
        return eventStructs[eventId].totalOracleStake;
    }

    function getOracleListLength()  view returns (uint) {
        return oracleList.length;
    }

    function getOracleListAt (uint index)  view returns (address) {
        return oracleList[index];
    }

    function getLastEventOraclized (address oracle) view returns (bytes32) {
        return lastEventOraclized[oracle];
    }

    function checkOracleStatus (address oracle, bytes32 eventId) external view returns (bool) {
        if (eventStructs[eventId].oracleStakes[oracle] == 0) {
            return false;
        } else {
            return true;
        }
    }

}



contract Migrations {
    address public owner;
    uint public last_completed_migration;

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function Migrations() public {
        owner = msg.sender;
    }

    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;
    }

    function upgrade(address new_address) public restricted {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}


contract Mevu is Ownable, usingOraclize {

    address mevuWallet;
    Events events;
    Admin admin;
    Wagers wagers;
    Oracles oracles;
    Rewards rewards;
    MvuTokenBet mvuToken;

    bool  contractPaused = false;
    bool  randomNumRequired = false;
    bool settlementPeriod = false;
    uint lastIteratedIndex = 0;
    uint  mevuBalance = 0;
    uint  lotteryBalance = 0;
    uint oraclizeGasLimit = 500000;
    uint oracleServiceFee = 3; //Percent
    //  TODO: Set equal to launch date + one month in unix epoch seocnds
    uint  newMonth = 1515866437;
    uint  monthSeconds = 2592000;
    uint public playerFunds;

    mapping (bytes32 => bool) validIds;
    mapping (address => bool) abandoned;
    mapping (address => bool) private isAuthorized;

    event newOraclizeQuery (string description);

    modifier notPaused() {
        require (!contractPaused);
        _;
    }

    modifier onlyBettor (bytes32 wagerId) {
        require (msg.sender == wagers.getMaker(wagerId) || msg.sender == wagers.getTaker(wagerId));
        _;
    }

    modifier onlyPaused() {
        require (contractPaused);
        _;
    }

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }


    modifier eventUnlocked(bytes32 eventId){
        require (!events.getLocked(eventId));
        _;
    }

    modifier wagerUnlocked (bytes32 wagerId) {
        require (!wagers.getLocked(wagerId));
        _;
    }

    modifier mustBeVoteReady(bytes32 eventId) {
        require (events.getVoteReady(eventId));
        _;
    }

    modifier mustBeTaken (bytes32 wagerId) {
        require (wagers.getTaker(wagerId) != address(0));
        _;
    }

    modifier notSettled(bytes32 wagerId) {
        require (!wagers.getSettled(wagerId));
        _;
    }

    function () payable {
        if (msg.sender != address(wagers)) {
            mevuBalance += msg.value;
        }
    }

    // Constructor
    function Mevu () payable {
        //OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
        mevuWallet = msg.sender;
        mvuToken = MvuTokenBet(0x10f5125ECEdd1a0c13de969811A8c8Aa2139eCeb); //TODO: Update with actual token address
    }

    function grantAuthority (address nowAuthorized) onlyOwner {
        isAuthorized[nowAuthorized] = true;
    }

    function removeAuthority (address unauthorized) onlyOwner {
        isAuthorized[unauthorized] = false;
    }

    function setEventsContract (address thisAddr) external onlyOwner {
        events = Events(thisAddr);
    }

    function setOraclesContract (address thisAddr) external onlyOwner {
        oracles = Oracles(thisAddr);
    }

    function setRewardsContract   (address thisAddr) external onlyOwner {
        rewards = Rewards(thisAddr);
    }

    function setAdminContract (address thisAddr) external onlyOwner {
        admin = Admin(thisAddr);
    }

    function setWagersContract (address thisAddr) external onlyOwner {
        wagers = Wagers(thisAddr);
    }

    // function setMvuTokenContract (address thisAddr) external onlyOwner {
    //     mvuToken = MvuToken(thisAddr);
    // }

    function __callback (bytes32 myid, string result) notPaused {
        require(validIds[myid]);
        require(msg.sender == oraclize_cbAddress());

        if (randomNumRequired) {
            uint maxRange = 2**(8* 7); // this is the highest uint we want to get. It should never be greater than 2^(8*N), where N is the number of random bytes we had asked the datasource to return
            uint randomNumber = uint(keccak256(result)) % maxRange; // this is an efficient way to get the uint out in the [0, maxRange] range
            randomNumRequired = false;
            address potentialWinner = oracles.getOracleListAt(randomNumber);
            payoutLottery(potentialWinner);
        } else {

            events.determineEventStage(events.getActiveEventId(lastIteratedIndex), lastIteratedIndex);
            lastIteratedIndex ++;
            bytes32 queryId;

            if (lastIteratedIndex == events.getActiveEventsLength()) {
                lastIteratedIndex = 0;
                checkLottery();
                newOraclizeQuery("Last active event processed, callback being set for admin interval.");
                queryId =  oraclize_query(admin.getCallbackInterval(), "URL", "");
                validIds[queryId] = true;
            } else {
                queryId = oraclize_query("URL", "");
                validIds[queryId] = true;
            }
        }
    }

    function setMevuWallet (address newAddress) onlyOwner {
        mevuWallet = newAddress;
    }

    function abandonContract() external onlyPaused {
        require(!abandoned[msg.sender]);
        abandoned[msg.sender] = true;
        uint ethBalance =  rewards.getEthBalance(msg.sender);
        uint mvuBalance = rewards.getMvuBalance(msg.sender);
        playerFunds -= ethBalance;
        if (ethBalance > 0) {
            msg.sender.transfer(ethBalance);
        }
        if (mvuBalance > 0) {
            mvuToken.transfer(msg.sender, mvuBalance);
        }
    }


    function withdraw(
        uint eth,
        uint mvu
    )
    notPaused
    external
    {
        require (rewards.getUnlockedEthBalance(msg.sender) >= eth);
        rewards.subUnlockedEth(msg.sender, eth);
        rewards.subEth(msg.sender, eth);
        playerFunds -= eth;
        msg.sender.transfer(eth);
        require (rewards.getUnlockedMvuBalance(msg.sender) >= mvu);
        rewards.subUnlockedMvu(msg.sender, mvu);
        rewards.subMvu(msg.sender, mvu);
        mvuToken.transfer (msg.sender, mvu);

    }

    /** @dev Enters the makers vote for who actually won after the event is over.
      * @param wagerId bytes32 id for the wager.
      * @param winnerVote number representing who the creator thinks won the match
      */
    function submitVote (
        bytes32 wagerId,
        uint winnerVote
    )
    onlyBettor(wagerId)
    mustBeVoteReady(wagers.getEventId(wagerId))
    notPaused
    {
        bytes32 eventId = wagers.getEventId(wagerId);
        if (msg.sender == wagers.getMaker(wagerId)){
            wagers.setMakerWinVote (wagerId, winnerVote);
        } else {
            wagers.setTakerWinVote (wagerId, winnerVote);
        }
        uint eventWinner = events.getWinner(eventId);
        if (eventWinner != 0 && eventWinner != 3) {
            lateSettle(wagerId, eventWinner);
            lateSettledPayout(wagerId);
        } else {
            if (events.getCancelled(eventId) || events.getWinner(eventId) == 3) {
                abortWager(wagerId);
            } else {
                if (wagers.getTakerWinVote(wagerId) != 0 && wagers.getMakerWinVote(wagerId) != 0) {
                    settle(wagerId);

                }
            }
        }
    }

    /** @dev Aborts a standard wager where the creators disagree and there are not enough oracles or because the event has
     *  been cancelled, refunds all eth.
     *  @param wagerId bytes32 wagerId of the wager to abort.
     */
    function abortWager(bytes32 wagerId) internal {
        address maker = wagers.getMaker(wagerId);
        address taker = wagers.getTaker(wagerId);
        wagers.setSettled(wagerId);
        rewards.addUnlockedEth(maker, wagers.getOrigValue(wagerId));
        if (taker != address(0)) {
            rewards.addUnlockedEth(wagers.getTaker(wagerId), (wagers.getWinningValue(wagerId) - wagers.getOrigValue(wagerId)));
        }
    }

    /** @dev Settles the wager if both the maker and taker have voted, pays out if they agree, otherwise they need to wait for oracle settlement.
      * @param wagerId bytes32 id for the wager.
      */
    function settle(bytes32 wagerId) internal {
        address maker = wagers.getMaker(wagerId);
        address taker = wagers.getMaker(wagerId);
        uint origValue = wagers.getOrigValue(wagerId);
        if (wagers.getMakerWinVote(wagerId) == wagers.getTakerWinVote(wagerId)) {
            if (wagers.getMakerWinVote(wagerId) == wagers.getMakerChoice(wagerId)) {
                wagers.setWinner(wagerId, maker);
                rewards.addEth(maker, wagers.getWinningValue(wagerId) - origValue);
                rewards.subEth(taker, wagers.getWinningValue(wagerId) - origValue);
            } else {
                if (wagers.getMakerWinVote(wagerId) == 3) {
                    wagers.setWinner(wagerId, address(0));
                } else {
                    wagers.setWinner(wagerId, taker);
                    rewards.addEth(maker, origValue);
                    rewards.subEth(taker, origValue);
                }
            }
            payout(wagerId, maker, taker);
        }
    }

    /** @dev Pays out the wager if both the maker and taker have agreed, otherwise they need to wait for oracle settlement.
       * @param wagerId bytes32 id for the wager.
       */
    function payout(bytes32 wagerId, address maker, address taker) internal {
        if (!wagers.getSettled(wagerId)) {
            wagers.setSettled(wagerId);
            uint origVal =  wagers.getOrigValue(wagerId);
            uint winVal = wagers.getWinningValue(wagerId);
            if (wagers.getWinner(wagerId) == address(0)) { //Tie
                maker.transfer(origVal);
                taker.transfer(winVal-origVal);

            } else {
                uint payoutValue = wagers.getWinningValue(wagerId);
                uint fee = (payoutValue/100) * 2; // Sevice fee is 2 percent

                mevuBalance += (3*(fee/4));
                rewards.subEth(wagers.getWinner(wagerId), payoutValue);
                payoutValue -= fee;
                lotteryBalance += (fee/8);

                transferEthFromMevu(wagers.getWinner(wagerId), payoutValue);
                events.addResolvedWager(wagers.getEventId(wagerId), winVal);
            }
            rewards.addPlayerRep(maker, 1);
            rewards.addPlayerRep(taker, 1);
            wagers.setLocked(wagerId);
        }
    }

    function lateSettle (bytes32 wagerId, uint eventWinner) internal {
        address maker = wagers.getMaker(wagerId);
        address taker = wagers.getTaker(wagerId);
        if (wagers.getMakerChoice(wagerId) == eventWinner) {
            wagers.setWinner(wagerId, maker);
            wagers.setLoser(wagerId, taker);
        } else {
            wagers.setWinner(wagerId, taker);
            wagers.setLoser(wagerId, maker);
        }
    }

    /** @dev Pays out the wager after oracle settlement.
      * @param wagerId bytes32 id for the wager.
      */
    function lateSettledPayout(bytes32 wagerId) internal {

        if (!wagers.getSettled(wagerId)) {
            wagers.setSettled(wagerId);
            wagers.setLocked(wagerId);
            uint origValue = wagers.getOrigValue(wagerId);
            uint winningValue = wagers.getWinningValue(wagerId);
            uint payoutValue = winningValue;
            uint fee = (payoutValue/100) * oracleServiceFee;
            addMevuBalance(fee/2);
            addLotteryBalance(fee/12);
            payoutValue -= fee;
            uint oracleFee = (fee/12) + (fee/3);
            addLotteryBalance(oracleFee); // Too late to reward oracles directly for this wager, fee added to oracle lottery
            address maker = wagers.getMaker(wagerId);
            address taker = wagers.getTaker(wagerId);
            if (wagers.getWinner(wagerId) == maker) { // Maker won
                rewards.addUnlockedEth(maker, payoutValue);
                rewards.addEth(maker, (winningValue - origValue));
                rewards.addPlayerRep(maker, 1);
                rewards.subPlayerRep(taker, 2);
            } else { //Taker won
                rewards.addUnlockedEth(taker, payoutValue);
                rewards.addEth(taker, origValue);
                rewards.addPlayerRep(taker, 1);
                rewards.subPlayerRep(maker, 2);
            }
        }
    }



    // PLayers should call this when an event has been cancelled after thay have made a wager
    function playerRefund (bytes32 wagerId) external onlyBettor(wagerId) {
        require (events.getCancelled(wagers.getEventId(wagerId)));
        require (!wagers.getRefund(msg.sender, wagerId));
        wagers.setRefund(msg.sender, wagerId);
        address maker = wagers.getMaker(wagerId);
        wagers.setSettled(wagerId);
        if(msg.sender == maker) {
            rewards.addUnlockedEth(maker, wagers.getOrigValue(wagerId));
        } else {
            rewards.addUnlockedEth(wagers.getTaker(wagerId), (wagers.getWinningValue(wagerId) - wagers.getOrigValue(wagerId)));
        }
    }


    /** @dev Calls the oraclize contract for a random number generated through the Wolfram Alpha engine
      * @param max uint which corresponds to entries in oracleList array.
      */
    function randomNum(uint max) private {
        randomNumRequired = true;
        string memory qString = strConcat("random number between 0 and ", bytes32ToString(uintToBytes(max)));
        bytes32 queryId = oraclize_query("Wolfram Alpha", qString);
        validIds[queryId] = true;
    }

    function callRandomNum (uint max) internal {
        randomNum(max);
    }

    /** @dev Checks to see if a month (in seconds) has passed since the last lottery paid out, pays out if so
      */
    function checkLottery() internal {
        if (block.timestamp > getNewMonth()) {
            addMonth();
            randomNum(oracles.getOracleListLength()-1);
        }
    }

    /** @dev Pays out the monthly lottery balance to a random oracle and sends the mevuWallet its accrued balance.
      */
    function payoutLottery(address potentialWinner) private {
        // TODO: add functionality to test for oracle service being provided within one mointh of block.timestamp
        // TODO uncomment when MintableToken is implemented
        // if (mvuToken.balanceOf(potentialWinner) > 0) {
        //     uint thisWin = lotteryBalance;
        //     lotteryBalance = 0;
        //     potentialWinner.transfer(thisWin);
        // } else {
        //     require(oracles.getOracleListLength() > 0);
        //     callRandomNum(oracles.getOracleListLength()-1);

        // }
        assert(this.balance - mevuBalance > playerFunds);
        mevuWallet.transfer(mevuBalance);
        mevuBalance = 0;
    }

    function pauseContract()
    public
    onlyOwner {
        contractPaused = true;
    }

    function restartContract(uint secondsFromNow)
    external
    onlyOwner
    payable
    {
        contractPaused = false;
        bytes32 queryId = oraclize_query(secondsFromNow, "URL", "");
        validIds[queryId] = true;

    }

    function addMevuBalance (uint amount) public onlyAuth { mevuBalance += amount; }

    function addLotteryBalance (uint amount) public onlyAuth { lotteryBalance += amount; }

    function addToPlayerFunds (uint amount) onlyAuth {
        playerFunds += amount;
    }

    function subFromPlayerFunds (uint amount) onlyAuth {
        playerFunds -= amount;
    }

    function getContractPaused() constant returns (bool) {
        return contractPaused;
    }

    function getOracleFee () constant returns (uint256) {
        return oracleServiceFee;
    }

    function transferTokensToMevu (address oracle, uint mvuStake) internal {
        // TODO uncomment when MintableToken is implemented
        // mvuToken.transferFrom(oracle, this, mvuStake);
    }

    function transferTokensFromMevu (address oracle, uint mvuStake) internal {
        mvuToken.transfer(oracle, mvuStake);
    }

    function transferEthFromMevu (address recipient, uint amount) internal {
        recipient.transfer(amount);
    }

    function addMonth () internal {
        newMonth += monthSeconds;
    }

    function getNewMonth () constant returns (uint256) {
        return newMonth;
    }

    function makeOraclizeQuery (string engine, string query) internal {
        bytes32 queryId =  oraclize_query (engine, query, admin.getCallbackGasLimit());
        validIds[queryId] = true;

    }

    function uintToBytes(uint v) view returns (bytes32 ret) {
        if (v == 0) {
            ret = '0';
        }
        else {
            while (v > 0) {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }

    function bytes32ToString (bytes32 data) view returns (string) {
        bytes memory bytesString = new bytes(32);
        for (uint j=0; j<32; j++) {
            byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[j] = char;
            }
        }
        return string(bytesString);
    }

}


contract Events is Ownable {
    mapping (address => bool) private isAuthorized;
    uint public eventsCount;
    bytes32[] public activeEvents;

    Oracles oracles;
    Wagers wagers;
    Admin admin;

    address oraclesAddress;

    struct StandardWagerEvent {
        bytes32 name;
        bytes32 teamOne;
        bytes32 teamTwo;
        uint startTime; // Unix timestamp
        uint duration; // Seconds
        uint numWagers;
        uint totalAmountBet;
        uint totalAmountResolvedWithoutOracles;
        uint winner;
        uint loser;
        uint activeEventIndex;
        bytes32[] wagers;
        bool voteReady;
        bool locked;
        bool cancelled;
    }

    mapping (bytes32 => StandardWagerEvent) standardEvents;

    // Empty mappings to instantiate events
    mapping (address => uint256) oracleStakes;
    address[] emptyAddrArray;
    bytes32[] emptyBytes32Array;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    function grantAuthority (address nowAuthorized) onlyOwner {
        isAuthorized[nowAuthorized] = true;
    }

    function removeAuthority (address unauthorized) onlyOwner {
        isAuthorized[unauthorized] = false;
    }

    function setWagersContract (address thisAddr) external onlyOwner {
        wagers = Wagers(thisAddr);
    }

    function setOraclesContract (address thisAddr) external onlyAuth {
        oracles = Oracles(thisAddr);
    }

    function setAdminContract (address thisAddr) external onlyAuth {
        admin = Admin(thisAddr);
    }

    function Events () {
        bytes32 empty;
        activeEvents.push(empty);
    }


    function addResolvedWager (bytes32 eventId, uint value) onlyAuth {
        standardEvents[eventId].totalAmountResolvedWithoutOracles += value;
    }


    /** @dev Creates a new Standard event struct for users to bet on and adds it to the standardEvents mapping.
      * @param name The name of the event to be diplayed.
      * @param startTime The date and time the event begins in the YYYYMMDD9999 format.
      * @param duration The length of the event in seconds.
      * @param teamOne The name of one of the participants, eg. Toronto Maple Leafs, Georges St-Pierre, Justin Trudeau.
      * @param teamTwo The name of teamOne's opposition.
      */
    function makeStandardEvent(
        bytes32 id,
        bytes32 name,
        uint startTime,
        uint duration,
        bytes32 teamOne,
        bytes32 teamTwo
    )
    external
    onlyAuth
    {
        StandardWagerEvent memory thisEvent;
        thisEvent = StandardWagerEvent( name,
            teamOne,
            teamTwo,
            startTime,
            duration,
            0,
            0,
            0,
            0,
            0,
            activeEvents.length,
            emptyBytes32Array,
            false,
            false,
            false);
        standardEvents[id] = thisEvent;
        eventsCount++;
        activeEvents.push(id);
    }

    function updateStandardEvent(
        bytes32 eventId,
        uint newStartTime,
        uint newDuration,
        bytes32 newTeamOne,
        bytes32 newTeamTwo
    )
    external
    onlyAuth
    {
        standardEvents[eventId].startTime = newStartTime;
        standardEvents[eventId].duration = newDuration;
        standardEvents[eventId].teamOne = newTeamOne;
        standardEvents[eventId].teamTwo = newTeamTwo;

    }

    function cancelStandardEvent (bytes32 eventId) external onlyAuth {
        standardEvents[eventId].voteReady = true;
        standardEvents[eventId].locked = true;
        standardEvents[eventId].cancelled = true;
        uint indexToDelete = standardEvents[eventId].activeEventIndex;
        uint lastItem = activeEvents.length - 1;
        activeEvents[indexToDelete] = activeEvents[lastItem]; // Write over item to delete with last item
        standardEvents[activeEvents[lastItem]].activeEventIndex = indexToDelete; //Point what was the last item to its new spot in array
        activeEvents.length -- ; // Delete what is now duplicate entry in last spot
    }

    function determineEventStage (bytes32 thisEventId, uint lastIndex) onlyAuth {
        require (!getLocked(thisEventId));
        uint eventEndTime = getStart(thisEventId) + getDuration(thisEventId);
        if (block.timestamp > eventEndTime){
            // Event is over
            if (this.getVoteReady(thisEventId) == false){
                makeVoteReady(thisEventId);
            } else {
                // Go through next active event in array and finalize winners with voteReady events
                decideWinner(thisEventId);
                setLocked(thisEventId);
                removeEventFromActive(thisEventId);
            }
        }
    }

    function decideWinner (bytes32 eventId) internal {
        require (oracles.getOracleVotesNum(eventId) >= admin.getMinOracleNum(eventId));
        uint teamOneCount = oracles.getVotesForOne(eventId);
        uint teamTwoCount = oracles.getVotesForTwo(eventId);
        uint tieCount = oracles.getVotesForThree(eventId);
        if (teamOneCount > teamTwoCount && teamOneCount > tieCount){
            setWinner(eventId, 1);
        } else {
            if (teamTwoCount > teamOneCount && teamTwoCount > tieCount){
                setWinner(eventId, 2);
            } else {
                if (tieCount > teamTwoCount && tieCount > teamOneCount){
                    setWinner(eventId, 3);// Tie
                } else {
                    setWinner(eventId, 0); // No clear winner
                }
            }
        }
    }

    function removeEventFromActive (bytes32 eventId) onlyAuth {
        uint indexToDelete = standardEvents[eventId].activeEventIndex;
        uint lastItem = activeEvents.length - 1;
        activeEvents[indexToDelete] = activeEvents[lastItem]; // Write over item to delete with last item
        standardEvents[activeEvents[lastItem]].activeEventIndex = indexToDelete; //Point what was the last item to its new spot in array
        activeEvents.length -- ; // Delete what is now duplicate entry in last spot
    }

    function removeWager (bytes32 eventId, uint value) external onlyAuth {
        standardEvents[eventId].numWagers --;
        standardEvents[eventId].totalAmountBet -= value;
    }

    function addWager(bytes32 eventId, uint value) external onlyAuth {
        standardEvents[eventId].numWagers ++;
        standardEvents[eventId].totalAmountBet += value;
    }

    function setWinner (bytes32 eventId, uint winner) onlyAuth {
        standardEvents[eventId].winner = winner;
    }

    function setLocked (bytes32 eventId) onlyAuth {
        standardEvents[eventId].locked = true;
    }

    function getActiveEventId (uint i) external view returns (bytes32) {
        return activeEvents[i];
    }

    function getActiveEventsLength () external view returns (uint) {
        return activeEvents.length;
    }

    function getStandardEventCount () external view returns (uint) {
        return eventsCount;
    }

    function getTotalAmountBet (bytes32 eventId) view returns (uint) {
        return standardEvents[eventId].totalAmountBet;
    }

    function getTotalAmountResolvedWithoutOracles (bytes32 eventId) view returns (uint) {
        return standardEvents[eventId].totalAmountResolvedWithoutOracles;
    }

    function getCancelled(bytes32 id) external view returns (bool) {
        return standardEvents[id].cancelled;
    }

    function getStart (bytes32 id) view returns (uint) {
        return standardEvents[id].startTime;
    }

    function getDuration (bytes32 id) view returns (uint) {
        return standardEvents[id].duration;
    }

    function getLocked(bytes32 id) view returns (bool) {
        return standardEvents[id].locked;
    }

    function getWinner (bytes32 id) external view returns (uint) {
        return standardEvents[id].winner;
    }

    function getVoteReady (bytes32 id) external view returns (bool) {
        return standardEvents[id].voteReady;
    }

    function makeVoteReady (bytes32 id) internal {
        standardEvents[id].voteReady = true;
    }

}


contract Admin is Ownable {
    mapping (address => bool) private isAuthorized;
    uint minWagerAmount = 10;
    uint callbackInterval = 15;
    uint minOracleStake = 1;
    uint callbackGasLimit = 600000;
    int oracleRepPenalty = 25;
    mapping (bytes32 => uint) minOracleNum;

    modifier onlyAuth () {
        require(isAuthorized[msg.sender]);
        _;
    }

    function grantAuthority (address nowAuthorized) onlyOwner {
        isAuthorized[nowAuthorized] = true;
    }

    function removeAuthority (address unauthorized) onlyOwner {
        isAuthorized[unauthorized] = false;
    }

    function setMinOracleStake (uint newMin) external onlyOwner {
        minOracleStake = newMin;
    }

    function setMinOracleNum (bytes32 eventId, uint min) external onlyAuth {
        minOracleNum[eventId] = min;

    }

    function setOracleRepPenalty (int penalty) external onlyOwner {
        oracleRepPenalty = penalty;
    }

    function setCallbackGasLimit (uint newLimit) external onlyOwner {
        callbackGasLimit = newLimit;
    }

    /** @dev Sets a new number for the interval in between callback functions.
      * @param newInterval The new interval between oraclize callbacks.
      */
    function setCallbackInterval(uint newInterval) external onlyOwner {
        callbackInterval = newInterval;
    }

    /** @dev Updates the minimum amount of ETH required to make a wager.
      * @param minWager The new required minimum amount of ETH to make a wager.
      */
    function setMinWagerAmount(uint256 minWager) external onlyOwner {
        minWagerAmount = minWager;
    }

    function getCallbackInterval() external view returns (uint) {
        return callbackInterval;
    }

    function getMinWagerAmount() external view returns (uint) {
        return minWagerAmount;
    }

    function getMinOracleStake () external view returns (uint) {
        return minOracleStake;
    }

    function getOracleRepPenalty () external view returns (int) {
        return oracleRepPenalty;
    }

    function getCallbackGasLimit() external view returns (uint) {
        return callbackGasLimit;
    }

    function getMinOracleNum (bytes32 eventId) external view returns (uint) {
        return minOracleNum[eventId];
    }


}

