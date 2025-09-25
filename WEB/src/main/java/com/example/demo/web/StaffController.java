package com.example.demo.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/staff")
public class StaffController {
    @GetMapping("/home")
    public String home() { return "staff/home"; }

    @GetMapping("/routes")
    public String routes() { return "staff/routes"; }

    @GetMapping("/alerts")
    public String alerts() { return "staff/alerts"; }

    @GetMapping("/aftercare")
    public String aftercare() { return "staff/aftercare"; }
}