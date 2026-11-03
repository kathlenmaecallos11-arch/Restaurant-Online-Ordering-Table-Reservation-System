<?php
declare(strict_types=1);

/**
 * Tables that fit the party AND have no active reservation overlapping the requested 2-hour
 * window. The same 2-hour window is enforced by the database (constraint ex_reservation_no_overlap).
 */
function available_tables(string $date, string $time, int $guests): array
{
    $start = $date . ' ' . $time . ':00';
    return fetch_all(
        "SELECT t.table_id, t.table_number, t.capacity
           FROM restaurant_table t
          WHERE t.capacity >= ?
            AND t.status <> 'out_of_service'
            AND NOT EXISTS (
                SELECT 1 FROM reservation r
                 WHERE r.table_id = t.table_id
                   AND r.reservation_status IN ('pending', 'confirmed', 'seated')
                   AND tsrange(r.reservation_date + r.reservation_time,
                               r.reservation_date + r.reservation_time + interval '2 hours')
                       && tsrange(?::timestamp, ?::timestamp + interval '2 hours'))
          ORDER BY t.capacity, t.table_number",
        [$guests, $start, $start]
    );
}

function reservations_list(): void
{
    $customer = require_customer();
    $rows = fetch_all(
        'SELECT r.reservation_id, r.reservation_date, r.reservation_time, r.number_of_guests,
                r.reservation_status, t.table_number
           FROM reservation r JOIN restaurant_table t ON t.table_id = r.table_id
          WHERE r.customer_id = ? ORDER BY r.reservation_date DESC, r.reservation_time DESC',
        [$customer['customer_id']]
    );
    render('reservations/index', ['reservations' => $rows]);
}

/** Feature 7: check table availability; Feature 6: choose a table to reserve. */
function reservation_new(): void
{
    require_customer();
    $date = get_param('date');
    $time = get_param('time');
    $guests = (int) get_param('guests', '2');
    $tables = null;
    $errors = [];

    if ($date !== '' || $time !== '') {
        if (!valid_date($date) || !valid_slot($time)) {
            $errors[] = 'Choose a valid date and time slot.';
        } elseif ($guests < 1 || $guests > 20) {
            $errors[] = 'Guests must be between 1 and 20.';
        } elseif (strtotime($date . ' ' . $time) <= time()) {
            $errors[] = 'Choose a date and time in the future.';
        } else {
            $tables = available_tables($date, $time, $guests);
        }
    }
    render('reservations/new', compact('date', 'time', 'guests', 'tables', 'errors'));
}

function reservation_create(): void
{
    $customer = require_customer();
    csrf_check();
    $date = post('date');
    $time = post('time');
    $guests = (int) post('guests');
    $tableId = (int) post('table_id');

    if (!valid_date($date) || !valid_slot($time) || $guests < 1 || $guests > 20
        || strtotime($date . ' ' . $time) <= time()) {
        flash('error', 'That reservation request is not valid.');
        redirect('/reservations/new');
    }
    try {
        q('INSERT INTO reservation (customer_id, table_id, reservation_date, reservation_time, number_of_guests)
           VALUES (?, ?, ?, ?, ?)',
          [$customer['customer_id'], $tableId, $date, $time, $guests]);
    } catch (PDOException $e) {
        $state = (string) $e->getCode();
        if ($state === '23P01') {          // exclusion_violation: someone booked the table first
            flash('error', 'Sorry, that table was just booked. Please choose another table or time.');
        } elseif ($state === '23514') {    // check_violation: capacity trigger
            flash('error', 'That table is too small for your party.');
        } elseif ($state === '23503') {    // foreign_key_violation: unknown table
            flash('error', 'That table does not exist.');
        } else {
            error_log('[RORS] reservation failed: ' . $e->getMessage());
            flash('error', 'We could not save your reservation.');
        }
        redirect('/reservations/new?date=' . urlencode($date) . '&time=' . urlencode($time) . '&guests=' . $guests);
    }
    flash('success', 'Your table is reserved. See you on ' . dt($date, 'M j, Y') . ' at ' . dt($time, 'g:i A') . '!');
    redirect('/reservations');
}

function reservation_cancel(): void
{
    $customer = require_customer();
    csrf_check();
    $stmt = q("UPDATE reservation SET reservation_status = 'cancelled'
                WHERE reservation_id = ? AND customer_id = ? AND reservation_status IN ('pending', 'confirmed')",
              [(int) post('reservation_id'), $customer['customer_id']]);
    flash($stmt->rowCount() === 1 ? 'success' : 'error',
          $stmt->rowCount() === 1 ? 'Reservation cancelled.' : 'That reservation cannot be cancelled.');
    redirect('/reservations');
}
