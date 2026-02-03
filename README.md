# Airbnb Database Project

University database project implementing an Airbnb-like accommodation platform in PostgreSQL.

## Project Structure

```
├── docker-compose.yml       # docker compose setup with postgresql 16
└── airbnb_database.sql      # sql queries       
```

## Database Schema

26 normalized tables including:
- **Core tables:** User, Property, Booking, Payment, Review
- **Relationship tables:** Property_Amenity, Booking_Guest_Payment, Booking_Host_Payout
- **Profile tables:** Host_Profile, Guest_Profile
- **Support tables:** Address, Pricing, Availability, Conversation, Dispute

## Key Features Implemented

- **User management** with separate host/guest profiles
- **Property listings** with amenities and pricing
- **Booking system** with availability calendar
- **Payment processing** with 24-hour hold rule
- **Review system** with bidirectional ratings
- **Commission tracking** (6-12% guest, 3% host)
- **Social network integration** (Facebook connectivity)
- **Ternary relationships** for complex business logic

## Setup Instructions

1. **Start the database:**
   ```bash
   docker-compose up -d
   ```

2. **Access pgAdmin:**
   - Add new server:
     - Host: postgres
     - Port: 5432
     - Username: myuser
     - Password: mysecretpassword
     - Database: mydatabase

3. **Run SQL scripts:**
   - Execute `airbnb_database.sql` to create schema, populate and validate data

## Technologies Used

- **Database:** PostgreSQL 16
- **Containerization:** Docker + Docker Compose
- **Management:** pgAdmin 4
