package com.example.demo.config;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import java.io.IOException;

@Component @Order(1)
public class AuthGuardFilter implements Filter {
    @Override public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        HttpSession session = req.getSession(false);

        // 보호 대상
        boolean needLogin = uri.startsWith("/consumer/") || uri.startsWith("/staff/");

        if (needLogin) {
            String role = (session == null) ? null : (String) session.getAttribute("LOGIN_ROLE");
            if (role == null) { res.sendRedirect("/login"); return; }
            if (uri.startsWith("/consumer/") && !"CONSUMER".equals(role)) { res.sendError(403); return; }
            if (uri.startsWith("/staff/")    && !"STAFF".equals(role))    { res.sendError(403); return; }
        }
        chain.doFilter(request, response);
    }
}
