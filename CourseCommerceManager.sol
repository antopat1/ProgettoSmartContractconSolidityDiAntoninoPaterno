// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./SalesLibrary.sol";

contract CourseCommerceManager {
    using SalesLibrary for SalesLibrary.Enrollment[]; // Utilizza la libreria per l'array di iscrizioni

    address public owner;
    uint256 public totalEnrollments; // Conteggio totale delle iscrizioni
    uint256 public totalCourses; // Conteggio totale dei corsi

    struct Course {
        uint256 id;
        string title;
        uint256 feeInWei; // Costo del corso in wei
    }

    Course[] private courses; // Array di corsi offerti
    SalesLibrary.Enrollment[] private enrollments; // Array di iscrizioni registrate
    mapping(uint256 => mapping(address => bool)) private courseEnrollments; // Mapping che tiene traccia degli studenti iscritti a ciascun corso


    event CourseAdded(uint256 indexed courseId, string title, uint256 feeInWei); // Evento per quando un corso viene aggiunto
    event CourseEnrolled(
        uint256 indexed courseId,
        address indexed student,
        uint256 timestamp
    ); // Evento per quando uno studente si iscrive a un corso

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Solo il proprietario puo' eseguire questa funzione."
        );
        _;
    }

    // Funzione per aggiungere un nuovo corso
    function addCourse(
        string memory _title,
        uint256 _feeInWei
    ) public onlyOwner {
        require(
            bytes(_title).length > 0,
            "Il titolo del corso deve essere specificato."
        );
        require(
            _feeInWei > 0,
            "La quota d'iscrizione deve essere maggiore di 0."
        );

        courses.push(Course(totalCourses, _title, _feeInWei));
        totalCourses++;

        emit CourseAdded(totalCourses, _title, _feeInWei);
    }

    // Funzione per iscriversi a un corso
    function enrollInCourse(uint256 _courseId) public payable {
        require(_courseId < courses.length, "Il corso non esiste.");
        require(msg.sender != owner, "L'owner non puo' autoacquistare dei corsi"); // Impedisce all'owner di acquistare corsi da lui stesso pubblicati
        Course memory selectedCourse = courses[_courseId];
        require(msg.value == selectedCourse.feeInWei, "L'importo inviato non corrisponde alla quota d'iscrizione del corso.");

        // Controlla se lo studente è già iscritto al corso
        require(!courseEnrollments[_courseId][msg.sender], "Sei gia' iscritto a questo corso.");

        // Registra l'iscrizione
        enrollments.push(SalesLibrary.Enrollment(_courseId, msg.sender, block.timestamp));
        courseEnrollments[_courseId][msg.sender] = true; // Aggiorna il mapping delle iscrizioni
        totalEnrollments++;

        emit CourseEnrolled(_courseId, msg.sender, block.timestamp);
    }

    // Funzione per ottenere le informazioni su un corso specifico
    function getCourseDetails(
        uint256 _courseId
    ) public view returns (Course memory) {
        require(_courseId < courses.length, "Il corso non esiste.");
        return courses[_courseId];
    }

    // Funzione per ottenere le informazioni su una specifica iscrizione
    function getEnrollmentDetails(
        uint256 _enrollmentId
    ) public view returns (SalesLibrary.Enrollment memory) {
        require(_enrollmentId < enrollments.length, "L'iscrizione non esiste.");
        return enrollments[_enrollmentId];
    }

    // *** Utilizzo delle funzioni della libreria SalesLibrary ***

    // Restituisce i corsi a cui uno studente si è iscritto
    function getStudentCourses(
        address _student
    ) public view returns (uint256[] memory) {
        return enrollments.getCoursesByStudent(_student); // Usa la funzione della libreria
    }

    // Restituisce sia ID che nome dei corsi a cui uno studente si è iscritto
    function getStudentCoursesWithDetails(
        address _student
    ) public view returns (Course[] memory) {
        uint256[] memory studentCourseIds = enrollments.getCoursesByStudent(_student); // Ottieni gli ID dei corsi
        Course[] memory courseDetails = new Course[](studentCourseIds.length); // Array per ID e titoli

        for (uint256 i = 0; i < studentCourseIds.length; i++) {
            uint256 courseId = studentCourseIds[i];
            courseDetails[i] = courses[courseId]; // Aggiungi il corso direttamente
        }

        return courseDetails; // Ritorna l'array di corsi con ID, titoli e feeInWei
    }

    // Calcola totale dei fondi raccolti dalle iscrizioni ai corsi in un certo periodo di tempo
    function getTotalEnrollmentsInPeriod(
        uint256 _startTimestamp,
        uint256 _endTimestamp
    ) public view returns (uint256) {
        // Creiamo un array delle quote d'iscrizione per i corsi
        uint256[] memory courseFees = new uint256[](courses.length);
        for (uint256 i = 0; i < courses.length; i++) {
            courseFees[i] = courses[i].feeInWei;
        }
        return
            enrollments.calculateTotalEnrollments(
                _startTimestamp,
                _endTimestamp,
                courseFees
            ); // Usa la funzione della libreria
    }

    // Funzione per il proprietario per prelevare i fondi accumulati
    function withdrawFunds() public onlyOwner {
        require(address(this).balance > 0, "Non ci sono fondi da prelevare.");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Prelievo dei fondi fallito.");
    }
}
