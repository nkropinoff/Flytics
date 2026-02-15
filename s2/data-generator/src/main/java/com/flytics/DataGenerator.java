package com.flytics;

import net.datafaker.Faker;
import org.apache.commons.math3.distribution.ZipfDistribution;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

public class DataGenerator {

    private static final int COUNT_CLIENTS = 260_000;
    private static final int COUNT_PASSENGERS = 260_000;
    private static final int COUNT_FLIGHTS = 260_000;
    private static final int COUNT_BOOKINGS = 500_000;

    private static final int BATCH_SIZE = 5000;

    private static final String DB_URL = "jdbc:postgresql://localhost:54322/flytics";
    private static final String USER = "postgres";
    private static final String PASS = "postgres";

    private final Connection conn;
    private final Faker faker;
    private final Random random;

    public DataGenerator() throws SQLException {
        this.conn = DriverManager.getConnection(DB_URL, USER, PASS);
        this.conn.setAutoCommit(false);
        this.faker = new Faker();
        this.random = new Random();
    }

    public static void main(String[] args) {
        try {
            DataGenerator generator = new DataGenerator();
            generator.generateAll();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void generateAll() throws SQLException {
        System.out.println("Starting data generation...");

        List<Integer> clientIds = generateClients();

        generatePassengers();

        List<Integer> flightIds = generateFlights();

        generateBookings(clientIds, flightIds);

        conn.commit();
        conn.close();
        System.out.println("All data generated successfully!");
    }

    private List<Integer> generateClients() throws SQLException {
        System.out.println("Generating Clients...");
        String sql = "INSERT INTO client (first_name, last_name, email, password_hash, phone_number, registration_date, loyalty_points, home_address_coords, notes) VALUES (?, ?, ?, ?, ?, ?, ?, POINT(?, ?), ?)";
        PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

        List<Integer> ids = new ArrayList<>(COUNT_CLIENTS);

        for (int i = 0; i < COUNT_CLIENTS; i++) {
            ps.setString(1, faker.name().firstName());
            ps.setString(2, faker.name().lastName());
            ps.setString(3, faker.internet().emailAddress() + i);
            ps.setString(4, "hash_" + i);
            ps.setString(5, faker.phoneNumber().cellPhone());
            ps.setObject(6, LocalDate.now().minusDays(random.nextInt(365 * 5)));

            int points = (random.nextInt(10) > 8) ? random.nextInt(10000) : 0;
            ps.setInt(7, points);

            if (random.nextDouble() > 0.15) {
                ps.setDouble(8, 55.75 + (random.nextDouble() - 0.5));
                ps.setDouble(9, 37.61 + (random.nextDouble() - 0.5));
            } else {
                ps.setNull(8, Types.DOUBLE);
                ps.setNull(9, Types.DOUBLE);
            }

            if (random.nextDouble() > 0.10) {
                ps.setString(10, faker.lorem().sentence(3 + random.nextInt(5)));
            } else {
                ps.setNull(10, Types.VARCHAR);
            }

            ps.addBatch();
            if (i % BATCH_SIZE == 0) {
                ps.executeBatch();
                System.out.print(".");
            }
        }
        ps.executeBatch();

        ResultSet rs = ps.getGeneratedKeys();
        while (rs.next()) ids.add(rs.getInt(1));
        System.out.println(" Clients done.");
        return ids;
    }

    private void generatePassengers() throws SQLException {
        System.out.println("Generating Passengers...");
        String sql = "INSERT INTO passenger (first_name, last_name, birthdate, passport_series, passport_number, profile_data, gender, has_children) VALUES (?, ?, ?, ?, ?, ?::jsonb, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);

        String[] meals = {"standard", "vegan", "kosher", "halal", "gluten_free", "child"};
        String[] seats = {"window", "aisle", "middle", "extra_space"};

        for (int i = 0; i < COUNT_PASSENGERS; i++) {
            ps.setString(1, faker.name().firstName());
            ps.setString(2, faker.name().lastName());
            ps.setObject(3, LocalDate.now().minusYears(18 + random.nextInt(60)));
            ps.setString(4, String.format("%04d", random.nextInt(9999)));
            ps.setString(5, String.format("%06d", i));

            if (random.nextDouble() > 0.20) {
                String meal = meals[random.nextInt(meals.length)];
                String seat = seats[random.nextInt(seats.length)];
                boolean priority = random.nextBoolean();
                String json = String.format("{\"meal\": \"%s\", \"seat\": \"%s\", \"priority\": %b}", meal, seat, priority);
                ps.setString(6, json);
            } else {
                ps.setNull(6, Types.VARCHAR);
            }

            ps.setString(7, random.nextBoolean() ? "M" : "F");
            ps.setBoolean(8, random.nextBoolean());

            ps.addBatch();
            if (i % BATCH_SIZE == 0) ps.executeBatch();
        }
        ps.executeBatch();
        System.out.println(" Passengers done.");
    }

    private List<Integer> generateFlights() throws SQLException {
        System.out.println("Generating Flights...");
        String sql = "INSERT INTO flight (flight_number, aircraft_id, departure_time, arrival_time, status_id, flight_tags, booking_window) VALUES (?, ?, ?, ?, ?, ?, ?::tstzrange)";
        PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

        List<Integer> ids = new ArrayList<>(COUNT_FLIGHTS);
        List<String> flightNums = Arrays.asList("SU100", "SU101", "DP200", "S7300", "UT400");
        String[] allTags = {"wifi", "meal", "tv", "power", "business_class", "priority"};

        for (int i = 0; i < COUNT_FLIGHTS; i++) {
            String fNum = flightNums.get(random.nextInt(flightNums.size()));
            LocalDateTime depTime = LocalDateTime.now().plusHours(i);

            ps.setString(1, fNum);
            ps.setInt(2, 1 + random.nextInt(5));
            ps.setObject(3, depTime);
            ps.setObject(4, depTime.plusHours(2));
            ps.setInt(5, 1 + random.nextInt(4));

            if (random.nextDouble() > 0.05) {
                int numTags = 1 + random.nextInt(3);
                Set<String> tagSet = new HashSet<>();
                while (tagSet.size() < numTags) {
                    tagSet.add(allTags[random.nextInt(allTags.length)]);
                }
                ps.setArray(6, conn.createArrayOf("text", tagSet.toArray()));
            } else {
                ps.setNull(6, Types.ARRAY);
            }

            String range = String.format("[\"%s\", \"%s\")", depTime.minusMonths(3), depTime.minusHours(1));
            ps.setString(7, range);

            ps.addBatch();
            if (i % BATCH_SIZE == 0) ps.executeBatch();
        }
        ps.executeBatch();

        ResultSet rs = ps.getGeneratedKeys();
        while (rs.next()) ids.add(rs.getInt(1));
        System.out.println(" Flights done.");
        return ids;
    }

    private void generateBookings(List<Integer> clientIds, List<Integer> flightIds) throws SQLException {
        System.out.println("Generating Bookings (Zipf)...");
        String sql = "INSERT INTO booking (client_id, booking_date, total_cost, status_id, discount_code, channel, insurance_amount) VALUES (?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);

        ZipfDistribution zipf = new ZipfDistribution(clientIds.size(), 1.5);

        for (int i = 0; i < COUNT_BOOKINGS; i++) {
            int zipfIndex = zipf.sample() - 1;
            int clientId = clientIds.get(zipfIndex);

            ps.setInt(1, clientId);
            LocalDateTime bookingDate = LocalDateTime.now()
                    .minusDays(random.nextInt(365))
                    .minusSeconds(random.nextInt(86400))
                    .minusNanos(random.nextInt(999999999));

            ps.setObject(2, bookingDate);
            ps.setInt(3, 5000 + random.nextInt(50000));
            ps.setInt(4, 1 + random.nextInt(3));

            ps.setString(5, random.nextDouble() < 0.1 ? "PROMO2025" : null);
            ps.setString(6, faker.options().option("WEB", "APP", "PARTNER", "OFFLINE"));

            if (random.nextDouble() < 0.2) {
                ps.setDouble(7, 500.00);
            } else {
                ps.setNull(7, Types.NUMERIC);
            }

            ps.addBatch();
            if (i % BATCH_SIZE == 0) {
                ps.executeBatch();
                System.out.print(".");
            }
        }
        ps.executeBatch();
        System.out.println(" Bookings done.");
    }
}
