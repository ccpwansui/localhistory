pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;

contract Book {
    address public owner;
    modifier restricted() {
        if (msg.sender == owner) _;
    }

    constructor() public {
        owner = msg.sender;
    }

    struct OptBook {
        uint[] publishedBooks; //已经发表的
        uint[] borrowedBooks; //已经点赞的
        uint[] commentedBooks; //已评论的
    }

    struct Book {
        address owner; //发布者 0
        string nameWriter; //资料名 1
        string style; //所属地区 2
        string publisherPublishAge; //所属年代 3
        string intro; //简介 4
        string cover; //预览 5
        string status; //状态(0：在线；1：离线) 6
        string source; //资料来源 7
        uint publishDate; //上架时间 8
        uint score; //评分 9
        uint comment; //评论个数 10
        mapping(uint => Comment) comments; //评价列表 11
        uint borrowNums; //12
        string pdf; //13
    }

    struct Comment {
        address reader; // 借阅者
        uint date; // 评价日期
        uint score; // 评分
        string content; // 评论正文
    }

    Book[] books;
    uint tempNum = 1;
    mapping(address => OptBook) BooksPool;
    //发布图书成功
    event publishBookSuccess(
        uint id,
        string nameWriter,
        string style,
        string publisherPublishAge,
        string intro,
        string cover,
        string source,
        string status,
        uint publishDate,
        string pdf
    );
    //评价成功
    event evaluateSuccess(uint id, address addr, uint score);
    //点赞成功
    event borrowSuccess(uint id, address addr);
    //还书成功
    event returnBookSuccess(uint id, address addr);

    //获取已经被借阅的书单
    function getBorrowedBooks() public view returns (uint[] memory) {
        return BooksPool[msg.sender].borrowedBooks;
    }

    //获取已经被评论过
    function getCommentedBook() public view returns (uint[] memory) {
        return BooksPool[msg.sender].commentedBooks;
    }

    //获取发布
    function getPublishedBooks() public view returns (uint[] memory) {
        return BooksPool[msg.sender].publishedBooks;
    }

    //获取书籍数量
    function getBooksLength() public view returns (uint) {
        return books.length;
    }

    //获取评价数量
    function getCommentLength(uint id) public view returns (uint) {
        return books[id].comment;
    }

    //获取借阅数据
    function getBorrowNums(uint id) public view returns (uint) {
        return books[id].borrowNums;
    }

    //获取信息
    function getBookInfo(
        uint id
    )
        public
        view
        returns (
            address,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            uint,
            uint,
            uint,
            string memory
        )
    {
        require(id < books.length);
        //获取图书,载入合约
        Book storage book = books[id];
        return (
            book.owner, //0
            book.nameWriter, //1
            book.style, //2
            book.publisherPublishAge, //3
            book.intro, //4
            book.cover, //5
            book.status, //6
            book.source, //7
            book.publishDate, //8
            book.score, //9
            book.comment, //10
            book.pdf //11
        );
    }

    //获得评价消息
    function getCommentInfo(
        uint bookId,
        uint commentId
    ) public view returns (address, uint, uint, string memory) {
        require(bookId < books.length);
        require(commentId < books[bookId].comment);
        Comment storage c = books[bookId].comments[commentId];
        return (c.reader, c.date, c.score, c.content);
    }

    // 是否已经评价 通过遍历实现
    function isEvaluated(uint id) public view returns (bool) {
        Book storage book = books[id];
        for (uint i = 0; i < book.comment; i++)
            if (book.comments[i].reader == msg.sender) return true; // 已经评价
        return false; // 尚未评价
    }

    // 是否已经借阅 通过遍历实现
    function isBorrowed(uint id) public view returns (bool) {
        OptBook storage optBook = BooksPool[msg.sender];
        for (uint i = 0; i < optBook.borrowedBooks.length; i++)
            if (optBook.borrowedBooks[i] == id) return true; // 已经借阅
        return false; // 尚未借阅
    }

    function isMyBook(uint id) public view returns (bool) {
        Book storage book = books[id];
        if (book.owner == msg.sender) return true;
        return false;
    }

    //查看已经离线
    function isBookLeft(uint id) public payable returns (bool) {
        require(id < books.length);
        Book storage book = books[id];
        if (hashCompareInternal(book.status, "离线")) return true; //离馆
        return false; //没有离馆
    }

    //发布
    function publishBookInfo(
        string memory nameWriter,
        string memory style,
        string memory publisherPublishAge,
        string memory intro,
        string memory cover,
        string memory status,
        string memory source,
        string memory pdf
    ) public restricted {
        uint id = books.length;
        Book memory book = Book(
            msg.sender,
            nameWriter,
            style,
            publisherPublishAge,
            intro,
            cover,
            status,
            source,
            now,
            0,
            0,
            0,
            pdf
        );
        books.push(book);
        BooksPool[msg.sender].publishedBooks.push(id);
        emit publishBookSuccess(
            id,
            book.nameWriter,
            book.style,
            book.publisherPublishAge,
            book.intro,
            book.cover,
            book.source,
            book.status,
            book.publishDate,
            book.pdf
        );
    }

    //评价
    function evaluate(uint id, uint score, string memory content) public {
        require(id < books.length);
        // 读取合约
        Book storage book = books[id];
        require(book.owner != msg.sender && !isEvaluated(id)); // 限制条件
        require(0 <= score && score <= 10); // 合法条件
        // 记录评价
        book.score += score;
        book.comments[book.comment++] = Comment(
            msg.sender,
            now,
            score,
            content
        );
        BooksPool[msg.sender].commentedBooks.push(id);
        emit evaluateSuccess(id, msg.sender, book.score);
    }

    //阅览
    function borrowedBook(uint id) public {
        require(id < books.length);
        Book storage book = books[id];
        require(book.owner != msg.sender && !isBorrowed(id)); // 限制条件
        book.borrowNums++;
        BooksPool[msg.sender].borrowedBooks.push(id);
        book.status = "离线";
        emit borrowSuccess(id, msg.sender);
    }

    //字符串比较
    function hashCompareInternal(
        string memory a,
        string memory b
    ) internal returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function() external {
        revert();
    }
}
