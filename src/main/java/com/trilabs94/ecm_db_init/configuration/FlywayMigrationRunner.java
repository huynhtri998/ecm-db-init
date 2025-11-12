package com.trilabs94.ecm_db_init.configuration;

import org.flywaydb.core.Flyway;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("!test")
public class FlywayMigrationRunner implements ApplicationRunner {

    private final Flyway customerFlyway;
    private final Flyway productFlyway;
    private final Flyway orderFlyway;
    private final Flyway paymentFlyway;
    private final Flyway notificationFlyway;

    public FlywayMigrationRunner(
            Flyway customerFlyway,
            Flyway productFlyway,
            Flyway orderFlyway,
            Flyway paymentFlyway,
            Flyway notificationFlyway) {
        this.customerFlyway = customerFlyway;
        this.productFlyway = productFlyway;
        this.orderFlyway = orderFlyway;
        this.paymentFlyway = paymentFlyway;
        this.notificationFlyway = notificationFlyway;
    }

    @Override
    public void run(ApplicationArguments args) {
        System.out.println("🚀 Starting Flyway migrations...");

        customerFlyway.migrate();
        productFlyway.migrate();
        orderFlyway.migrate();
        paymentFlyway.migrate();
        notificationFlyway.migrate();

        System.out.println("✅ All Flyway migrations completed successfully!");
    }
}
