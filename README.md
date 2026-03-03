# Airbnb Database Project

University database project implementing an Airbnb-like accommodation platform in PostgreSQL.

## Project Structure

```
├── docker-compose.yml       # docker compose setup with postgresql 16
├── create.yml     # sql create statements
├── insert.yml     # sql insert statements
└── select.sql     # sql test queries (20 base + 3 complex)       
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

2. **Look at the console output**
   - Console will contain the result of all the executed queries


## Technologies Used

- **Database:** PostgreSQL 16
- **Containerization:** Docker + Docker Compose
