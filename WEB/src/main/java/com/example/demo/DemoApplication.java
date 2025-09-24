package com.example.demo;


import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
//import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication
public class DemoApplication {

	public static void main(String[] args) {
		System.setProperty("org.apache.jasper.compiler.disablejsr199", "true");
		SpringApplication.run(DemoApplication.class, args);
	}
}
