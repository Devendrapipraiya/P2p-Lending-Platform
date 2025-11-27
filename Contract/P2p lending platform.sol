// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Project {
    struct Loan {
        uint256 id;
        address borrower;
        address lender;
        uint256 amount;
        uint256 interest;
        bool isFunded;
        bool isRepaid;
    }

    uint256 public loanCount;
    mapping(uint256 => Loan) public loans;

    event LoanRequested(uint256 indexed id, address indexed borrower, uint256 amount, uint256 interest);
    event LoanFunded(uint256 indexed id, address indexed lender);
    event LoanRepaid(uint256 indexed id, address indexed borrower);

    /// @notice Borrower creates a loan request
    function requestLoan(uint256 _amount, uint256 _interest) external {
        loanCount++;

        loans[loanCount] = Loan({
            id: loanCount,
            borrower: msg.sender,
            lender: address(0),
            amount: _amount,
            interest: _interest,
            isFunded: false,
            isRepaid: false
        });

        emit LoanRequested(loanCount, msg.sender, _amount, _interest);
    }

    /// @notice Lender funds a loan request
    function fundLoan(uint256 _loanId) external payable {
        Loan storage loan = loans[_loanId];
        require(!loan.isFunded, "Loan already funded");
        require(msg.value == loan.amount, "Incorrect funding amount");

        loan.lender = msg.sender;
        loan.isFunded = true;

        payable(loan.borrower).transfer(msg.value);

        emit LoanFunded(_loanId, msg.sender);
    }

    /// @notice Borrower repays loan amount + interest
    function repayLoan(uint256 _loanId) external payable {
        Loan storage loan = loans[_loanId];
        require(loan.isFunded, "Loan not funded");
        require(!loan.isRepaid, "Loan already repaid");
        require(msg.sender == loan.borrower, "Only borrower can repay");

        uint256 totalDue = loan.amount + loan.interest;
        require(msg.value == totalDue, "Incorrect repayment amount");

        loan.isRepaid = true;
        payable(loan.lender).transfer(msg.value);

        emit LoanRepaid(_loanId, msg.sender);
    }
}
