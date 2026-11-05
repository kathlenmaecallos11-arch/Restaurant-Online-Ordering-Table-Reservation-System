# PostgreSQL Log Review – Group 2 Park It

## 1. Log Configuration

The PostgreSQL logging configuration was inspected.

- **Log Destination:** stderr
- **Logging Collector:** Enabled
- **Log Directory:** log
- **Log Filename:** postgresql-%Y-%m-%d_%H%M%S.log
- **Log Minimum Messages:** warning
- **Log Minimum Error Statement:** error
- **Log Connections:** Not explicitly enabled
- **Log Disconnections:** Off

## 2. Log Findings

- The reviewed logs showed normal checkpoint activities and a database shutdown event.
- No confirmed critical database failure was identified during the review.
- Client disconnection messages were also recorded, but their cause could not be confirmed.
- **Recommendation:** Continue monitoring the PostgreSQL logs for unusual events and recurring errors.

## 3. Limitations

The inspected logs came from the local Park It database environment. Some events, such as failed authentication and client disconnections, did not provide enough information to identify their exact cause.

The SQL errors were related to the inspection queries used during this activity and were not confirmed as Park It application errors.

## 4. Conclusion

Normal checkpoint and shutdown events were also recorded. These findings show the importance of regularly checking PostgreSQL logs to monitor database activity and identify possible issues.
