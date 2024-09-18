# IncluDO Course E-Commerce Smart Contract

This project implements the `CourseCommerceManager` smart contract for IncluDO, a startup that focuses on creating inclusive online courses, particularly for migrants and disadvantaged individuals, to help them integrate into the workforce.

The goal of this project is to build a decentralized e-commerce platform for IncluDO's courses, allowing users to purchase courses and enabling the management of course sales through a smart contract deployed on the Ethereum blockchain.

## Smart Contracts

### 1. CourseCommerceManager.sol
This smart contract handles the creation, management, and sales tracking of the courses.

- **Owner's Address:** The address of the contract owner (the deployer).
- **Course Structure:** Defines the details of a course, including its title, ID, and price in Ether (in wei).
- **Courses Array:** Stores all available courses.
- **Total Sales Count:** Tracks the total number of sales made through the contract.
- **Sale Structure:** Stores details about a sale, such as the purchased course, the timestamp of the purchase, and the buyer's address.
- **Sales Array:** Tracks all sales registered in the system.
- **Events:**
  - `CourseAdded`: Emitted when a new course is added.
  - `CourseEnrolled`: Emitted when a user enrolls in a course (makes a purchase).
- **Withdraw Funds:** Allows the contract owner to withdraw the balance of the contract.
- **Key Functions:**
  - `addCourse`: The owner can add a new course for sale.
  - `getCourseDetails`: Allows anyone to view details of a specific course using its ID.
  - `enrollInCourse`: A function that allows a user to purchase a course.
  - `getEnrollmentDetails`: Allows anyone to view specific details of a particular sale.

### 2. SalesLibrary.sol
This library is used to manage enrollment records and includes helper functions for the `CourseCommerceManager`.

- **Sales Record:** Keeps track of course enrollments, associating them with a student and a course.
- **Functions:**
  - `getCoursesByStudent`: Retrieves the list of course IDs a particular student has enrolled in.
  - `calculateTotalEnrollments`: Calculates the total sales amount in Ether for a specified period.

## Deployment Details

The following are the details of the deployed smart contracts on the Sepolia Testnet:

- **CourseCommerceManager**: `0x3D7111F7282C8750cf6866a7482d1A306f4B80CC`
- **SalesLibrary**: `0xd52865c6349479a89d0ba1cf7af07f01c94b0cec`

These contracts were deployed using the externally owned account (EOA):  
`0x6Db728e8A98b89C421CBb0cF23A3e9975a943B27`

## Technical Choices and Considerations

1. **Solidity Version**: The contract uses Solidity version `^0.8.19`, taking advantage of features like built-in overflow checking.
2. **Ownership Pattern**: The `onlyOwner` modifier ensures that only the contract deployer (owner) can add new courses or withdraw funds, following the common ownership pattern in Solidity.
3. **Private Data Structures**: The `courses`, `enrollments`, and `courseEnrollments` mappings are marked as `private` to prevent unauthorized reading of sensitive data. Instead, view functions are provided to access the necessary information.
4. **Event Logging**: Events such as `CourseAdded` and `CourseEnrolled` help external observers, such as front-end interfaces or other contracts, to track changes in the system in a gas-efficient manner.
5. **Mapping and Struct Design**: We used mappings and arrays to efficiently store and retrieve data. The enrollment records are managed using mappings of course IDs to addresses to ensure that students cannot enroll in the same course twice.
6. **Gas Optimization**: Structs and mappings are used in a way that minimizes the gas costs of transactions, especially when accessing or modifying enrollment data.
7. **Sales Tracking**: The SalesLibrary is used for tracking student enrollments and calculating total earnings during specific time periods. This modular design increases the contract's readability and reusability.

## Testing

The contract was deployed and tested on the Sepolia Testnet. All functions, including course creation, enrollment, and fund withdrawal, were tested successfully. The contract is ready to be integrated into the IncluDO platform for further testing in a production environment.


## How to Use

1. Clone the repository and compile the contract using your preferred Solidity development environment for example Remix.
2. Deploy the contract on your desired network. You can use Sepolia for testing as shown in this project.
3. Interact with the contract functions using a frontend or directly through tools like Remix, Etherscan, or web3 library.

## Contact

For any questions or collaboration inquiries, feel free to contact:

- **Developer**: Antonino Paterno'
- **Email**: antopat1@gmail.com

