package com.example.demo.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.*;

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
    public String aftercare(Model model,
                            @RequestParam(required = false) String range,
                            @RequestParam(required = false) String q,
                            @RequestParam(required = false) String sigungu,
                            @RequestParam(required = false) String channel,
                            @RequestParam(required = false) String status) {

        // 드롭다운(데모 데이터) — JDK 8이면 Arrays.asList(...) 사용해도 됩니다.
        model.addAttribute("sigunguList", Arrays.asList("강남구","종로구","부산진구"));

        // KPI (데모)
        Map<String, Object> ac = new HashMap<>();
        ac.put("total", 384);
        ac.put("csat", 4.3);
        ac.put("nps", 38);
        ac.put("resolveRate", 87);
        model.addAttribute("ac", ac);

        // 피드백/로그 (비우면 JSP의 placeholder가 보입니다)
        model.addAttribute("feedbackList", Collections.emptyList());
        model.addAttribute("actionLogs", Collections.emptyList());

        return "staff/aftercare"; // /WEB-INF/views/staff/aftercare.jsp
    }
}