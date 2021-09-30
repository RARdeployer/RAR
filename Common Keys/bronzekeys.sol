/**
 *Submitted for verification at FtmScan.com on 2021-09-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface rarity {
    function level(uint) external view returns (uint);
    function getApproved(uint) external view returns (address);
    function ownerOf(uint) external view returns (address);
    function class(uint) external view returns (uint);
    function summon(uint _class) external;
    function next_summoner() external view returns (uint);
    function spend_xp(uint _summoner, uint _xp) external;
}

interface rarity_attributes {
    function character_created(uint) external view returns (bool);
    function ability_scores(uint) external view returns (uint32,uint32,uint32,uint32,uint32,uint32);
}

interface rarity_crafting_materials_i {
    function transferFrom(uint executor, uint from, uint to, uint amount) external returns (bool);
}

interface rarityTrans {
    function transfer(uint from, uint to, uint amount) external returns (bool);
}

interface codex_base_random {
    function d20(uint _summoner) external view returns (uint);
}


contract bronze_key_keysmith {
    

    
    
    struct Crafter {
        uint attempts;
    }
    mapping(uint => Crafter) public crafters;
    
    uint public immutable SUMMMONER_ID;
    
    
    string public constant name = "Bronze Keys Keysmith";
    string public constant symbol = "BKK";
    uint8 public constant decimals = 0;
    uint public totalSupply = 0;
    

    
    rarity_crafting_materials_i constant _craft_i = rarity_crafting_materials_i(0x2A0F1cB17680161cF255348dDFDeE94ea8Ca196A);
    rarity constant rm = rarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    rarity_attributes constant _attr = rarity_attributes(0xB5F5AF1087A8DA62A23b08C00C6ec9af21F397a1);
    rarityTrans constant _rarityTrans = rarityTrans(0x00000000000147629f002966C4f2ADc1cB4f0Aca);
    codex_base_random constant _random = codex_base_random(0x7426dBE5207C2b5DaC57d8e55F0959fcD99661D4);

    mapping(uint => mapping (uint => uint)) public allowance;
    mapping(uint => uint) public balanceOf;
    
  

    event Transfer(uint indexed from, uint indexed to, uint amount);
    event Approval(uint indexed from, uint indexed to, uint amount);
     event Crafted(address indexed owner, uint summoner, uint rar, uint craft_i);


    constructor() {
        SUMMMONER_ID = rm.next_summoner();
        rm.summon(11);
       
    }



    function _isApprovedOrOwner(uint _summoner) internal view returns (bool) {
        return rm.getApproved(_summoner) == msg.sender || rm.ownerOf(_summoner) == msg.sender;
    }
    
    

    
    
    
    function _search_key(uint _summoner) public view returns (bool crafted) {
        int check = 100000*int(crafters[_summoner].attempts)+(int(crafters[_summoner].attempts)+9000+int(_random.d20(_summoner)*80))*int(totalSupply); 
        check /= (10000*int(totalSupply)+1);
        return (check >= 1);
    }
    
    
   
    
    function craft(uint summoner, uint crafting_materials) external {
        require(_isApprovedOrOwner(summoner));
        require(_attr.character_created(summoner), "!created");
        require(summoner != SUMMMONER_ID, "hax0r");
        require(crafting_materials >= 1);
        require(_craft_i.transferFrom(SUMMMONER_ID, summoner, SUMMMONER_ID, 1), "!craft");
        
        (bool crafted) = _search_key(summoner);
        crafters[summoner].attempts++;
        if(crafted){
            uint _cost = 1e17;
            require(_rarityTrans.transfer(summoner, SUMMMONER_ID, _cost), "!rar");
            crafters[summoner].attempts = 0;
            _mint(summoner, 1);
            emit Crafted(msg.sender, summoner, _cost, 1);
        }
        }

    function _mint(uint dst, uint amount) internal {
        totalSupply += amount;
        balanceOf[dst] += amount;
        emit Transfer(dst, dst, amount);
    }

    function approve(uint from, uint spender, uint amount) external returns (bool) {
        require(_isApprovedOrOwner(from));
        allowance[from][spender] = amount;

        emit Approval(from, spender, amount);
        return true;
    }

    function transfer(uint from, uint to, uint amount) external returns (bool) {
        require(_isApprovedOrOwner(from));
        _transferTokens(from, to, amount);
        return true;
    }

    function transferFrom(uint executor, uint from, uint to, uint amount) external returns (bool) {
        require(_isApprovedOrOwner(executor));
        uint spender = executor;
        uint spenderAllowance = allowance[from][spender];

        if (spender != from && spenderAllowance != type(uint).max) {
            uint newAllowance = spenderAllowance - amount;
            allowance[from][spender] = newAllowance;

            emit Approval(from, spender, newAllowance);
        }

        _transferTokens(from, to, amount);
        return true;
    }

    function _transferTokens(uint from, uint to, uint amount) internal {
        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
    }
}