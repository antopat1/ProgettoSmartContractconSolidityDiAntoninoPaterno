// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library SalesLibrary {
    struct Enrollment {
        uint256 courseId;
        address student;
        uint256 timestamp;
    }

    // Funzione per ottenere i corsi a cui uno studente si è iscritto
    function getCoursesByStudent(
        Enrollment[] memory enrollments,
        address student
    ) public pure returns (uint256[] memory) {
        // Conta prima quante iscrizioni ci sono per quello studente
        uint256 count = 0;
        for (uint256 i = 0; i < enrollments.length; i++) {
            if (enrollments[i].student == student) {
                count++;
            }
        }

        // Inizializza un array della lunghezza esatta
        uint256[] memory enrolledCourses = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < enrollments.length; i++) {
            if (enrollments[i].student == student) {
                enrolledCourses[index] = enrollments[i].courseId;
                index++;
            }
        }

        return enrolledCourses;
    }

    // Funzione per calcolare il totale dei fondi raccolti dalle iscrizioni ai corsi in un certo periodo di tempo
    function calculateTotalEnrollments(
        Enrollment[] memory enrollments,
        uint256 startTime,
        uint256 endTime,
        uint256[] memory courseFees
    ) public pure returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < enrollments.length; i++) {
            if (
                enrollments[i].timestamp >= startTime &&
                enrollments[i].timestamp <= endTime
            ) {
                total += courseFees[enrollments[i].courseId];
            }
        }
        return total;
    }
}
