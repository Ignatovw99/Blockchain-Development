// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract DigitalLibrary {
    enum Status {
        Active,
        Outdated,
        Archived
    }

    struct EBook {
        string title;
        string author;
        uint256 publicationDate;
        uint256 expirationDate;
        Status status;
        address primaryLibrarian;
        uint256 readCount;
    }

    mapping(uint256 => EBook) private books;
    mapping(uint256 => mapping(address => bool)) private authorizedLibrarians;
    mapping(uint256 => bool) private bookExistsMapping; // Storing the existance of books in separate mapping is gas efficient
    uint256 private nextBookId;

    event EBookCreated(
        uint256 ebookId,
        string title,
        address indexed primaryLibrarian
    );
    event LibrarianAdded(uint256 ebookId, address indexed librarian);
    event LibrarianRemoved(uint256 ebookId, address indexed librarian);
    event ExpirationExtended(uint256 ebookId, uint256 newExpirationDate);
    event StatusChanged(uint256 ebookId, Status newStatus);
    event ExpirationChecked(uint256 ebookId, bool isOutdated);

    modifier requireBookExistence(uint256 bookId) {
        require(bookExistsMapping[bookId], "Book does not exist");
        _;
    }

    modifier onlyPrimaryLibrarian(uint256 bookId) {
        require(
            msg.sender == books[bookId].primaryLibrarian,
            "Not the primary librarian of the book"
        );
        _;
    }

    modifier onlyAuthorizedLibrarian(uint256 bookId) {
        require(
            authorizedLibrarians[bookId][msg.sender],
            "Not an authorized librarian"
        );
        _;
    }

    function createEBook(
        string calldata title,
        string calldata author,
        uint256 publicationDate,
        uint256 expirationDays
    ) external {
        EBook memory eBook = EBook({
            title: title,
            author: author,
            publicationDate: publicationDate,
            expirationDate: block.timestamp + (expirationDays * 1 days),
            status: Status.Active,
            primaryLibrarian: msg.sender,
            readCount: 0
        });

        uint256 bookId = nextBookId++;

        books[bookId] = eBook;
        authorizedLibrarians[bookId][msg.sender] = true;
        bookExistsMapping[bookId] = true;

        emit EBookCreated(bookId, title, eBook.primaryLibrarian);
    }

    function addLibrarian(uint256 bookId, address librarian)
        external
        requireBookExistence(bookId)
        onlyPrimaryLibrarian(bookId)
    {
        require(librarian != address(0), "Invalid librarian address");
        authorizedLibrarians[bookId][librarian] = true;
        emit LibrarianAdded(bookId, librarian);
    }

    function extendExpirationDate(uint256 bookId, uint256 additionalDays)
        external
        requireBookExistence(bookId)
        onlyAuthorizedLibrarian(bookId)
    {
        require(
            additionalDays > 0,
            "Additional days must be greater than zero"
        );

        EBook storage ebook = books[bookId];
        ebook.expirationDate += additionalDays * 1 days;

        emit ExpirationExtended(bookId, ebook.expirationDate);
    }

    function changeStatus(uint256 bookId, Status status)
        external
        requireBookExistence(bookId)
        onlyPrimaryLibrarian(bookId)
    {
        EBook storage ebook = books[bookId];
        ebook.status = status;
        emit StatusChanged(bookId, status);
    }

    function checkExpirationDate(uint256 bookId)
        external
        requireBookExistence(bookId)
        returns (bool)
    {
        EBook storage ebook = books[bookId];
        ebook.readCount++;

        bool isOutdated = block.timestamp > ebook.expirationDate;
        if (isOutdated && ebook.status == Status.Active) {
            ebook.status = Status.Outdated;
        }

        emit ExpirationChecked(bookId, isOutdated);
        return isOutdated;
    }

    function getEBook(uint256 bookId)
        public
        view
        requireBookExistence(bookId)
        returns (
            string memory title,
            string memory author,
            uint256 publicationDate,
            uint256 expirationDate,
            Status status,
            address primaryLibrarian,
            uint256 readCount
        )
    {
        EBook memory ebook = books[bookId];
        return (
            ebook.title,
            ebook.author,
            ebook.publicationDate,
            ebook.expirationDate,
            ebook.status,
            ebook.primaryLibrarian,
            ebook.readCount
        );
    }

    function isAuthorizedLibrarian(uint256 bookId, address librarian)
        public
        view
        returns (bool)
    {
        return authorizedLibrarians[bookId][librarian];
    }
}
