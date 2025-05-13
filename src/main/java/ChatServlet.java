

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;

import com.google.gson.*;

/**
 * Servlet implementation class ChatServlet
 */
public class ChatServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

    private static final String API_URL = "https://chatgpt-42.p.rapidapi.com/chatgpt";
    private static final String API_KEY = "14bceefcbdmshf7e1cb649f45162p12739fjsn12a24817f01c";
    private static final String API_HOST = "chatgpt-42.p.rapidapi.com";

    // 🧹 Handle chat clear via GET
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String clearParam = request.getParameter("clear");
        if ("true".equals(clearParam)) {
            HttpSession session = request.getSession();
            session.removeAttribute("chatHistory");
            response.sendRedirect("index.jsp");
        } else {
            response.sendRedirect("index.jsp");
        }
    }

    // 💬 Handle AI interaction via POST
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userMessage = request.getParameter("message");
        String aiResponse;

        try {
            URL url = new URL(API_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("x-rapidapi-key", API_KEY);
            conn.setRequestProperty("x-rapidapi-host", API_HOST);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            // Request body
            JsonObject messageObj = new JsonObject();
            messageObj.addProperty("role", "user");
            messageObj.addProperty("content", userMessage);

            JsonArray messagesArray = new JsonArray();
            messagesArray.add(messageObj);

            JsonObject requestBody = new JsonObject();
            requestBody.add("messages", messagesArray);
            requestBody.addProperty("web_access", false);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(requestBody.toString().getBytes("utf-8"));
            }

            BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
            StringBuilder responseStr = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                responseStr.append(line.trim());
            }

            System.out.println("🔍 RAW API RESPONSE: " + responseStr);

            JsonParser parser = new JsonParser();
            JsonObject jsonResponse = parser.parse(responseStr.toString()).getAsJsonObject();

            JsonElement resultElement = jsonResponse.get("result");
            if (resultElement != null) {
                if (resultElement.isJsonObject()) {
                    aiResponse = resultElement.getAsJsonObject().get("content").getAsString();
                } else if (resultElement.isJsonPrimitive()) {
                    aiResponse = resultElement.getAsString();
                } else {
                    aiResponse = "Unexpected response format.";
                }
            } else {
                aiResponse = "No result returned from API.";
            }

        } catch (Exception e) {
            aiResponse = "Error: " + e.getMessage();
            e.printStackTrace();
        }

        // Save to chat history
        HttpSession session = request.getSession();
        List<Map<String, String>> chatHistory = (List<Map<String, String>>) session.getAttribute("chatHistory");
        if (chatHistory == null) chatHistory = new ArrayList<>();

        Map<String, String> chat = new HashMap<>();
        chat.put("user", userMessage);
        chat.put("ai", aiResponse);
        chatHistory.add(chat);

        session.setAttribute("chatHistory", chatHistory);
        request.setAttribute("aiResponse", aiResponse);
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }
}
