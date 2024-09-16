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
        uint256[] memory enrolledCourses = new uint256[](enrollments.length);
        uint256 count = 0;
        for (uint256 i = 0; i < enrollments.length; i++) {
            if (enrollments[i].student == student) {
                enrolledCourses[count] = enrollments[i].courseId;
                count++;
            }
        }

        // Ridimensionare l'array per restituire solo i corsi effettivamente iscritti
        uint256[] memory result = new uint256[](count);
        for (uint256 j = 0; j < count; j++) {
            result[j] = enrolledCourses[j];
        }

        return result;
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
