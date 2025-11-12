package com.trilabs94.ecm_db_init.configuration;

import jakarta.annotation.PostConstruct;
import org.flywaydb.core.Flyway;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FlywayConfig {

    @Bean
    public Flyway customerFlyway() {
        return Flyway.configure()
                .dataSource("jdbc:postgresql://localhost:5433/customer_db", "postgres", "postgres")
                .locations("classpath:db/migration/customer_db")
                .baselineOnMigrate(true)
                .load();
    }

    @Bean
    public Flyway productFlyway() {
        return Flyway.configure()
                .dataSource("jdbc:postgresql://localhost:5437/product_db", "postgres", "postgres")
                .locations("classpath:db/migration/product_db")
                .baselineOnMigrate(true)
                .load();
    }

    @Bean
    public Flyway orderFlyway() {
        return Flyway.configure()
                .dataSource("jdbc:postgresql://localhost:5434/order_db", "postgres", "postgres")
                .locations("classpath:db/migration/order_db")
                .baselineOnMigrate(true)
                .load();
    }

    @Bean
    public Flyway paymentFlyway() {
        return Flyway.configure()
                .dataSource("jdbc:postgresql://localhost:5435/payment_db", "postgres", "postgres")
                .locations("classpath:db/migration/payment_db")
                .baselineOnMigrate(true)
                .load();
    }

    @Bean
    public Flyway notificationFlyway() {
        return Flyway.configure()
                .dataSource("jdbc:postgresql://localhost:5436/notification_db", "postgres", "postgres")
                .locations("classpath:db/migration/notification_db")
                .baselineOnMigrate(true)
                .load();
    }
}
