package com.iot.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BackendApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(BackendApplication.class, args);
        System.out.println("========================================");
        System.out.println("  IoT Smart Home Backend API Started  ");
        System.out.println("  Port: 8888                           ");
        System.out.println("  Swagger: http://localhost:8888/api   ");
        System.out.println("========================================");
    }
}

