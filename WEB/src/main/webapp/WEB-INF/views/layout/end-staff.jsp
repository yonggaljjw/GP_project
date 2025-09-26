<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

    <footer style="text-align:center;color:#9CA3AF;font-size:12px;margin:20px 0">
      © 이동점포 · Staff Console
    </footer>
  </main>
</div>

<jsp:include page="/WEB-INF/views/includes/agent-dock.jsp"/>

<script defer src="<c:url value='/js/app.js'/>?v=${applicationScope.staticVer}"></script>
<script defer src="<c:url value='/js/agent-dock.js'/>?v=${applicationScope.staticVer}"></script>
<c:if test="${not empty param.pageJs}">
  <script defer src="<c:url value='${param.pageJs}'/>?v=${applicationScope.staticVer}"></script>
</c:if>
</body>
</html>

