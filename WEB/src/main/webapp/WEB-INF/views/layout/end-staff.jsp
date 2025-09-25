<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

    <footer style="text-align:center;color:#9CA3AF;font-size:12px;margin:20px 0">
      © 이동점포 · Staff Console
    </footer>
  </main>
</div>

<!-- 1) 도크 HTML을 먼저 넣고 -->
<jsp:include page="/WEB-INF/views/includes/agent-dock.jsp"/>

<!-- 2) 공통 JS를 '한 번만' 로드 (defer 권장) -->
<script defer src="<c:url value='/resources/static/js/app.js'/>?v=${applicationScope.staticVer}"></script>
<script defer src="<c:url value='/resources/static/js/agent-dock.js'/>?v=${applicationScope.staticVer}"></script>
<c:if test="${not empty param.pageJs}">
  <script defer src="<c:url value='${param.pageJs}'/>?v=${applicationScope.staticVer}"></script>
</c:if>
</body>
</html>
