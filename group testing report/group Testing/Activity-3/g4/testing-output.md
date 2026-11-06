# Activity 3 Testing Log - Group 4

## 1. Project Details
- **Project Tested:** Group 4 - BrewPOS: Café Point-of-Sale System
- **Testing Group:** Group 10
- **Repository Link:** https://github.com/grp04-dba/BrewPOS
- **Branch Tested:** main

---

## 2. System Requirements & Prerequisites
- **Language/Environment:** Java 17, Spring Boot 4.1.1
- **Database:** PostgreSQL (`grp_brewposdb`)
- **Build Tool:** Maven Wrapper (`mvnw.cmd`)

---

## 3. Issues Found
1. **Maven Wrapper / JAVA_HOME Environment Blocker:**
   - Executing the startup command `.\mvnw.cmd spring-boot:run` triggers an error stating `The JAVA_HOME environment variable is not defined correctly`[cite: 3].
   - Even after applying the troubleshooting commands and manual environment path overrides outlined in the repository's documentation, the local Java runtime failed to launch the application server[cite: 3].

---

## 4. Setup & Execution Results

| Step / Test Case | Result | Remarks / Notes |
| :--- | :--- | :--- |
| **Repository Clone** | Success | Successfully cloned from GitHub[cite: 3]. |
| **Database Creation** | Success | Created `grp_brewposdb` in PostgreSQL via pgAdmin / psql[cite: 3]. |
| **SQL Script Execution** | Success | Schema, seed data, and role scripts executed without errors[cite: 3]. |
| **Maven & JDK Verification** | Failed | Executing `.\mvnw.cmd spring-boot:run` failed due to unresolved `JAVA_HOME` environment variable issues[cite: 3]. |
| **Application Run** | Blocked | Database setup is complete, but unable to launch the POS web interface due to build execution failure[cite: 3]. |

---

## 5. Overall Result & Feedback
- **Result:** Some Issues
- **Feedback for Original Developers:**
  1. Provide a more robust fallback or clearer diagnostic steps in the `README.md` for Windows users encountering complex `JAVA_HOME` path evaluation issues during Maven wrapper execution.
