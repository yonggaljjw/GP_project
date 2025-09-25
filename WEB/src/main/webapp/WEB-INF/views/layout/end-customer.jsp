    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    <footer style="text-align:center;color:#9CA3AF;font-size:12px;margin:26px 0">
      © 미정
    </footer>
  </main>
</div>

<script src="${pageContext.request.contextPath}/resources/static/js/app.js?v=${applicationScope.staticVer}"></script>
<c:if test="${not empty param.pageJs}">
  <script src="${pageContext.request.contextPath}${param.pageJs}?v=${applicationScope.staticVer}"></script>
</c:if>
</body>
</html>
