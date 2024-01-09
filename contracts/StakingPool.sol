// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Whitelist.sol";

contract StakingPool is Ownable, Whitelist, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public allowReinvest;
    IERC20 public stakingToken;
    IERC20 public rewardToken;
    uint256 public startTime;
    uint256 public lastRewardTime;
    uint256 public finishTime;
    uint256 public allStakedAmount;
    uint256 public allPaidReward;
    uint256 public allRewardDebt;
    uint256 public poolTokenAmount;
    uint256 public rewardPerSec;
    uint256 public accTokensPerShare; // Accumulated tokens per share
    uint256 public participants; //Count of participants

    // Info of each user.
    struct UserInfo {
        uint256 amount;    
        uint256 rewardDebt; 
        bool registrated;
        uint256 lockTime;
    }

    mapping (address => UserInfo) public userInfo;

    event PoolReplenished(uint256 amount);
    event TokensStaked(address indexed user, uint256 amount, uint256 reward, bool reinvest);
    event StakeWithdrawn(address indexed user, uint256 amount, uint256 reward);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardWithdraw(address indexed user , uint256 amount);

    event WithdrawPoolRemainder(address indexed user, uint256 amount);
    event UpdateFinishTime(uint256 addedTokenAmount, uint256 newFinishTime);
    event HasWhitelistingUpdated(bool newValue);
    event AddRewardBalance(uint256 _addTokenAmount);
    event SubRewardBalance(address indexed user , uint256 _subTokenAmount);

    constructor(
        IERC20 _stakingToken,
        IERC20 _poolToken,
        uint256 _startTime,
        uint256 _finishTime,
        uint256 _poolTokenAmount,
        bool _hasWhitelisting
    ) public Whitelist(_hasWhitelisting) {
        stakingToken = _stakingToken;
        rewardToken = _poolToken;
        require(_startTime < _finishTime, "Start must be less than finish");
        require(_startTime > now, "Start must be more than now");

        startTime = _startTime;
        lastRewardTime = startTime;
        finishTime = _finishTime;
        poolTokenAmount = _poolTokenAmount;
        rewardPerSec =( _poolTokenAmount.div(_finishTime.sub(_startTime))) / 10;

        allowReinvest = address(stakingToken) == address(rewardToken);
    }

    function getUserInfo(address user)
        external
        view
        returns (uint256, uint256,uint256)
    {
        UserInfo memory info = userInfo[user];
        return (info.amount, info.rewardDebt, info.lockTime);
    }
    
    function getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_from >= _to) {
          return 0;
        }
        if (_to <= finishTime) {
            return _to.sub(_from);
        } else if (_from >= finishTime) {
            return 0;
        } else {
            return finishTime.sub(_from);
        }
    }
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 tempAccTokensPerShare = accTokensPerShare;
        if (now > lastRewardTime && allStakedAmount != 0) {
            uint256 multiplier = getMultiplier(lastRewardTime, now);
            uint256 reward = multiplier.mul(rewardPerSec);
            tempAccTokensPerShare = accTokensPerShare.add(
                reward.mul(1e18).div(allStakedAmount)
            );
        }
        return user.amount.mul(tempAccTokensPerShare).div(1e18).sub(user.rewardDebt);
    }
    function updatePool() public {
        if (now <= lastRewardTime) {
            return;
        }
        if (allStakedAmount == 0) {
            lastRewardTime = now;
            return;
        }

        uint256 multiplier = getMultiplier(lastRewardTime, now);
        uint256 reward = multiplier.mul(rewardPerSec);
        accTokensPerShare = accTokensPerShare.add(
            reward.mul(1e18).div(allStakedAmount)
        );
        lastRewardTime = now;
    }
    function withdrawReward(uint256 _amount) external nonReentrant {
        updatePool();
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount > 0, "Nothing to withdraw");
        uint256 pending = transferPendingReward(user,false);
        require(pending >= _amount, "Not enough tokens");
        allPaidReward = allPaidReward.sub(_amount);
        rewardToken.safeTransfer(msg.sender, _amount);
        emit RewardWithdraw(msg.sender, _amount);

    }

    function reinvestTokens() external nonReentrant onlyWhitelisted{
        innerStakeTokens(0, true);
    }

    function stakeTokens(uint256 _amountToStake, uint256 lockTime) external nonReentrant onlyWhitelisted{
        userInfo[msg.sender].lockTime = lockTime;
        innerStakeTokens(_amountToStake, false);
    }

    function innerStakeTokens(uint256 _amountToStake, bool reinvest) private{
        updatePool();
        uint256 pending = 0;
        UserInfo storage user = userInfo[msg.sender];

        if(!user.registrated){
            user.registrated = true;
            participants +=1;
        }
        if (user.amount > 0) {
            pending = transferPendingReward(user, reinvest);
            if(reinvest)
            {
                require(allowReinvest, "Reinvest disabled");
                user.amount = user.amount.add(pending);
                allStakedAmount = allStakedAmount.add(pending);
            }
        }
        if (_amountToStake > 0) {
            uint256 balanceBefore = stakingToken.balanceOf(address(this));
            stakingToken.safeTransferFrom(msg.sender, address(this), _amountToStake);
            uint256 received = stakingToken.balanceOf(address(this)) - balanceBefore;
            _amountToStake = received;
            user.amount = user.amount.add(_amountToStake);
            allStakedAmount = allStakedAmount.add(_amountToStake);
            whitelistedAddresses.push(msg.sender);
        }
        
        allRewardDebt = allRewardDebt.sub(user.rewardDebt);
        user.rewardDebt = user.amount.mul(accTokensPerShare).div(1e18);
        allRewardDebt = allRewardDebt.add(user.rewardDebt);
        emit TokensStaked(msg.sender, _amountToStake, pending, reinvest);
    }
    function withdrawStake(uint256 _amount) external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        require(user.lockTime < now, "Tokens are locked");
        updatePool();
        uint256 pending = transferPendingReward(user, false);

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            stakingToken.safeTransfer(msg.sender, _amount);
        }
        allRewardDebt = allRewardDebt.sub(user.rewardDebt);
        user.rewardDebt = user.amount.mul(accTokensPerShare).div(1e18);
        allRewardDebt = allRewardDebt.add(user.rewardDebt);
        allStakedAmount = allStakedAmount.sub(_amount);

        emit StakeWithdrawn(msg.sender, _amount, pending);
    }


    function transferPendingReward(UserInfo memory user, bool reinvest) public returns (uint256) {
        uint256 pending = user.amount.mul(accTokensPerShare).div(1e18).sub(user.rewardDebt);

        if (pending > 0) {
            if(!reinvest){
                rewardToken.safeTransfer(msg.sender, pending);
            }
            allPaidReward = allPaidReward.add(pending);
        }

        return pending;
    }

    function emergencyWithdraw() external nonReentrant{
        UserInfo storage user = userInfo[msg.sender];
        if(user.amount > 0) {
            stakingToken.safeTransfer(msg.sender, user.amount);
            emit EmergencyWithdraw(msg.sender, user.amount);

            allStakedAmount = allStakedAmount.sub(user.amount);
            allRewardDebt = allRewardDebt.sub(user.rewardDebt);
            user.amount = 0;
            user.rewardDebt = 0;
        }
    }
    function withdrawPoolRemainder() external onlyOwner nonReentrant{
        require(now > finishTime, "Allow after finish");
        updatePool();
        uint256 pending = allStakedAmount.mul(accTokensPerShare).div(1e18).sub(allRewardDebt);
        uint256 returnAmount = poolTokenAmount.sub(allPaidReward).sub(pending);
        allPaidReward = allPaidReward.add(returnAmount);

        rewardToken.safeTransfer(msg.sender, returnAmount);
        emit WithdrawPoolRemainder(msg.sender, returnAmount);
    }

    function extendDuration(uint256 _addTokenAmount) external onlyOwner nonReentrant{
        require(now < finishTime, "Pool was finished");
        rewardToken.safeTransferFrom(msg.sender, address(this), _addTokenAmount);     
        poolTokenAmount = poolTokenAmount.add(_addTokenAmount);
        finishTime = finishTime.add(_addTokenAmount.div(rewardPerSec));

        emit UpdateFinishTime(_addTokenAmount, finishTime);
    }
    function addRewardBalance(uint256 _addTokenAmount) external onlyOwner nonReentrant{
        require(now < finishTime, "Pool was finished");
        rewardToken.safeTransferFrom(msg.sender, address(this), _addTokenAmount);     
        poolTokenAmount = poolTokenAmount.add(_addTokenAmount);
        updatePool();

        emit AddRewardBalance(_addTokenAmount);
    }
    function subTokenBalance(uint256 _subTokenAmount) external onlyOwner nonReentrant {
        require(now < finishTime, "Pool was finished");
        poolTokenAmount = poolTokenAmount.sub(_subTokenAmount);
        rewardToken.safeTransfer(msg.sender, _subTokenAmount);
        updatePool();
        emit SubRewardBalance(msg.sender, _subTokenAmount);
    }
    function setHasWhitelisting(bool value) external onlyOwner{
        hasWhitelisting = value;
        emit HasWhitelistingUpdated(hasWhitelisting);
    }
}