# Entity-relationship diagram

![ERD](erd.png)

```mermaid
erDiagram
    CUSTOMER ||--o{ ORDERS : places
    CUSTOMER ||--o{ RESERVATION : makes
    RESTAURANT_TABLE ||--o{ RESERVATION : "is booked in"
    ORDERS ||--|{ ORDER_ITEM : contains
    MENU_ITEM ||--o{ ORDER_ITEM : "appears in"
    ORDERS ||--o| PAYMENT : "paid by"
    CUSTOMER { int customer_id PK
               string email UK }
    ORDERS { int order_id PK
             int customer_id FK
             numeric total_amount }
    ORDER_ITEM { int order_id PK,FK
                 int menu_item_id PK,FK
                 int quantity }
    MENU_ITEM { int menu_item_id PK
                numeric price }
    RESERVATION { int reservation_id PK
                  int customer_id FK
                  int table_id FK }
    RESTAURANT_TABLE { int table_id PK
                       int capacity }
    PAYMENT { int payment_id PK
              int order_id FK,UK }
    STAFF { int staff_id PK
            string role }
```
`staff` has no foreign key in the approved design (it holds the logins of people who manage the system).
`orders` ⟷ `menu_item` is the many-to-many relationship resolved by the associative table `order_item`.
