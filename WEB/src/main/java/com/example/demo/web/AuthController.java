package com.example.demo.web;

import com.example.demo.domain.UserAccount;
import com.example.demo.service.AuthService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller @RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    @PostMapping("/perform_login")
    public String doLogin(@RequestParam String username,
                          @RequestParam String password,
                          HttpSession session) {

        UserAccount user = authService.authenticate(username, password);
        if (user == null) return "redirect:/login?error";

        // 세션에 최소 정보 저장
        session.setAttribute("LOGIN_USER", user.getUsername());
        session.setAttribute("LOGIN_ROLE", user.getRole());

        return "redirect:" + ("STAFF".equals(user.getRole()) ? "/staff/home" : "/consumer/home");
    }
}
