package com.vehica;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

import java.io.File;

@SpringBootApplication
@EnableScheduling
public class VehicaBackendApplication {

    public static void main(String[] args) {
        // Load single root .env or local .env into System Properties seamlessly
        try {
            Dotenv dotenv = Dotenv.configure()
                    .ignoreIfMissing()
                    .directory("./")
                    .load();
            dotenv.entries().forEach(entry -> {
                if (System.getProperty(entry.getKey()) == null && System.getenv(entry.getKey()) == null) {
                    System.setProperty(entry.getKey(), entry.getValue());
                }
            });

            File parentEnv = new File("../.env");
            if (parentEnv.exists()) {
                Dotenv parentDotenv = Dotenv.configure()
                        .ignoreIfMissing()
                        .directory("../")
                        .load();
                parentDotenv.entries().forEach(entry -> {
                    if (System.getProperty(entry.getKey()) == null && System.getenv(entry.getKey()) == null) {
                        System.setProperty(entry.getKey(), entry.getValue());
                    }
                });
            }
        } catch (Exception ignored) {
        }

        SpringApplication.run(VehicaBackendApplication.class, args);
    }
}

